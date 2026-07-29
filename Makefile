# 下面用到数组，需要 bash（macOS 的 /bin/sh 不够）。
# 多条命令的 recipe 开头显式写 set -e，而不是用 .SHELLFLAGS：
# macOS 自带 GNU Make 3.81 会忽略 .SHELLFLAGS（3.82+ 才支持），
# 依赖它会变成 CI 上失败、本机不失败。
SHELL := bash

PHP_VERSION ?= 8.5
IMAGE_NAME  ?= php-fpm
IMAGE       ?= yifans/phpdock:local-$(PHP_VERSION)-$(IMAGE_NAME)

.DEFAULT_GOAL := help

.PHONY: help sync sync-force build-local test-local

help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} \
		/^##@/ {printf "\n\033[1m%s\033[0m\n", substr($$0, 5); next} \
		/^[a-zA-Z0-9_-]+:.*?## / {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST)

##@ Sync

sync: ## Pull latest files from upstream, then regenerate .env.laradock
	bin/sync-upstream.sh
	bin/extract-env.sh

sync-force: ## Sync from upstream, ignoring the clone cache
	LCC_SYNC_CACHE_TTL=0 make sync

##@ Build

# bin/build-args.sh 把 .env.laradock 与 .env.laradock.preference 合并成去重的
# NAME=value 行（CI 消费的是同一份输出）。读进数组，带空格的值
# （如 ADDITIONAL_LOCALES）才能作为单个 --build-arg 传下去。
# 先赋值给变量而不是 < <(...) 读：进程替换的退出码 set -e 看不见，
# build-args.sh 挂掉时会静默地不带任何 --build-arg 就开始构建。
build-local: ## Build ONE image locally (IMAGE_NAME=php-fpm|php-worker|workspace, PHP_VERSION=)
	@set -e; \
	args="$$(bin/build-args.sh)"; \
	extra=(); \
	while IFS= read -r line; do extra+=(--build-arg "$$line"); done <<< "$$args"; \
	docker buildx build "$${extra[@]}" --build-arg LARADOCK_PHP_VERSION=$(PHP_VERSION) -f $(IMAGE_NAME)/Dockerfile -t $(IMAGE) --load $(IMAGE_NAME)

test-local: build-local ## Build-local, then smoke-test that image
	docker run --rm $(IMAGE) php -v
ifeq ($(IMAGE_NAME),php-fpm)
	docker run --rm $(IMAGE) php -m | grep -qi pgsql && echo "pgsql: ok"
	docker run --rm $(IMAGE) php -m | grep -qi redis && echo "redis: ok"
endif
