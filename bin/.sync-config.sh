#!/usr/bin/env bash
#
# bin/sync-upstream.sh 的共享配置（被 source 引入，而非执行）。
#
# 变量都给 source 方用，单独 lint 这个文件必然报未使用。
# shellcheck disable=SC2034

# 按需修改以下变量以匹配你的上游仓库。
UPSTREAM_REPO="https://github.com/laradock/laradock.git"
UPSTREAM_BRANCH="master"

# 从上游镜像的目录（仅刷新上游拥有的条目，本地新增文件保留）。
SYNC_DIRS=(
  php-fpm
  php-worker
  workspace
)

# 要从上游拉取的独立文件。格式 "上游路径" 或 "上游路径:本地路径"（改名落地）。
SYNC_FILES=(
)

# 从同步中排除的本地化文件（rsync --exclude）。
EXCLUDE_GLOBS=(
  'php-fpm/aerospike.ini'
  'php-fpm/mysql.ini'
  'php-fpm/php5*.ini'
  'php-fpm/php7*.ini'
  'php-fpm/php8*.ini'
  'php-fpm/phalcon.ini'
  'php-fpm/xhprof.ini'
  'php-fpm/xdebug'
  'workspace/aerospike.ini'
  'workspace/insecure_id_rsa.ppk'
  '*/compose.yml'
  '*/defaults.env'
)
