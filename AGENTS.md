# AGENTS.md

> 给在本仓库工作的 AI 编码代理。人类贡献者请看 [docs/CODE_STYLE.md](docs/CODE_STYLE.md) 与 [CONTRIBUTING.md](CONTRIBUTING.md)。
> 本文件是**操作手册**，不是需求文档。需求与排期见 [docs/DEVELOPMENT_PLAN.md](docs/DEVELOPMENT_PLAN.md)。

---

## 0. 一句话

`modoo_reader` 是一个 **Flutter 写的本地优先开源小说阅读器**（MIT），核心是中文排版分页引擎，插件化支持格式解析、书源、TTS，同步只用 WebDAV，**不内置任何书源**。

## 1. 当前阶段（先看这里）

| 项 | 状态 |
| --- | --- |
| 阶段 | **M0 骨架已落地**：pub workspace monorepo、12 个包（`apps/mobile` + 10 个 `packages/*` + `plugins/format_txt`）、App 壳、CI、工具脚本齐全，`check` 全绿 |
| 可跑 | `flutter pub get`、`dart run tool/tasks.dart {gen,analyze,test,check}`、`pwsh tool/check.ps1` |
| 还不能跑 | APK 构建（本机缺 Android SDK）、`docs/plugin-sdk/`（M4 才有内容） |
| 未完成 | M1 功能：文件选择与导入、阅读页、分页渲染；`docs/plugin-sdk/` 与正式签名 |

**M0 只是骨架**：书籍导入、阅读页、分页渲染都还没有，`apps/mobile` 只有书架空态与主题切换两个页面。写功能前后都要确认自己在哪个里程碑（[docs/DEVELOPMENT_PLAN.md](docs/DEVELOPMENT_PLAN.md) §5）。

## 2. 必读顺序

1. 本文件（硬规则与配方）
2. [docs/CODE_STYLE.md](docs/CODE_STYLE.md)（写代码时的判据）
3. [docs/DEVELOPMENT_PLAN.md](docs/DEVELOPMENT_PLAN.md) §2 需求矩阵 + §5 里程碑（确认你的任务属于哪一段）
4. [docs/GIT_WORKFLOW.md](docs/GIT_WORKFLOW.md)（要 push / 开 PR / 发版时必读）

冲突时：**CODE_STYLE > 本文件 > GIT_WORKFLOW > 计划**。计划描述目标，规范描述做法；做法冲突以规范为准。

---

## 3. 环境与命令

### 3.1 本机环境（2026-10-31 实测）

| 组件 | 状态 |
| --- | --- |
| Flutter / Dart | ✅ `D:\Download\Scoop\apps\flutter\current` |
| Git / JDK 17 / Gradle | ✅ |
| Android SDK（adb / platform-tools） | ❌ **未安装**，`ANDROID_HOME` 未设置 |

首次构建 Android 前必须先装 SDK 并 `flutter doctor` 全绿，否则 APK 相关任务无法验证。

### 3.2 命令（在仓库根执行）

| 目的 | 命令 |
| --- | --- |
| 装依赖 | `flutter pub get` |
| 生成代码（改模型/表/ARB/插件后必跑） | `dart run tool/tasks.dart gen`（含 `gen-registry`） |
| 只重生成插件注册表 | `dart run tool/tasks.dart gen:registry` |
| 格式化 | `dart run tool/tasks.dart format` |
| 静态分析 | `dart run tool/tasks.dart analyze` |
| 全部测试 | `dart run tool/tasks.dart test` |
| **提交前总检查** | `dart run tool/tasks.dart check`（等价脚本 `pwsh tool/check.ps1`） |
| 快速核心测试 | `dart run tool/tasks.dart test --scope core,domain,reader,plugin_api,plugin_host,data` |
| 构建 APK | `dart run tool/tasks.dart build:apk` |
| 新建插件 | `dart run tool/new_plugin.dart --name format_fb2` |

从**仓库根目录**执行。所有任务都是 `dart run tool/tasks.dart <task>`；带参数的命令直接调用具体脚本（`dart run tool/new_plugin.dart --name x`），不要写成 `melos run xxx -- --flag` 那种形式 —— Windows 上 `--` 之后的参数很容易被吞掉。

### 3.3 平台注意

- 仓库统一 **LF** 行尾（`.gitattributes` 里 `* text=auto eol=lf`）。
- 路径拼接用 `p.join` / `path` 包，不要手拼 `\`。
- Golden 测试只在 Linux CI 生成与比对；**本地 Windows 跑 golden 会失败，这不是你的改动坏了**。

---

## 4. 代码地图

| 你想改 | 去哪里 |
| --- | --- |
| 启动流程、路由、插件装配 | `apps/mobile/lib/src/` |
| 分页算法、章节切分、翻页动画 | `packages/reader/lib/src/` |
| 数据库表、DAO、迁移 | `packages/data/lib/src/` |
| 设计 token、主题、通用组件 | `packages/ui/lib/src/` |
| 插件契约（能力接口） | `packages/plugin_api/lib/` |
| 插件注册表、生命周期 | `packages/plugin_host/lib/` |
| 具体格式解析 | `plugins/format_*/lib/` |
| 书源 DSL、抓取、JS 沙箱 | `packages/source_engine/lib/` |
| WebDAV 同步 | `packages/sync/lib/` |
| 中文文案 | `packages/l10n/lib/l10n/*.arb` |
| 分层 / 命名 / 测试规则 | `docs/CODE_STYLE.md` |
| 需求、里程碑、风险 | `docs/DEVELOPMENT_PLAN.md` |
| 推送、分支、PR、发版、Git 报错 | `docs/GIT_WORKFLOW.md` |
| 架构决策 | `docs/adr/`（新增时按 `NNNN-title.md`） |

**唯一允许 import `plugins/*` 的文件**：`apps/mobile/lib/src/plugins/registry.g.dart`。这个文件由 `dart run tool/gen_registry.dart` 生成，不要手改。

---

## 5. 不可协商的硬规则

以下 10 条不因"这次比较特殊"而破例。破了 CI 会拦或 review 会打回。

1. **依赖方向单向**：`plugin_api ← plugins`、`core ← 所有业务包`、`reader` 不碰 `data`、`plugins` 不碰 `core/ui/data`。违反即架构事故。
2. **生成文件不手改**：`*.g.dart` / `*.freezed.dart` / `lib/generated/` 只由 `dart run tool/tasks.dart gen` 产生。改模型后必须重跑并把生成物一起提交。
3. **已发布的数据库迁移永久冻结**：只能追加新分支，不能改历史 `onUpgrade`。
4. **不新增依赖除非说明理由**：许可证、维护状态、体积、替代方案四问，写进 PR。GPL/AGPL 一律拒绝。
5. **不弱化 lint**：不加 `analysis_options` 例外，不加无理由的 `// ignore`（必须带规则名 + 原因 + issue）。全仓唯一豁免是附录 A 的 `invalid_annotation_target: ignore`，理由写在原地。
6. **用户可见文案必须走 l10n**：包括错误提示、空态、`Semantics` 标签。
7. **阅读热路径零阻塞**：翻页链路上禁止 I/O、禁止大对象分配、禁止同步 DB 查询。
8. **插件必须纯**：无 UI、无 `BuildContext`、无 `dart:io`、无全局可变状态。
9. **不内置任何书源、不抓取正版内容**：这是项目法律底线，看到此类 PR 直接关闭。
10. **提交前 `dart run tool/tasks.dart check` 必须绿**。

---

## 6. 任务配方

每个配方都是「改哪里 → 改什么 → 验证什么」。照着做，不要自由发挥。

### 6.1 新增一个格式插件（例：FB2）

```
1. dart run tool/new_plugin.dart --name format_fb2
2. 在 plugins/format_fb2/lib/ 实现 BookFormatParser（只依赖 modoo_plugin_api）
3. manifest 填 id: modoo.format.fb2、version、sdkConstraint、capabilities；name 只写英文兜底，中文名加到 ARB
4. test/ 写四类用例：正常 / 损坏 / 超大 / 边界编码，全部纯 Dart 可跑
5. 跑 dart run tool/tasks.dart gen:registry 重新生成 buildPluginList()（会自动包含新插件）
6. 跑 dart run tool/tasks.dart test && dart run tool/tasks.dart analyze
```

**不要**：改 `plugin_api` 加能力（除非任务明确要求，那就先写 ADR）、在插件里 import `modoo_core`、在插件里弹 UI。

### 6.2 新增一个页面 / feature

```
1. 在 apps/mobile/lib/src/features/<name>/ 建目录
2. <name>_page.dart 只放 UI，逻辑放 controllers/
3. provider 用 @riverpod 生成，autoDispose 默认
4. 路由常量加到 routes.dart，不要在其他地方写字符串路径
5. 文案加到 ARB（zh + en 占位）
6. widget 测试覆盖：空态、加载态、错误态
```

判据：删掉这个 feature 不需要动其他 feature 的文件。需要动 → 逻辑应该下沉到 `packages/`。

### 6.3 新增数据表 + 迁移

```
1. packages/data/lib/src/tables/ 加表类（复数名，snake_case 列，主键 + 时间戳）
2. 在 AppDatabase 的 tables 列表注册
3. schemaVersion + 1，在 onUpgrade 追加新分支（不要动历史分支）
4. test/migrations/ 放旧版本 DB 样本，断言迁移后数据正确
5. dart run tool/tasks.dart gen
6. dart run tool/tasks.dart test --scope core,domain,reader,plugin_api,plugin_host,data
```

**不要**：改已有列的语义、删列、重命名列而不写迁移、在 DAO 外拼 SQL。

### 6.4 新增 provider

```dart
// features/reader/controllers/reader_controller.dart
@riverpod
class ReaderController extends _$ReaderController {
  @override
  Future<ReaderState> build(String bookId) async { ... }
}
```

- `build()` 里只读依赖，不做副作用。
- `await` 之后用 `if (!ref.mounted) return;` 再碰 `ref`。
- 测试用 `ProviderScope(overrides:)`，不要 mock 全局。

### 6.5 新增文案

```
1. packages/l10n/lib/l10n/app_zh.arb 加 key（模板文件）
2. app_en.arb 加对应英文（占位也要有，否则 CI 失败）
3. dart run tool/tasks.dart gen
4. 用 context.l10n.xxx 引用；带参数用占位符，不要字符串拼接
```

### 6.6 改动分页 / 排版

这是全项目最敏感的区域。改之前：

1. 读 `docs/DEVELOPMENT_PLAN.md` §3.5（分页算法、layoutHash、页表缓存）。
2. 明确你的改动是否改变 `layoutHash` 的组成 —— 改了就等于让所有缓存失效，必须在 PR 里说明。
3. 必须验证三条：单章分页 < 300ms、命中缓存 < 20ms、改字号后重排 < 1.5s。
4. 必须有单元测试覆盖边界：空章节、超长段落（> 1 万字无换行）、含 emoji/生僻字、段落高度恰好等于页高。
5. 不要碰 `page_layouts` 的表结构，除非同时写迁移。

### 6.7 书源引擎加一种选择器

```
1. packages/source_engine/lib/src/selectors/ 加实现（css / json / regex / js 之外的新前缀）
2. 选择器必须是纯函数：输入响应体，输出字符串或列表
3. 加沙箱相关的限制检查（长度上限、超时）
4. 测试覆盖：正常命中、空结果、畸形 HTML、超长响应
5. 更新 docs/plugin-sdk/ 里的选择器语法说明
```

---

## 7. 常见陷阱

| 陷阱 | 症状 | 正确做法 |
| --- | --- | --- |
| 手改 `*.g.dart` | 下次 `gen` 后被覆盖，改动离奇消失 | 改源模型后重跑 `dart run tool/tasks.dart gen` |
| 忘跑 `gen` 就提交 | CI 报「生成物有未提交 diff」 | 提交前固定执行 `dart run tool/tasks.dart gen` |
| `dart:io` 进了共享包 | Web 端构建失败（未来） | 用 `FileSystemPort`，只在移动/桌面实现里 import |
| `ref` 跨 async gap | 偶发 `StateError: disposed` | `if (!ref.mounted) return;` |
| `context` 跨 async gap | `use_build_context_synchronously` 警告 | `if (!context.mounted) return;` |
| 主线程跑大正则 | 导入时 UI 卡死、ANR | `TaskRunner.run(() => ...)` |
| 在 `build()` 里 `ref.read(...).method()` | 重建即触发副作用，行为随机 | 移到 controller 的 `build` 或事件回调 |
| 改了已发布的迁移 | 升级用户数据库崩 | 追加新迁移，历史分支只读 |
| 改 `layoutHash` 组成却不说明 | 用户首次翻页全量重排，体感变慢 | PR 里标注，并把重排耗时测出来 |
| 用 `print` 调试完忘了删 | 日志泄露 + `avoid_print` 报错 | 用 `logger.debug`，提交前 grep |
| Golden 本地跑失败 | 以为改坏了 | Windows 与 Linux 渲染不同，只信 CI |
| 在 PowerShell 里参数被吞 | `dart run tool/tasks.dart xxx -- --flag` 不生效 | 改用 `dart run tool/xxx.dart --flag` |
| 插件里 import `modoo_core` | 依赖倒置，插件无法独立发布 | 只用 `plugin_api` 提供的能力 |
| 中文标点硬编码进 UI | 换语言后标点错乱 | 文案进 ARB，标点跟随语言 |

---

## 8. 完成定义（DoD）

一个改动算完成，必须同时满足：

1. `dart run tool/tasks.dart check` 全绿（format + analyze + test）。
2. 新逻辑有测试；修 bug 有回归测试（先失败后通过）。
3. 没有新增 lint 告警，没有无理由的 `// ignore`。
4. 改了模型/表/ARB → 生成物已重跑并提交。
5. 用户可见变更 → `CHANGELOG.md` 加一条（`Unreleased` 段）。
6. 公共 API 变更 → 英文 dartdoc；架构变更 → ADR。
7. PR ≤ 400 行，只做一件事。
8. PR 描述写清「为什么」，不是「改了哪些文件」。

**自检命令**（提交前固定跑）：

```bash
dart run tool/tasks.dart check          # format + analyze + test
pwsh tool/check.ps1      # Windows 上同上，另含 print 残留扫描与生成物 diff 检查
```

## 9. 禁止清单

- ❌ 直接 push / force-push 到 `main`
- ❌ 提交密钥、签名文件、`.env`、真实书源、受版权保护的书籍样本
- ❌ 顺手重构无关代码（单独开 PR）
- ❌ 删除或跳过失败的测试来"让 CI 变绿"
- ❌ 修改 `docs/DEVELOPMENT_PLAN.md` 的里程碑与排期（除非用户明确要求）
- ❌ 引入遥测 / 崩溃上报 SDK（除非用户明确要求且默认关闭）
- ❌ 在插件里内置书源、抓取正版平台内容
- ❌ 用 `dynamic`、裸 `!`、`catch (e)` 糊过类型检查
- ❌ 一次提交混合「功能 + 格式化 + 重构」

## 10. 文档同步矩阵

改动后必须同步更新对应文档，否则视为未完成：

| 你改了什么 | 必须更新 |
| --- | --- |
| 新增/删除包 | `CODE_STYLE.md` §3.1 映射表、根 `pubspec.yaml` 的 `workspace:`、CI |
| 改变分层或依赖方向 | `CODE_STYLE.md` §3.2 + 新 ADR |
| 新增插件能力接口 | `plugin_api` dartdoc + ADR + SDK 文档 |
| 数据库语义变化 | `DEVELOPMENT_PLAN.md` §3.10 + 迁移测试 |
| 里程碑范围变化 | `DEVELOPMENT_PLAN.md` §5（需用户确认） |
| 新增依赖 | `THIRD_PARTY.md` + PR 说明四问 |
| 用户可见行为变化 | `CHANGELOG.md` |
| 新的命令/脚本 | 本文件 §3.2 + `tool/tasks.dart` 的 `_usage` |
| 分支模型 / 推送 / 发版流程变化 | `GIT_WORKFLOW.md` + 仓库 Settings 同步调整 |

## 11. 何时停下来提问

遇到以下情况**不要自行决定**，先问：

- 需要新增第三方依赖
- 需要改 `plugin_api` 的公共契约（破坏性）
- 需要改数据库已有列语义或删除列
- 需要调整里程碑、砍功能、改变已确认的决策（见计划 §0.3 的 4 条）
- 需求本身有歧义（例如"段评"到底做不做社交）
- 发现规范与实现冲突，且两种改法都有代价

可以直接决定并继续的：内部实现细节、私有 API 命名、局部重构（不跨包）、测试组织方式。

## 12. 提交信息

```
<type>(<scope>): <祈使句英文，≤72 字符>

为什么这么改（英文或中文均可，说明动机与取舍）
```

- type：`feat` `fix` `docs` `refactor` `perf` `test` `chore` `build` `ci`
- scope 见 `CODE_STYLE.md` §14.1
- 一个 commit 一件事；不允许 `wip`、`fix bug`、`update` 这类信息

## 13. 参考实现线索

写代码卡住时可以看这些（都是公开项目，注意只学结构不抄代码）：

- 分层与插件：`very_good_cli` 的 monorepo 模板、`flame` 等 pub workspace 仓库的组织方式
- 书源规则 DSL：legado（阅读）的规则文档，本项目做了减法
- 分页与阅读器：各开源阅读器的分页实现差异很大，**以本项目计划 §3.5 为准**，不要照搬

---

## 变更记录

| 版本 | 日期 | 变更 |
| --- | --- | --- |
| v1.0 | 2026-10-31 | 首版：阶段说明、命令、代码地图、10 条硬规则、7 个任务配方、陷阱与 DoD |
| v1.1 | 2026-10-31 | 与 CODE_STYLE v1.1 对齐：新建插件改 `dart run tool/new_plugin.dart`、注册表改 `buildPluginRegistry()` + `dart run tool/tasks.dart gen:registry`、硬规则 1 限定 `core ← 所有业务包`、自检命令改 `dart run tool/tasks.dart check` / `tool/check.ps1`、补 lint 唯一豁免说明 |
| v1.2 | 2026-10-31 | 新增 `docs/GIT_WORKFLOW.md`（推送、分支、PR、发版）；必读顺序与冲突优先级加入该文档；代码地图与文档同步矩阵补行 |
| v1.3 | 2026-10-31 | M0 落地后回填：阶段改为「M0 骨架已落地，12 个包」、命令面改 `dart run tool/tasks.dart`（弃用 melos）、注册表路径改 `registry.g.dart` / `buildPluginList()`、首行指向 `CONTRIBUTING.md`、文档同步矩阵把 `melos.yaml` 换成根 `pubspec.yaml` |
