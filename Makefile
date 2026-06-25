PHP_VERSION ?= 8.5
IMAGE_NAME  ?= php-fpm
IMAGE       ?= yifans/phpdock:local-$(PHP_VERSION)-$(IMAGE_NAME)

.DEFAULT_GOAL := help

.PHONY: help sync build-local test-local

help:
	@echo "Targets:"
	@echo "  sync         - pull latest files from laradock/laradock"
	@echo "  build-local  - build ONE image locally, selected via IMAGE_NAME=$(IMAGE_NAME) (php-fpm|php-worker|workspace), PHP_VERSION=$(PHP_VERSION)"
	@echo "  test-local   - build-local, then smoke-test that image"

sync:
	bin/sync-upstream.sh
	bin/prune-php-ini.sh
	bin/generate-env.sh

# .env.laradock holds every image's ARG defaults; .env.laradock.preference
# overrides a subset of them with this project's chosen values (concatenated
# after, so its --build-arg occurrences win on conflicting names).
build-local:
	@build_args=""; \
	for f in .env.laradock .env.laradock.preference; do \
		while IFS= read -r line; do \
			line="$${line%%#*}"; \
			line="$$(printf '%s' "$$line" | sed -e 's/[[:space:]]*$$//')"; \
			[ -z "$$line" ] && continue; \
			build_args="$$build_args --build-arg $$line"; \
		done < $$f; \
	done; \
	docker buildx build $$build_args --build-arg LARADOCK_PHP_VERSION=$(PHP_VERSION) -f $(IMAGE_NAME)/Dockerfile -t $(IMAGE) --load $(IMAGE_NAME)

test-local: build-local
	docker run --rm $(IMAGE) php -v
ifeq ($(IMAGE_NAME),php-fpm)
	docker run --rm $(IMAGE) php -m | grep -qi pgsql && echo "pgsql: ok"
	docker run --rm $(IMAGE) php -m | grep -qi redis && echo "redis: ok"
endif
