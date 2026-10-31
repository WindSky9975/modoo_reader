# Changelog

本文件记录所有值得注意的变更。格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，
版本号遵循 [SemVer](https://semver.org/lang/zh-CN/)：`0.x` 阶段允许破坏性变更，但必须在条目里写明迁移方式。

分类固定为：`Added` / `Changed` / `Deprecated` / `Removed` / `Fixed` / `Security`。
用户可见的行为变化必须单独写一条，不能混在「重构」里。

---

## [Unreleased]

### Added

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

### Known limitations

- 只有书架空态与设置页，**没有导入流程与阅读页**（M1）。
- TXT 解析仅支持 UTF-8；GBK / UTF-16 在 M1 引入 `charset_converter` 后支持。
- 数据库 schema v1 尚未发布，M1 之前仍可调整；一旦发布 `v0.1.0`，迁移即冻结。
- 本机未安装 Android SDK，APK 构建路径尚未实机验证。
