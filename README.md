# modoo_reader · 墨读

一个 **本地优先** 的开源中文小说阅读器。Flutter 编写，Android 为主，逐步覆盖桌面端；**不内置任何书源**，只做一个干净的阅读工具。

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Status](https://img.shields.io/badge/status-pre--M0-lightgrey)

> 当前状态：**只有文档，没有代码**。`apps/`、`packages/`、`melos.yaml` 尚未创建，M0 建仓中。

## 为什么做这个

主流阅读器要么闭源、要么夹带书城与广告、要么排版粗糙。这个项目只解决三件事：**本地书籍导入顺畅**、**中文排版好看**、**阅读界面安静**。

## 计划中的能力

| 能力 | 说明 | 里程碑 |
| --- | --- | --- |
| 本地导入 | TXT（含 GBK）、EPUB 2/3，CBZ / MOBI / PDF 后续 | M1–M2 |
| 中文排版 | 标点挤压、避头尾、自定义字距行距段距、分页 | M2 |
| 阅读体验 | 滚动与分页双模式、多种翻页动画、护眼主题 | M2 |
| 笔记搜索 | 划线批注、全文搜索、书摘导出 | M5 |
| 听书 | TTS 断句、语速、定时、后台播放 | M4 |
| 同步 | 仅 WebDAV，进度 / 书签 / 笔记 / 设置 | M5 |
| 插件 | 编译期插件：格式解析、书源规则、TTS | M4 |
| 多端 | Android → Windows/macOS/Linux → Web（v1.0 之后） | M3 / M5 / M6 |

不做：书城、推荐流、签到金币、广告、遥测上报、社交段评。

## 文档

- [开发计划](docs/DEVELOPMENT_PLAN.md) —— 需求矩阵、架构、里程碑、风险登记册
- [代码规范](docs/CODE_STYLE.md) —— 分层与依赖、命名、Riverpod / Drift / 插件规范、测试与提交规则
- [GitHub 推送规则](docs/GIT_WORKFLOW.md) —— 分支模型、分支保护、PR 与 squash、tag 与发版、常见 Git 报错处置
- [AGENTS.md](AGENTS.md) —— 给 AI 编码代理与新贡献者的操作手册（硬规则、任务配方、常见陷阱）

遇到冲突时的优先级：**代码规范 > AGENTS.md > 计划**。

## 开发

> M0 完成后可用。现在还没有 `melos.yaml`，下面的命令会失败。

```bash
melos bootstrap      # 安装全部包依赖
melos run gen        # 代码生成（模型 / 数据表 / ARB / 插件注册表）
melos run check      # 提交前总检查：format + analyze + test
melos run build:apk  # 构建 release APK
```

环境要求：Flutter（stable，Dart 3.x）、JDK 17、Android SDK（`minSdk 24`）。

## 参与贡献

先读 [docs/CODE_STYLE.md](docs/CODE_STYLE.md) 与 [AGENTS.md](AGENTS.md)。提交信息用 Conventional Commits，一个 PR 只做一件事且不超过 400 行。

`CONTRIBUTING.md`、`CODE_OF_CONDUCT.md`、`SECURITY.md` 在 M0 补齐。

## 法律声明

本项目是**阅读工具**，不提供、不托管、不分发任何书籍内容，也不内置任何书源规则。请仅导入你合法拥有的书籍文件。因使用本项目产生的版权纠纷由使用者自行承担。

## 许可证

[MIT](LICENSE) © 2026 WindSky9975
