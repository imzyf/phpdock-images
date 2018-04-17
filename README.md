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
build_args=()
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  build_args+=(--build-arg "$line")
done < .env.production

docker buildx build "${build_args[@]}" --build-arg LARADOCK_PHP_VERSION=8.5 -t yifans/php-fpm:test --load .
```

## CI

`.github/workflows/dockerimage.yml` builds PHP `8.5` for `linux/amd64,linux/arm64`, using `.env.development` / `.env.production` as build-args. Tags pushed to Docker Hub:

- `8.5-development`
- `8.5-production`
- `8.5` (alias of `8.5-production`)
