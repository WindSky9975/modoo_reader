# ADR-0001：编译期 Dart 插件 + 注册表，而非运行时热插拔

- 状态：已接受
- 日期：2026-10-31
- 相关：`docs/DEVELOPMENT_PLAN.md` §3.4、`docs/CODE_STYLE.md` §9、`packages/plugin_api`、`packages/plugin_host`

## 背景

需求方要求「插件驱动一切」：格式解析、书源、TTS 都要能扩展。可选路线有两条：
运行时动态加载（用户下载插件包即可生效），或编译期插件（插件是 Dart 包，随 App 一起构建）。

Flutter 的现实是：**AOT 编译后无法在运行时加载新的 Dart 代码**。要在运行时执行外部逻辑，
只能内嵌 JS 引擎或引入解释器 —— 两者都会把启动成本、包体积、安全边界一起拉高。

## 决策

插件是**编译期 Dart package**，位于 `plugins/<name>`，只依赖 `modoo_plugin_api`，
在公共出口导出顶层函数 `ModooPlugin createPlugin()`。注册表由 `tool/gen_registry.dart` 扫描生成
（`apps/mobile/lib/src/plugins/registry.g.dart` 里的 `buildPluginList()`），App 启动时交给
`PluginRegistry` 初始化。

## 后果

**正面**

- 类型安全：插件与宿主在编译期对齐接口，不存在「字段改名后线上崩」。
- 可测试：每个插件都是普通 Dart 包，`dart test` 即可覆盖，无需模拟宿主。
- 安全面小：没有运行时加载器，也就没有「加载恶意 Dart 代码」这条攻击路径。
- 性能：AOT 内联，插件调用没有跨边界开销。

**负面**

- 用户装新插件必须换一个 App 构建产物（多渠道构建 / 每插件一个 flavor 是后续工作）。
- 插件与宿主的 `plugin_api` 版本强耦合，接口只能加、不能随意删（SemVer + `sdkConstraint` 校验缓解）。
- 插件作者无法独立发版；测试基线必须与宿主对齐。

## 替代方案

| 方案 | 为什么不选 |
| --- | --- |
| 运行时下载插件包（Dart Kernel） | Flutter AOT 不支持动态加载 Dart；JIT 模式只在 debug 可用 |
| 内嵌 JS 引擎跑插件逻辑 | 包体积 +10MB 起，性能与安全边界都差；JS 只保留给书源规则（ADR-0003） |
| 只做内部接口、不对外开放 | 与「插件驱动一切」的产品目标冲突 |

## 复审条件

Flutter 官方支持运行时加载 Dart 代码，或插件生态需要「用户自助安装」且维护成本可接受时。
