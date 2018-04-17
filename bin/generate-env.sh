#!/usr/bin/env bash
#
# Generate .env.example from the `ARG` lines declared in the Dockerfile.
# Overwrites .env.example with one line per ARG: NAME=default. ARGs
# without a default, or with a self-referencing default (e.g.
# ARG NEW_RELIC=${NEW_RELIC}), are still included with an empty value.
#
# Usage: bin/generate-env.sh

set -euo pipefail

ROOT_DIR="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
dockerfile="${ROOT_DIR}/Dockerfile"
out_env="${ROOT_DIR}/.env.example"

out="$(mktemp)"
trap 'rm -f "${out}"' EXIT

declare -A seen
while IFS= read -r argline; do
  name="${argline%%=*}"
  default=""
  [[ "${argline}" == *=* ]] && default="${argline#*=}"
  [[ "${default}" == '${'*'}' ]] && default=""

  [[ -n "${seen[${name}]+x}" ]] && continue
  seen["${name}"]=1

  echo "${name}=${default}" >> "${out}"
done < <(grep '^ARG ' "${dockerfile}" | sed -E 's/^ARG +//')

mv "${out}" "${out_env}"
echo "==> Wrote $(wc -l < "${out_env}") vars to .env.example"
