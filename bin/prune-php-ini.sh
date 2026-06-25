#!/usr/bin/env bash
#
# Delete php-fpm/php<version>.ini files mirrored from upstream
# laradock/laradock. None of them are referenced by php-fpm/Dockerfile
# (it only COPYs laravel.ini, opcache.ini, xdebug.ini into conf.d), so
# they're dead weight. Re-run after bin/sync-upstream.sh, which mirrors
# php-fpm/ unmodified and would otherwise restore them.
#
# Usage: bin/prune-php-ini.sh

set -euo pipefail

ROOT_DIR="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

shopt -s nullglob
files=("${ROOT_DIR}"/php-fpm/php[0-9]*.ini)
shopt -u nullglob

if [[ ${#files[@]} -eq 0 ]]; then
  echo "==> No php-fpm/php*.ini files to prune"
  exit 0
fi

for f in "${files[@]}"; do
  echo "==> Removing ${f#"${ROOT_DIR}"/}"
  rm -f "${f}"
done
