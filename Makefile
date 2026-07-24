# Array + process substitution below need bash (macOS /bin/sh is not enough).
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

# bin/build-args.sh merges .env.laradock + .env.laradock.preference into deduped
# NAME=value lines (same output CI consumes). Read into an array so values with
# spaces (e.g. ADDITIONAL_LOCALES) survive as a single --build-arg token.
build-local: ## Build ONE image locally (IMAGE_NAME=php-fpm|php-worker|workspace, PHP_VERSION=)
	@extra=(); \
	while IFS= read -r line; do extra+=(--build-arg "$$line"); done \
		< <(bin/build-args.sh); \
	docker buildx build "$${extra[@]}" --build-arg LARADOCK_PHP_VERSION=$(PHP_VERSION) -f $(IMAGE_NAME)/Dockerfile -t $(IMAGE) --load $(IMAGE_NAME)

test-local: build-local ## Build-local, then smoke-test that image
	docker run --rm $(IMAGE) php -v
ifeq ($(IMAGE_NAME),php-fpm)
	docker run --rm $(IMAGE) php -m | grep -qi pgsql && echo "pgsql: ok"
	docker run --rm $(IMAGE) php -m | grep -qi redis && echo "redis: ok"
endif
