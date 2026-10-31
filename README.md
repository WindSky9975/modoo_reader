# modoo_reader · 墨读

一个 **本地优先** 的开源中文小说阅读器。Flutter 编写，Android 为主，逐步覆盖桌面端；**不内置任何书源**，只做一个干净的阅读工具。

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Status](https://img.shields.io/badge/status-M0%20skeleton-yellow)

> 当前状态：**M0 骨架已完成**。monorepo、11 个包、App 壳、CI、工具脚本齐全，`dart run tool/tasks.dart check` 全绿。
> 还**没有**导入流程与阅读页 —— 这是 M1 的事。命令见 [开发](#开发)。

## 为什么做这个

主流阅读器要么闭源、要么夹带书城与广告、要么排版粗糙。这个项目只解决三件事：**本地书籍导入顺畅**、**中文排版好看**、**阅读界面安静**。

## 能力与进度

| 能力 | 说明 | 里程碑 | 状态 |
| --- | --- | --- | --- |
| 骨架 | monorepo、分层、插件契约、数据库、设计 token、CI | M0 | ✅ 已完成 |
| 本地导入 | TXT（含 GBK）、EPUB 2/3，CBZ / MOBI / PDF 后续 | M1–M2 | ⬜ |
| 阅读页 | 上下滚动、目录、进度恢复 | M1 | ⬜ |
| 中文排版 | 标点挤压、避头尾、自定义字距行距段距、分页 | M2 | ⬜ |
| 阅读体验 | 滚动与分页双模式、多种翻页动画、护眼主题 | M2 | ⬜ |
| 听书 | TTS 断句、语速、定时、后台播放 | M4 | ⬜ |
| 插件 | 编译期插件：格式解析、书源规则、TTS | M4 | ⬜ |
| 笔记搜索 | 划线批注、全文搜索、书摘导出 | M5 | ⬜ |
| 同步 | 仅 WebDAV，进度 / 书签 / 笔记 / 设置 | M5 | ⬜ |
| 多端 | Android → Windows/macOS/Linux → Web（v1.0 之后） | M3 / M5 / M6 | ⬜ |

已落地的基础设施：`modoo_core`（错误/日志/端口）、`modoo_domain`（模型与仓库接口）、
`modoo_data`（Drift schema v1）、`modoo_reader_engine`（切章 + 排版规格 + 分页契约）、
`modoo_plugin_api` / `modoo_plugin_host`（插件契约与注册表）、`modoo_source_engine`（书源规则模型）、
`modoo_sync`（冲突裁决与 WebDAV 路径）、`modoo_ui`（四套主题）、`modoo_l10n`（中英）、
`modoo_format_txt`（TXT 解析插件）。

不做：书城、推荐流、签到金币、广告、遥测上报、社交段评。

## 文档

- [开发计划](docs/DEVELOPMENT_PLAN.md) —— 需求矩阵、架构、里程碑、风险登记册
- [代码规范](docs/CODE_STYLE.md) —— 分层与依赖、命名、Riverpod / Drift / 插件规范、测试与提交规则
- [GitHub 推送规则](docs/GIT_WORKFLOW.md) —— 分支模型、分支保护、PR 与 squash、tag 与发版、常见 Git 报错处置
- [架构决策记录](docs/adr/README.md) —— 为什么是编译期插件、为什么只存字符偏移、为什么只支持 WebDAV
- [AGENTS.md](AGENTS.md) —— 给 AI 编码代理与新贡献者的操作手册（硬规则、任务配方、常见陷阱）
- [CONTRIBUTING.md](CONTRIBUTING.md) · [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) · [SECURITY.md](SECURITY.md)
- [THIRD_PARTY.md](THIRD_PARTY.md) · [CHANGELOG.md](CHANGELOG.md)

遇到冲突时的优先级：**代码规范 > AGENTS.md > GitHub 推送规则 > 计划**。

## 开发

环境要求：Flutter 3.44.4（stable）、Dart 3.12.2、JDK 17、Android SDK（`minSdk 24`，构建 APK 才需要）。

```bash
flutter pub get                      # 安装全部包依赖（仓库根执行一次）
dart run tool/tasks.dart gen         # 代码生成（模型 / 数据表 / ARB / 插件注册表）
dart run tool/tasks.dart check       # 提交前总检查：format + analyze + test
dart run tool/tasks.dart build:apk   # 构建 APK（需先装 Android SDK）
```

仓库是 **Dart pub workspace**，不是 melos：根 `pubspec.yaml` 的 `workspace:` 列出全部包，全仓只有一个 `pubspec.lock`。

## 参与贡献

先读 [CONTRIBUTING.md](CONTRIBUTING.md) 与 [docs/CODE_STYLE.md](docs/CODE_STYLE.md)。提交信息用 Conventional Commits，一个 PR 只做一件事且不超过 400 行。

**不接受**内置书源、抓取正版平台内容的 PR。安全问题请走私密渠道，见 [SECURITY.md](SECURITY.md)。

## 法律声明

本项目是**阅读工具**，不提供、不托管、不分发任何书籍内容，也不内置任何书源规则。请仅导入你合法拥有的书籍文件。因使用本项目产生的版权纠纷由使用者自行承担。

## 许可证

[MIT](LICENSE) © 2026 WindSky9975
