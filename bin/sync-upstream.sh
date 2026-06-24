#!/usr/bin/env bash
#
# Sync php-fpm, php-worker, and workspace files from upstream
# laradock/laradock (master branch).
#
# Clones laradock/laradock (sparse, just the three dirs below) into a tmp
# dir and mirrors each one into the matching subdirectory at the repo
# root, unmodified (this repo keeps them unmodified, see README.md).
#
# Run bin/generate-env.sh afterwards to refresh .env.laradock from the
# newly synced Dockerfiles.
#
# Usage: bin/sync-upstream.sh

set -euo pipefail

ROOT_DIR="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
UPSTREAM_REPO="https://github.com/laradock/laradock.git"
IMAGES=(php-fpm php-worker workspace)

clone_dir="$(mktemp -d)"
trap 'rm -rf "${clone_dir}"' EXIT

echo "==> Cloning laradock/laradock (${IMAGES[*]} only)"
git clone --depth=1 --filter=blob:none --sparse -q "${UPSTREAM_REPO}" "${clone_dir}"
git -C "${clone_dir}" sparse-checkout set "${IMAGES[@]}"

shopt -s dotglob

for image in "${IMAGES[@]}"; do
  echo "==> Mirroring files into ${image}/"
  mkdir -p "${ROOT_DIR}/${image}"
  rm -rf "${ROOT_DIR}/${image:?}"/*
  for f in "${clone_dir}/${image}"/*; do
    name="$(basename "${f}")"
    mv "${f}" "${ROOT_DIR}/${image}/${name}"
    echo "  - ${image}/${name}"
  done
done

echo "==> Done. Review with: git diff, then run bin/generate-env.sh"
