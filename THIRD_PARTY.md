# 第三方依赖与许可证

本项目以 **MIT** 发布，但会链接/打包第三方代码。本文件列出全部**直接依赖**及其许可证，
用于合规审查与升级时的许可证回归。传递依赖的许可证由 `dart pub deps` 决定，见文末检查方法。

## 许可证政策

| 许可证 | 结论 | 说明 |
| --- | --- | --- |
| MIT / BSD-2 / BSD-3 / Apache-2.0 / ISC / Zlib | ✅ 允许 | Apache-2.0 需在 `NOTICE` 保留归属 |
| MPL-2.0（不改其源码） | ✅ 允许 | 文件级弱 copyleft：只约束被 MPL 覆盖的文件本身，不改即可；一旦 patch，那个文件必须继续 MPL |
| LGPL（动态链接、不改源码） | ⚠️ 需评审 | 移动端静态链接场景基本等同 GPL，默认拒绝 |
| GPL-2.0 / GPL-3.0 / AGPL-3.0 | ❌ 禁止 | 与 MIT 分发不兼容 |
| 无许可证 / 自定义「仅限非商业」条款 | ❌ 禁止 | 无法确认授权范围 |
| 字体（OFL-1.1 等） | ✅ 允许 | 需在本文件登记字体名与来源，且不打包进 APK（ADR-0007） |

新增依赖必须在 PR 里回答四问（许可证 / 维护状态 / 体积 / 替代方案），并在此表登记。

## 运行时依赖（进入 App）

| 包 | 版本 | 许可证 | 用途 |
| --- | --- | --- | --- |
| `flutter` / `flutter_localizations` | 3.44.4 | BSD-3-Clause | UI 框架与本地化代理 |
| `flutter_riverpod` | 3.3.2 | MIT | 状态管理与依赖注入 |
| `riverpod_annotation` | 4.0.3 | MIT | provider 注解（配合 codegen） |
| `path` | 1.9.1 | BSD-3-Clause | 路径拼接（禁止手拼 `\`） |
| `path_provider` | 2.1.6 | BSD-3-Clause | 应用私有目录 |
| `drift` | 2.34.4 | MIT | SQLite ORM 与响应式查询 |
| `sqlite3` | 3.5.2 | MIT | SQLite 的 Dart 绑定（内嵌 SQLite，公有领域） |
| `sqlite3_flutter_libs` | 0.5.42 | MIT | Android/iOS 上的 SQLite 原生库 |
| `freezed_annotation` | 3.1.0 | MIT | 不可变数据模型注解 |
| `intl` | 0.20.2 | BSD-3-Clause | 日期/数字格式化（由 gen-l10n 使用） |
| `cupertino_icons` | 1.0.8 | MIT | iOS 风格图标（Flutter 模板自带） |
| `enough_convert` | 1.7.1 | **MPL-2.0** | 纯 Dart 的 GBK 解码（ADR-0011）；不修改其源码 |
| `file_picker` | 11.0.3 | MIT | 系统文件选择器（导入 TXT） |
| `flutter_plugin_android_lifecycle` | 2.0.35 | BSD-3-Clause | `file_picker` 的 Android 传递依赖 |

## 构建/开发期依赖（不进入运行时产物）

| 包 | 版本 | 许可证 | 用途 |
| --- | --- | --- | --- |
| `riverpod_generator` | 4.0.4 | MIT | 生成 `*.g.dart` provider |
| `drift_dev` | 2.34.0 | MIT | 生成数据库代码 |
| `freezed` | 3.2.6-dev.1 | MIT | 生成值语义类 |
| `build_runner` | 2.15.1 | BSD-3-Clause | 代码生成调度 |
| `analyzer` | 12.1.0 | BSD-3-Clause | 静态分析（生成器依赖） |
| `json_annotation` / `source_gen` 等 | 见 `pubspec.lock` | BSD-3-Clause / MIT | 生成器链路 |
| `test` | 1.31.0 | BSD-3-Clause | 单元测试 |
| `flutter_lints` / `lints` | 6.0.0 / 6.1.0 | BSD-3-Clause | lint 基线 |
| `yaml` | 3.1.4 | BSD-3-Clause | 工具脚本读取根 pubspec |
| `path`（dev） | 1.9.1 | BSD-3-Clause | 工具脚本路径处理 |

## 原生 / 二进制组件

| 组件 | 版本 | 许可证 | 说明 |
| --- | --- | --- | --- |
| SQLite | 3.49.x（随 `sqlite3_flutter_libs`） | Public Domain | 数据库引擎 |
| AndroidX / Material Components | 随 Flutter 插件 | Apache-2.0 | Android 端传递依赖，见 `apps/mobile/android` 生成的依赖树 |

**字体**：M0 不打包任何字体文件，使用系统字体（ADR-0007）。若将来引入内置或可下载字体，
必须在本节登记字体名、来源 URL、许可证全文位置。

## 检查方法

```bash
# 1) 所有解析出的版本
dart pub deps --style=compact

# 2) 逐包核对许可证（pub 缓存里的 LICENSE 文件）
dart run tool/tasks.dart licenses     # M1 计划提供，当前请手工核对下方路径
%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\<包名>-<版本>\LICENSE

# 3) 打包产物里是否混入新原生库
unzip -l build/app/outputs/flutter-apk/app-release.apk | Select-String "lib/"
```

升级依赖后必须同步更新本文件的版本号列；CI 在 M1 引入许可证扫描（`tool/tasks.dart licenses`）后，
版本不一致会直接失败。

## 已知许可证注意事项

- `intl` 的 BSD-3 条款要求保留版权声明；发布页与 App 内「关于」页需提供本文件的可达链接（M3 实现）。
- Apache-2.0 的 AndroidX/Material 依赖要求保留 `NOTICE`；Flutter 构建会自动合并到 APK，
  但对外发布页仍需列出。
- 本项目**没有**任何 GPL/AGPL 依赖；若未来某插件需要，只能以独立进程/可选下载方式提供，
  且不得进入主 AAB。
- `enough_convert` 是 MPL-2.0：我们只在运行时调用它、不修改其文件。发布 AAB 时按 MPL 要求
  提供其源码位置（pub.dev 页面 + `pubspec.lock` 里的版本与 sha256 已足以定位）。若将来要
  patch 它，必须把改动后的文件单独以 MPL-2.0 发布，或换成本仓库自带的 GBK 映射表。

---

最后更新：2026-10-31（M1 导入链路：新增 `enough_convert` / `file_picker`，对应 `pubspec.lock`）。
