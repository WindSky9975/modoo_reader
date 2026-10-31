# Changelog

本文件记录所有值得注意的变更。格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，
版本号遵循 [SemVer](https://semver.org/lang/zh-CN/)：`0.x` 阶段允许破坏性变更，但必须在条目里写明迁移方式。

分类固定为：`Added` / `Changed` / `Deprecated` / `Removed` / `Fixed` / `Security`。
用户可见的行为变化必须单独写一条，不能混在「重构」里。

---

## [Unreleased]

### Added

- **M2 分页阅读**：
  - 阅读页从滚动改为**分页**：`PageView` + 左右点按翻页（左/右 30% 区域），页脚显示页码，
    末页自动进入下一章，首章末页可翻到下一章；`PageView` 的滑动与「无动画」两种翻页模式可在排版面板切换。
  - 分页引擎 `TextPainterLayoutEngine`（`packages/ui`）：用 `computeLineMetrics` 逐行测量、
    按页高贪心装箱，并把段距算进行盒；产出「字符偏移区间」而不是渲染结果，因此与字号/字体无关的层
    可以复用同一套坐标（ADR-0002）。
  - 页表缓存：新增 `page_layouts` 表（`bookId + chapterIndex + layoutHash` 唯一），命中直接复用，
    `layoutHash` 任一排版字段变化即换一套缓存；`deleteOlderThan` / `deleteForBook` 用于清理。
  - 排版设置持久化：字号、行距、主题、翻页模式写入 `app_settings`，冷启动第一帧就用上次的设置；
    `ReaderSettings.normalized()` 把越界值夹回 14–30 / 1.2–2.4。
  - **改字号保持阅读位置**：重排前记录当前页起始字符偏移，重排后定位到包含该偏移的页。
  - Drift schema **v2**：新增 `page_layouts`、`app_settings`，`onUpgrade` 只追加分支。
  - 新增 3 个中英 ARB 键：翻页 / 滑动 / 无动画。
  - 测试：分页引擎（连续性、覆盖全文、字号变大页数变多、2 万字符单章 < 300ms）、
    `pageIndexForOffset` 边界、页表读写与覆盖、设置往返与夹取、widget 测试补上新 provider override。
- **M1 导入与最小阅读闭环**：
  - 书架上真实数据：列表（格式、章节数）、导入进度遮罩、长按菜单删除（软删除，文件保留）、
    点击进入阅读页；空态与 FAB 都能触发导入。
  - 导入管线：系统文件选择器（`file_picker`）→ 编码探测 → 一次性转码为 UTF-8 副本写入
    `<应用支持目录>/library/` → 插件解析章节 → 一本书 + 全部章节在事务里落库。
    GBK / GB2312 文件可直接导入（ADR-0011）。
  - 阅读页 v1：上下滚动、章节标题、上一章 / 下一章、章节目录（底部抽屉，`DraggableScrollableSheet`）、
    字号（14–30）与行距（1.2–2.4）滑杆、阅读位置持久化并在下次打开时恢复。
  - `modoo_core` 新增 `detectEncoding` / `decodeText`（UTF-8 / UTF-16LE / UTF-16BE / GBK），
    检测永不抛异常，畸形字节降级为替换字符。
  - `ChapterRepository.replaceAll`：导入与重导入在单个事务内整体替换章节。
  - 新增 12 个中英 ARB 键（导入进度、导入成功、四类导入失败、删除确认、目录、阅读设置等）。
- **M0 骨架**：Dart pub workspace + 12 个包（`apps/mobile`、`packages/*` 10 个、`plugins/format_txt`），
  根 `pubspec.yaml` 单一 lockfile，`flutter pub get` 一次装齐。
- **`modoo_reader_engine`**：`ChapterSplitter`（中文章节标题识别、序章、无标题兜底）、
  `LayoutSpec` + FNV-1a `layoutHash`（排版字段任一变化即换缓存）、`TextLayoutEngine` 分页契约。
- **`modoo_domain`**：`Book` / `Chapter` / `ReadingProgress`（freezed），以及
  `BookRepository` / `ChapterRepository` / `ProgressRepository` 三个接口。
- **`modoo_data`**：Drift schema v1（`books` / `chapters` / `progress_rows`），导入、软删除、
  最近阅读排序、进度 `revision` 单调自增；迁移策略留好「只能追加」的骨架。
- **`modoo_plugin_api` 0.1.0**：`ModooPlugin` / `PluginManifest` / `PluginSetting`、
  `BookFormatParser` + `FileHandle` / `ImportSink`（不暴露文件路径）、`TtsEngine`、`SyncBackend`。
- **`modoo_plugin_host`**：版本约束解析（`^x.y.z`、比较符、`any`）、插件注册表与状态机
  （`active` / `incompatible` / `failed`），单个插件失败不影响其他插件。
- **`modoo_source_engine`**：书源规则模型与选择器表达式（`@css:` / `@json:` / `@regex:` / `@js:`），
  `@js:` 标记为需要沙箱。**不包含任何具体书源。**
- **`modoo_sync`**：进度冲突裁决（`revision` 优先、时间戳仅 tie-break）、WebDAV 路径规范。
- **`modoo_l10n`**：中英双语 ARB，`context.l10n` 扩展。
- **`modoo_ui`**：四套阅读主题（纸白 / 羊皮 / 夜间 / 纯黑）、间距与圆角 token、空态与分组标题组件。
- **`modoo_format_txt`**：TXT 格式插件（流式 UTF-8 解码、章节目录、按偏移取章、取消支持）。
- **App 壳**：启动时装配数据库与插件注册表；书架空态、主题切换两个页面。
- **工具链**：`tool/tasks.dart`（`gen` / `format` / `analyze` / `test` / `check` / `build:apk`）、
  `tool/gen_registry.dart`、`tool/new_plugin.dart`、`tool/check.ps1`。
- **CI**：`.github/workflows/ci.yml`，Ubuntu + Flutter 3.44.4，锁死「生成物已提交」。
- **文档**：开发计划、代码规范、GitHub 推送规则、`AGENTS.md`、ADR 索引与首批决策记录。

### Changed

- 命令面由 melos 改为 `dart run tool/tasks.dart <task>`：melos 8 要求 `cli_util ^0.5`，
  与 `drift_dev` 需要的 `cli_util ^0.4` 冲突，且 `--` 之后的参数在 Windows 容易被吞。
- 依赖固定为 `flutter_riverpod 3.3.x` + `riverpod_annotation 4.x` + `riverpod_generator >=4.0.3 <4.0.9`，
  上界是为了与 `freezed 3.x`（analyzer < 11）共存，升级时两个生成器必须同 PR 处理。
- Android 侧固定 `AGP 8.13.1` + `android.builtInKotlin=false` + `kotlin.incremental=false`：
  AGP 9 的 built-in Kotlin 与 `file_picker` / `flutter_plugin_android_lifecycle` 组合无法构建；
  Kotlin 2.3 在本机无法关闭增量缓存，故关掉增量编译（只影响插件模块的编译速度）。
- TXT 章节偏移改为「标题行之后」：章节正文不再包含标题行，阅读页不会把标题显示两遍。
  M1 之前导入的书记录仍按旧规则，重新导入即可。

### Known limitations

- 阅读页只有分页 + 点按翻页，**没有覆盖式翻页、双指捏合调字号、书签、选中复制**（M2 后续）。
- 排版扩展（页边距、段首缩进、对齐、字体选择）尚未开放，只有字号、行距、主题、翻页模式。
- 预分页（空闲帧预排下一章）未实现：首次进入某章会看到短暂加载。
- TXT 仅支持 UTF-8 / UTF-16 / GBK(GB2312 范围)；GB18030 四字节区与 Big5 尚未覆盖。
- 书架不支持重命名、封面、排序自定义；导入只接受 `.txt`（EPUB 在 M2 后续）。
- 数据库 schema v2 尚未发布，M1/M2 之前仍可调整；一旦发布 `v0.1.0`，迁移即冻结。
- 多选导入、文件夹扫描、自定义切章正则、阅读统计、全书搜索均未实现。
