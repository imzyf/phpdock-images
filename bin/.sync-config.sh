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

# 同步时「完全不碰」的路径：既不从上游复制，也不删除本地已有的同名文件。
# 按仓库根的相对路径匹配，只覆盖 SYNC_DIRS 下的顶级条目（<dir>/<name>）。
# 因此这里同时用于两件事：
#   1. 保护本项目手写、且与上游同名的文件（compose.yml、defaults.env）；
#   2. 剪掉用不到的上游文件（本地不存在的，跳过即保持不存在）。
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
