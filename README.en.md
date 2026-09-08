<h4 align="right"><a href="./README.md">中文</a> | <strong>English</strong></h4>

# phpdock-images

Prebuilt multi-arch (`linux/amd64` + `linux/arm64`) PHP 8.5 images from
[laradock](https://github.com/laradock/laradock), with PostgreSQL, Redis,
ImageMagick and more extensions already compiled in.

```bash
docker pull yifans/phpdock:8.5-php-fpm          # rolling tag, always the newest build
docker pull yifans/phpdock:8.5-php-fpm-202607   # year-month snapshot, never moves
```

`php-worker` and `workspace` follow the same tag scheme.

No 20-minute local build on Apple Silicon, and no laradock fork to maintain.

## How this repo is maintained

The interesting part is not the images. It's a reusable pattern for tracking
upstream Dockerfiles you don't own:

- **Mirror, don't fork.** `.github/scripts/sync-upstream.sh` refreshes only the
  dirs upstream owns (`php-fpm/`, `php-worker/`, `workspace/`); files you add are
  never touched, so each sync lands as a reviewable `git diff`. Upstream repo,
  branch, synced dirs and excluded paths all live in
  `.github/scripts/.sync-config.sh`. Point it elsewhere to track a different
  project.

- **Generate the config surface.** laradock's three Dockerfiles are configured
  entirely through build `ARG`s. `.github/scripts/extract-env.sh` scrapes them
  into `.env.laradock` as 151 `NAME=default` lines, grouped per image and deduped
  across Dockerfiles. It is generated — never hand-edit it.

- **Keep your choices in a 19-line diff.** `.env.laradock.preference` is the
  only hand-maintained config: just the ARGs this project overrides. "What did
  I change from stock laradock?" stays a file you can read in one screen.

- **One merge point, and it's tested.** `.github/scripts/build-args.sh` merges the
  two files into deduped `NAME=value` (preference wins, empty values dropped),
  the single place build args are assembled. `make test-args` pins it: merge
  rules, parsing edges, and a check that every emitted name is a real Dockerfile
  `ARG`. CI runs it before the build, so a broken merge can't reach a published
  image.

- **Weekly sync, manual publish.** `sync-upstream` runs every Monday and opens a
  PR only when upstream actually changed; `laradock-image` can only be triggered
  manually in [Actions](https://github.com/imzyf/phpdock-images/actions/), which
  also keeps the `sync-upstream` run history. The human step is deliberate:
  reviewing the diff is where you decide whether a new upstream ARG deserves an
  override, and three images across two architectures is too expensive to kick
  off by accident. Every currently available tag for the three images is listed
  on [Docker Hub](https://hub.docker.com/r/yifans/phpdock/tags).
