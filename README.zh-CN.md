[English](README.md) · 中文

# phpdock-images

基于 [laradock](https://github.com/laradock/laradock) 预构建的 PHP 8.5 多架构镜像
（`linux/amd64` + `linux/arm64`），已编译好 PostgreSQL、Redis、ImageMagick 等
17 个扩展。

```bash
docker pull yifans/phpdock:8.5-php-fpm          # 滚动 tag，指向最新一版
docker pull yifans/phpdock:8.5-php-fpm-202607   # 年月快照，内容不再变动
```

另有 `php-worker`、`workspace` 两个镜像，tag 规则相同。生产环境请钉住带年月的
tag。

Apple Silicon 上不用等 20 分钟本地构建，也不用维护一个 laradock fork。

## 工作原理

真正有意思的不是这几个镜像，而是这套「跟踪别人的 Dockerfile」的可复用做法：

- **镜像上游，而不是 fork。** `bin/sync-upstream.sh` 只刷新上游拥有的文件
  （`php-fpm/`、`php-worker/`、`workspace/`），克隆用 sparse + 本地缓存。你在旁边
  新增的文件永不被动，所以每次同步都落成一份可 review 的 `git diff`。上游仓库、
  分支、同步目录、排除路径全部集中在 `bin/.sync-config.sh` 一个文件里——改掉它，
  同一套机制就能跟踪另一个项目。

- **把配置面生成出来。** laradock 三个 Dockerfile 完全靠构建 `ARG` 配置。
  `bin/extract-env.sh` 把它们抽成 `.env.laradock` 里的 151 行 `NAME=default`，
  按镜像分组、跨 Dockerfile 重名去重。这是**生成文件，不要手改**。

- **自己的选择只占 19 行。** `.env.laradock.preference` 是唯一手工维护的配置，
  只写本项目覆盖的那些 ARG。「我到底改了原版 laradock 的什么？」永远是一屏能读完
  的一个文件。

- **只有一个合并点，而且有测试守着。** `bin/build-args.sh` 把上面两个文件合并成
  去重后的 `NAME=value` 行（preference 优先，空值丢弃），是构建参数唯一的组装处。
  `make test-args` 把它的行为钉住：合并规则、解析的边界情况，以及「输出的每个名字
  都真的是某个 Dockerfile 的 `ARG`」。CI 在构建前先跑它，所以合并逻辑悄悄坏掉不会
  一路带到发布出去的镜像里。

- **每周同步，手动发布。** `sync-upstream` 每周一跑，只在上游真的变了时才开 PR。
  `laradock-image` 只能手动触发：先 merge 同步 PR，再自己去点构建。这两步故意都留给
  人——review diff 正是你判断「上游新增的 ARG 需不需要覆盖」的地方，而三个镜像
  × 两个架构太贵，不该被顺手带起来。

本地可用的 target 见 `make help`。

## 链接

- [Actions](https://github.com/imzyf/phpdock-images/actions/) ·
  [Docker Hub tags](https://hub.docker.com/r/yifans/phpdock/tags)
