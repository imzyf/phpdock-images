# My PHP-FPM Docker Base Image

- [GitHub php-fpm-image](https://github.com/imzyf/php-fpm-image/)
- [GitHub php-fpm-image - actions](https://github.com/imzyf/php-fpm-image/actions/)
- [DockerHub php-fpm - tags](https://hub.docker.com/repository/registry-1.docker.io/yifans/php-fpm/tags?page=1&ordering=last_updated)

## Origin

Files are mirrored from [laradock/laradock](https://github.com/laradock/laradock/tree/master/php-fpm)'s `php-fpm/` directory (single generic `Dockerfile`, parameterized by `LARADOCK_PHP_VERSION`).

## Sync from upstream

```bash
bin/sync-upstream.sh   # pull latest files from laradock/laradock into repo root
bin/generate-env.sh    # regenerate .env.example from the Dockerfile's ARGs
```

After syncing, diff `.env.development` / `.env.production` against `.env.example` to pick up any new ARGs.

## Build locally

```bash
make build                       # PHP_VERSION=8.5 PROFILE=production
make build PROFILE=development
make test                        # build + smoke-check (php -v, pgsql, redis)
```

## CI

`.github/workflows/dockerimage.yml` builds PHP `8.5` for `linux/amd64,linux/arm64`, using `.env.production` (and `.env.development`, once uncommented in the matrix) as build-args.

Triggers: push/PR to `main`, or manually via the "Run workflow" button (`workflow_dispatch`) on the [Actions tab](https://github.com/imzyf/php-fpm-image/actions/workflows/dockerimage.yml).

Tags pushed to Docker Hub:

- `8.5-production`
- `8.5` (alias of `8.5-production`)
- `8.5-development` (once enabled)
