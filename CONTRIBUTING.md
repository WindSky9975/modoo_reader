# 参与贡献

先谢谢你愿意花时间。这个项目是单人起步的开源阅读器，**欢迎代码、文档、翻译、字体与排版建议**，也欢迎只是提一个「这里翻页卡了」的 issue。

在动手之前，请读完这一页 + [`docs/CODE_STYLE.md`](docs/CODE_STYLE.md) 里与你改动相关的章节。规则不多，但会被严格检查。

---

## 1. 先确认你要做的是什么

| 你想做的事 | 去哪 |
| --- | --- |
| 报 bug / 提需求 | GitHub Issue，用模板填写复现步骤与设备信息 |
| 改代码 | 先开 Issue 对齐范围，再开 PR（避免白写） |
| 写文档 / 翻译 | 直接 PR，无需提前对齐 |
| 新增格式解析、TTS、书源引擎能力 | **先开 Issue 讨论**，这类改动会影响 `plugin_api` 公共契约 |
| 内置书源、抓取正版平台内容 | ❌ 不接受，见 §7 |

不知道从哪开始？看 Issue 上的 `good first issue` 标签，或从下面这些低风险改动入手：
补充测试用例、修 lint、完善 ARB 翻译、改进错误文案。

## 2. 环境

| 组件 | 版本 |
| --- | --- |
| Flutter | 3.44.4（stable） |
| Dart | 3.12.2 |
| JDK | 17 |
| Android | `minSdk 24`、`compileSdk` 随 Flutter 默认 |
| 仓库布局 | Dart pub workspace（**不是** melos） |

```bash
flutter pub get                       # 在仓库根执行一次，装齐所有包
dart run tool/tasks.dart gen          # 生成代码（改模型/表/ARB/插件后必须重跑）
dart run tool/tasks.dart test         # 全部测试
dart run tool/tasks.dart check        # 提交前总检查：format + analyze + test
pwsh tool/check.ps1                   # Windows 上等价，另含 print 残留与生成物 diff 检查
```

**Android SDK 未装**时，除 `build:apk` 外的命令都能跑；构建 APK 前先 `flutter doctor` 全绿。

**Windows 上跑 `packages/data` 的测试**需要能找到 `sqlite3.dll`：把
`D:\Download\Scoop\apps\miniconda3\current\Library\bin` 之类含该 DLL 的目录加进 `PATH`，
或在根 `pubspec.yaml` 的 `hooks.user_defines.sqlite3` 里把 `source` 改成 `process` / 指定路径。

## 3. 分支、提交、PR

细节见 [`docs/GIT_WORKFLOW.md`](docs/GIT_WORKFLOW.md)，这里只列要点：

- **维护者**：仓库只有 `main` 一个分支，改动直接提交到 `main`，推之前 `dart run tool/tasks.dart check` 必须绿。
- **外部贡献者**：fork 后在自己仓库开分支，向 `main` 提 PR；分支名 `feat/<slug>`、`fix/<slug>`、`docs/<slug>`。
- commit：`<type>(<scope>): <祈使句英文，≤72 字符>`，正文写「为什么」。
- 任何人都不 force-push `main`、不删 `main`、不动已发布的 tag。
- PR ≤ 400 行、只做一件事、描述里写清「为什么 / 改了什么 / 怎么验 / 风险与回滚」。
- PR 合并只用 squash；CI 不绿不合并。

## 4. 完成定义（DoD）

1. `dart run tool/tasks.dart check` 全绿。
2. 新逻辑有测试；修 bug 有回归测试（先失败、后通过）。
3. 没有新增 lint 告警，没有无理由的 `// ignore`（必须带规则名 + 原因 + issue 链接）。
4. 改了模型 / 表 / ARB → 生成物已重跑并一起提交。
5. 用户可见变更 → `CHANGELOG.md` 的 `Unreleased` 加一条。
6. 公共 API 变更 → 英文 dartdoc；架构变更 → `docs/adr/` 新增一条。
7. 新增依赖 → `THIRD_PARTY.md` 登记，PR 里回答「许可证 / 维护 / 体积 / 替代」四问。

## 5. 代码规矩（最容易踩的三条）

- **依赖方向单向**：`plugins/*` 只能依赖 `modoo_plugin_api`；`reader` 不碰 `data`；共享包不准 `import 'dart:io'`。
  唯一允许 import `plugins/*` 的是生成文件 `apps/mobile/lib/src/plugins/registry.g.dart`。
- **生成文件不手改**：`*.g.dart`、`*.freezed.dart`、`packages/l10n/lib/src/generated/` 全部由工具生成。
- **代码注释与 commit 用英文，文档用中文，界面文案一律进 ARB**，包括错误提示与语义标签。

完整规则见 [`docs/CODE_STYLE.md`](docs/CODE_STYLE.md)；常见陷阱见 [`AGENTS.md`](AGENTS.md) §7。

## 6. 测试与性能

- 纯 Dart 包用 `dart test`，Flutter 包用 `flutter test`；由 `tool/tasks.dart` 自动选择。
- Golden 测试只在 Linux CI 生成与比对，**本地 Windows 跑 golden 失败不代表你改坏了**。
- 分页链路的改动必须验证：单章分页 < 300ms、命中缓存 < 20ms、改字号重排 < 1.5s，并在 PR 里贴数据。

## 7. 内容与法律底线

本项目**只是阅读工具**：

- 不提供、不托管、不分发任何书籍内容；
- **不内置任何书源**，也不接受把正版平台抓取规则提交进仓库的 PR；
- 测试用的书籍样本必须是公版或你自己创作的短文本，且体积尽量小；
- 不要提交密钥、签名文件、`.env`、真实设备信息。

违反上述任一条的 PR 会被直接关闭，不解释。

## 8. 沟通

- Issue / PR 里用中文或英文都可以，说清楚就行。
- 讨论技术取舍时请给出**约束与代价**，而不是只给结论。
- 维护者是单人兼职，响应可能慢，但不会忽略。

行为准则见 [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md)，安全问题见 [`SECURITY.md`](SECURITY.md)。
