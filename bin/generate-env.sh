#!/usr/bin/env bash
#
# Generate a single root .env.laradock from the `ARG` lines declared in
# every image's Dockerfile (see IMAGES in bin/.sync-config.sh).
#
# Overwrites .env.laradock with one line per ARG: NAME=default, grouped
# under a "# ===== <image> =====" heading per image. An ARG shared by
# more than one Dockerfile is only listed once, under whichever image
# is first in IMAGES order. ARGs without a default get an inline
# comment flagging that, since the build will fail unless it's set
# explicitly. An ARG whose default is a bare reference to another
# variable (e.g. ARG PHP_VERSION=${LARADOCK_PHP_VERSION}) is recorded
# under the referenced name instead of its own local alias, so it
# dedupes against that variable's own ARG declaration.
#
# Usage: bin/generate-env.sh

set -euo pipefail

ROOT_DIR="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
source "$(dirname "${BASH_SOURCE[0]}")/.sync-config.sh"
out_env="${ROOT_DIR}/.env.laradock"

out="$(mktemp)"
trap 'rm -f "${out}"' EXIT

declare -A seen=()
first=1
for image in "${IMAGES[@]}"; do
  dockerfile="${ROOT_DIR}/${image}/Dockerfile"
  section="$(mktemp)"

  while IFS= read -r argline; do
    name="${argline%%=*}"
    default=""
    [[ "${argline}" == *=* ]] && default="${argline#*=}"
    if [[ "${default}" =~ ^\$\{([A-Za-z_][A-Za-z0-9_]*)\}$ ]]; then
      name="${BASH_REMATCH[1]}"
      default=""
    fi

    [[ -n "${seen[${name}]+x}" ]] && continue
    seen["${name}"]=1

    if [[ -z "${default}" ]]; then
      echo "${name}=    # no default in Dockerfile" >> "${section}"
    else
      echo "${name}=${default}" >> "${section}"
    fi
  done < <(grep '^ARG ' "${dockerfile}" | sed -E 's/^ARG +//')

  if [[ -s "${section}" ]]; then
    {
      [[ "${first}" -eq 0 ]] && echo ""
      echo "# ===== ${image} ====="
      cat "${section}"
    } >> "${out}"
    first=0
  fi
  rm -f "${section}"
done

mv "${out}" "${out_env}"
echo "==> Wrote $(grep -cE '^[A-Za-z_][A-Za-z0-9_]*=' "${out_env}") vars to .env.laradock"
