.DEFAULT_GOAL := help

.PHONY: help sync sync-force test-args

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

##@ Test

test-args: ## Check that build-args.sh still merges the env files correctly
	bin/test-build-args.sh
