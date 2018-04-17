#!/usr/bin/env bash
#
# Sync php-fpm files from upstream laradock/laradock (master branch).
#
# Clones laradock/laradock (sparse, php-fpm/ only) into a tmp dir and
# moves every file from php-fpm/ into the repo root as-is (this repo
# keeps them unmodified, see README.md).
#
# Run bin/generate-env.sh afterwards to refresh .env.example from the
# newly synced Dockerfile.
#
# Usage: bin/sync-upstream.sh

set -euo pipefail

ROOT_DIR="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
UPSTREAM_REPO="https://github.com/laradock/laradock.git"

clone_dir="$(mktemp -d)"
trap 'rm -rf "${clone_dir}"' EXIT

echo "==> Cloning laradock/laradock (php-fpm/ only)"
git clone --depth=1 --filter=blob:none --sparse -q "${UPSTREAM_REPO}" "${clone_dir}"
git -C "${clone_dir}" sparse-checkout set php-fpm

echo "==> Mirroring files from php-fpm/"
for f in "${clone_dir}"/php-fpm/*; do
  name="$(basename "${f}")"
  mv "${f}" "${ROOT_DIR}/${name}"
  echo "  - ${name}"
done

echo "==> Done. Review with: git diff, then run bin/generate-env.sh"
