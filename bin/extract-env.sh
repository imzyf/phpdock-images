#!/usr/bin/env bash
#
# 从各镜像 Dockerfile 的 ARG 行抽取默认值，生成根目录 .env.laradock。
# 每行 NAME=default，按镜像分组（# ===== <image> =====）。
# 跨 Dockerfile 重名的 ARG 只保留首次出现（SYNC_DIRS 顺序）。
# 无默认值的 ARG 会加注释标记，构建时需显式传入。
# 默认值若是纯变量引用（如 ${LARADOCK_PHP_VERSION}），归到被
# 引用的变量名下，以便与其自身的 ARG 声明去重。
#
# 用法: bin/extract-env.sh

set -euo pipefail

ROOT_DIR="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
source "$(dirname "${BASH_SOURCE[0]}")/.sync-config.sh"
out_env="${ROOT_DIR}/.env.laradock"

# 临时文件累积结果，成功后一次性替换目标
out="$(mktemp)"
trap 'rm -f "${out}"' EXIT

declare -A seen=()   # 已出现的变量名，用于跨镜像去重
first=1
for image in "${SYNC_DIRS[@]}"; do
  dockerfile="${ROOT_DIR}/${image}/Dockerfile"
  section="$(mktemp)"

  while IFS= read -r argline; do
    name="${argline%%=*}"
    default=""
    [[ "${argline}" == *=* ]] && default="${argline#*=}"
    # 默认值是纯变量引用时，归到被引用的变量名下
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

  # 该镜像有变量才输出分组标题
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
