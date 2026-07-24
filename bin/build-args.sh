#!/usr/bin/env bash
#
# 合并根目录 .env.laradock 与 .env.laradock.preference，输出去重后的
# NAME=value 行（每行一个）到 stdout。后读的文件覆盖同名变量，所以
# preference 胜出。空值行（NAME=，Dockerfile 里没默认值）跳过，避免
# 传出空的 --build-arg。首次出现的顺序被保留，输出稳定可 diff。
#
# 用法: bin/build-args.sh
#   make build-local 与 CI（laradock-image.yml）都消费它的输出。

set -euo pipefail

ROOT_DIR="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

declare -A args=()
order=()
for f in "${ROOT_DIR}/.env.laradock" "${ROOT_DIR}/.env.laradock.preference"; do
  [[ -f "${f}" ]] || continue
  while IFS= read -r line; do
    line="${line%%#*}"
    line="$(printf '%s' "${line}" | sed -e 's/[[:space:]]*$//')"
    [[ -z "${line}" ]] && continue
    name="${line%%=*}"
    value="${line#*=}"
    [[ -z "${value}" ]] && continue
    [[ -z "${args[${name}]+x}" ]] && order+=("${name}")
    args["${name}"]="${value}"
  done < "${f}"
done

for name in "${order[@]}"; do
  printf '%s=%s\n' "${name}" "${args[${name}]}"
done
