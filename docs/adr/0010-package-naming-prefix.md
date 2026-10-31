# ADR-0010：包名统一 `modoo_` 前缀，插件 id 用 `modoo.<能力>.<名字>`

- 状态：已接受
- 日期：2026-10-31
- 相关：`docs/CODE_STYLE.md` §3.1、§9.2、`tool/new_plugin.dart`

## 背景

monorepo 里包名叫 `core` / `data` / `reader` 看上去干净，但 pub 包名是全局命名空间：
`core`、`data`、`ui` 这类名字在 pub.dev 上必然撞车，一旦将来想把某个包单独发布（例如
`plugin_api` 给插件作者用），改名会牵连所有 import。插件 id 也需要一个稳定命名空间，
否则不同来源的插件会互相覆盖设置。

## 决策

- pub 包名统一 `modoo_<用途>`：`modoo_core`、`modoo_data`、`modoo_domain`、`modoo_reader_engine`、
  `modoo_plugin_api`、`modoo_plugin_host`、`modoo_ui`、`modoo_l10n`、`modoo_sync`、`modoo_source_engine`、
  `modoo_format_txt`…
- **目录名不加前缀**：`packages/core`、`packages/reader`、`plugins/format_txt`（路径短、grep 友好）。
- 插件 id 用 `modoo.<能力>.<名字>`，能力取 `format` / `source` / `tts` / `sync`，
  例如 `modoo.format.txt`。插件 id 一经发布不再修改，宿主用它查 ARB 文案（`plugin_<id>_name`）与设置。
- 模板插件是唯一例外：`plugins/example_hello` → 包名 `modoo_example_hello`。

## 后果

**正面**

- 任何包都能独立发布而不撞名；插件作者看到 `modoo_` 就知道是宿主 API。
- 插件 id 自带命名空间，第三方插件可用 `com.example.format.foo` 而不冲突。
- 目录与包名解耦，路径短，日志与 issue 里引用方便。

**负面**

- `import 'package:modoo_reader_engine/...'` 比 `package:reader/...` 长。
- 新人需要记一次映射表（见 `CODE_STYLE.md` §3.1）。
- 目录名与包名不同，搜索时两种写法都要试。

## 替代方案

| 方案 | 为什么不选 |
| --- | --- |
| 目录名与包名都加前缀 | 路径冗长，`packages/modoo_core` 在文件树里重复信息 |
| 不加前缀、也不打算发布 | 把「将来能否复用」这条路提前堵死，代价不可逆 |
| 插件 id 用随机 UUID | 不可读、不可预测，ARB key 与设置迁移都难写 |

## 复审条件

本项目拆分成多个仓库，或某个包要独立发布到 pub.dev 且需要短名时，可对单包申请例外（需新 ADR）。
