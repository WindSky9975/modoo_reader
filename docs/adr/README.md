# 架构决策记录（ADR）

本目录记录**不可轻易推翻的技术决策**。代码会变，决策的**理由**必须留下来 —— 否则半年后会有人（可能是你自己）
在不知道代价的情况下把它改掉，然后在同一个坑里再摔一次。

## 什么时候写 ADR

写：

- 改变了分层、依赖方向、包边界；
- 选型（框架、存储、同步协议、渲染路线）；
- 公共契约（`plugin_api`、书源 DSL、数据库表语义）；
- 明确「不做什么」且有长期影响的决定。

不写：内部实现细节、私有 API 命名、局部重构、测试组织。

## 命名与格式

- 文件名：`NNNN-kebab-case-title.md`，编号四位、只增不改，不复用。
- 状态：`提议` / `已接受` / `已废弃（被 ADR-XXXX 取代）`。
- 正文顺序：**背景 → 决策 → 后果（正/负）→ 替代方案**。后果里的「负」不可省略。
- 已接受的 ADR **不修改内容**；要改就写新 ADR 并在旧的上标状态。

## 索引

| 编号 | 决策 | 状态 |
| --- | --- | --- |
| [0001](0001-compile-time-plugins.md) | 编译期 Dart 插件 + 注册表，而非运行时热插拔 | 已接受 |
| [0002](0002-char-offset-as-truth.md) | 正文唯一真相是字符偏移，分页只是缓存 | 已接受 |
| [0003](0003-source-rules-as-data.md) | 书源规则作为「数据」由内置引擎执行 | 已接受 |
| [0004](0004-scroll-first-then-paginate.md) | 先滚动后分页的渲染路线 | 已接受 |
| [0005](0005-webdav-only-sync.md) | 同步只支持 WebDAV，不自建服务 | 已接受 |
| [0006](0006-no-bundled-book-sources.md) | 不内置任何书源 | 已接受 |
| [0007](0007-no-bundled-fonts.md) | 字体不打包进 APK，走系统字体 + 可选下载 | 待验证（体积） |
| [0008](0008-curl-page-turn-deferred.md) | 仿真翻页延后到 M6，且必须可降级 | 已接受 |
| [0009](0009-riverpod-codegen.md) | Riverpod 锁 3.x，统一走 `@riverpod` 代码生成 | 已接受 |
| [0010](0010-package-naming-prefix.md) | 包名统一 `modoo_` 前缀，插件 id 用 `modoo.<能力>.<名字>` | 已接受 |
| [0011](0011-pure-dart-charsets.md) | 字符集解码用纯 Dart 的 `enough_convert`（MPL-2.0） | 已接受 |

新增 ADR 时：复制 `template.md` → 改编号与标题 → 加进上表 → 在 PR 描述里说明「为什么需要一条新 ADR」。

模板见 [`template.md`](template.md)。
