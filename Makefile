.DEFAULT_GOAL := help

.PHONY: help open-upstream open-repo sync test-args

help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} \
		/^##@/ {printf "\n\033[1m%s\033[0m\n", substr($$0, 5); next} \
		/^[a-zA-Z0-9_-]+:.*?## / {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST)

##@ Open

open-upstream: ## Open the upstream repo in the browser
	open https://github.com/laradock/laradock

open-repo: ## Open this repo's GitHub page in the browser
	open https://github.com/imzyf/phpdock-images

##@ Sync

sync: ## Pull latest files from upstream, then regenerate .env.laradock (LCC_SYNC_CACHE_TTL=0 forces a fresh clone)
	.github/scripts/sync-upstream.sh
	.github/scripts/extract-env.sh

##@ Test

test-args: ## Check that build-args.sh still merges the env files correctly
	.github/scripts/test-build-args.sh
