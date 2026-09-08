<h4 align="right"><strong>中文</strong> | <a href="./README.en.md">English</a></h4>

# phpdock-images

基于 [laradock](https://github.com/laradock/laradock) 预构建的 PHP 8.5 多架构镜像
（`linux/amd64` + `linux/arm64`），已编译好 PostgreSQL、Redis、ImageMagick 等
扩展。

```bash
docker pull yifans/phpdock:8.5-php-fpm          # 滚动 tag，指向最新一版
docker pull yifans/phpdock:8.5-php-fpm-202607   # 年月快照，内容不再变动
```

另有 `php-worker`、`workspace` 两个镜像，tag 规则相同。

Apple Silicon 上不用等 20 分钟本地构建，也不用维护一个 laradock fork。

## 这个仓库怎么维护

真正有意思的不是这几个镜像，而是这套「跟踪别人的 Dockerfile」的可复用做法：

- **镜像上游，而不是 fork。** `.github/scripts/sync-upstream.sh` 只刷新上游拥有
  的目录（`php-fpm/`、`php-worker/`、`workspace/`），你新增的文件不会被改动，所以
  每次同步都落成一份可 review 的 `git diff`。上游仓库、分支、同步目录、排除路径
  全在 `.github/scripts/.sync-config.sh` 里，改成别的仓库就能跟踪别的项目。

- **把配置面生成出来。** laradock 三个 Dockerfile 完全靠构建 `ARG` 配置。
  `.github/scripts/extract-env.sh` 把它们抽成 `.env.laradock` 里的 151 行
  `NAME=default`，按镜像分组、跨 Dockerfile 重名去重。这是**生成文件，不要手改**。

- **自己的选择只占 19 行。** `.env.laradock.preference` 是唯一手工维护的配置，
  只写本项目覆盖的那些 ARG。「我到底改了原版 laradock 的什么？」永远是一屏能读完
  的一个文件。

- **只有一个合并点，而且有测试守着。** `.github/scripts/build-args.sh` 把上面两个
  文件合并成去重后的 `NAME=value`（preference 优先，空值丢弃），是构建参数唯一的
  组装处。
  `make test-args` 把它的行为写成测试：合并规则、解析边界，以及每个输出的名字都
  真是某个 Dockerfile 的 `ARG`。CI 在构建前先跑，坏掉的合并逻辑到不了发布的镜像。

- **每周同步，手动发布。** `sync-upstream` 每周一跑，上游真变了才开 PR；
  `laradock-image` 只能在 [Actions](https://github.com/imzyf/phpdock-images/actions/)
  手动触发，该页也保留 `sync-upstream` 的运行记录。留人工是有意的：
  review diff 正是你判断新增 ARG 要不要覆盖的地方，而三镜像 × 双架构太贵，
  不该被顺手带起来。三个镜像当前可用的全部 tag 可在
  [Docker Hub](https://hub.docker.com/r/yifans/phpdock/tags) 查看。
