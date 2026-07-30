English · [中文](README.zh-CN.md)

# phpdock-images

Prebuilt multi-arch (`linux/amd64` + `linux/arm64`) PHP 8.5 images from
[laradock](https://github.com/laradock/laradock) — with PostgreSQL, Redis,
ImageMagick and 14 more extensions already compiled in.

```bash
docker pull yifans/phpdock:8.5-php-fpm          # rolling tag, always the newest build
docker pull yifans/phpdock:8.5-php-fpm-202607   # year-month snapshot, never moves
```

`php-worker` and `workspace` follow the same tag scheme. Pin the dated tag in
production.

No 20-minute local build on Apple Silicon, and no laradock fork to maintain.

## How it works

The interesting part is not the images — it's a reusable pattern for tracking
upstream Dockerfiles you don't own:

- **Mirror, don't fork.** `bin/sync-upstream.sh` refreshes only the files
  upstream owns (`php-fpm/`, `php-worker/`, `workspace/`) from a cached sparse
  clone. Files you add beside them are never touched, so each sync lands as a
  reviewable `git diff`. Upstream repo, branch, synced dirs and excluded paths
  all live in one file: `bin/.sync-config.sh` — point it elsewhere and the same
  machinery tracks a different project.

- **Generate the config surface.** laradock's three Dockerfiles are configured
  entirely through build `ARG`s. `bin/extract-env.sh` scrapes them into
  `.env.laradock` as 151 `NAME=default` lines, grouped per image and deduped
  across Dockerfiles. It is generated — never hand-edit it.

- **Keep your choices in a 19-line diff.** `.env.laradock.preference` is the
  only hand-maintained config: just the ARGs this project overrides. "What did
  I change from stock laradock?" stays a file you can read in one screen.

- **One merge point, and it's tested.** `bin/build-args.sh` merges the two files
  into deduped `NAME=value` lines (preference wins, empty values dropped) — the
  single place build args are assembled. `make test-args` pins that behaviour:
  the merge rules, the parsing edge cases, and a check that every emitted name
  is a real Dockerfile `ARG`. CI runs it before the build, so a silent merge bug
  can't reach a published image.

- **Weekly sync, manual publish.** `sync-upstream` runs every Monday and opens a
  PR only when upstream actually changed. `laradock-image` is manual-only: merge
  the sync PR, then trigger the build yourself. Both steps are deliberately
  human — reviewing the diff is where you decide whether a new upstream ARG
  deserves an override, and three images across two architectures is too
  expensive to kick off by accident.

Run `make help` for the local targets.

## Links

- [Actions](https://github.com/imzyf/phpdock-images/actions/) ·
  [Docker Hub tags](https://hub.docker.com/r/yifans/phpdock/tags)
