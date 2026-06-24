PHP_VERSION ?= 8.5
PROFILE     ?= production
IMAGE       ?= yifans/php-fpm:local-$(PHP_VERSION)-$(PROFILE)
ENV_FILE    := .env.$(PROFILE)

.DEFAULT_GOAL := help

.PHONY: help sync env build test

help:
	@echo "Targets:"
	@echo "  sync   - pull latest files from laradock/laradock"
	@echo "  env    - regenerate .env.example from the Dockerfile's ARGs"
	@echo "  build  - build local image (PHP_VERSION=$(PHP_VERSION) PROFILE=$(PROFILE))"
	@echo "  test   - build, then smoke-test the image"

sync:
	bin/sync-upstream.sh

env:
	bin/generate-env.sh

build:
	@build_args=""; \
	while IFS= read -r line; do \
		[ -z "$$line" ] && continue; \
		build_args="$$build_args --build-arg $$line"; \
	done < $(ENV_FILE); \
	docker buildx build $$build_args --build-arg LARADOCK_PHP_VERSION=$(PHP_VERSION) -t $(IMAGE) --load .

test: build
	docker run --rm $(IMAGE) php -v
	docker run --rm $(IMAGE) php -m | grep -qi pgsql && echo "pgsql: ok"
	docker run --rm $(IMAGE) php -m | grep -qi redis && echo "redis: ok"
