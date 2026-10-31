# modoo_reader 代码规范

| 项 | 内容 |
| --- | --- |
| 版本 | v1.0 |
| 生效日期 | 2026-10-31（M0 起强制执行） |
| 适用范围 | 仓库内全部 Dart / Flutter / YAML / Markdown |
| 关联文档 | [开发计划](DEVELOPMENT_PLAN.md) · [AGENTS.md](../AGENTS.md) |
| 维护者 | 项目维护者；修改需 PR + 说明理由 |

---

## 1. 总则

### 1.1 规范的优先级

冲突时按以下顺序裁决，**不要自己发明第三套规则**：

```
编译器 / analyzer / lint  →  本文档  →  现有同类代码的写法  →  个人偏好
```

也就是说：lint 报错就是错，不需要讨论；本文档没写的，跟着同目录最相似的代码写；两者都没有，按 Dart 官方 Effective Dart 处理。

### 1.2 破例流程

任何一条规则都可以破，但必须留下证据：

```dart
// ignore: avoid_print — 插件调试面板需要输出到 adb logcat，见 #412
print(debugOutput);
```

要求三件事全有：**具体的规则名**、**一句为什么**、**issue 编号或可追溯的上下文**。三者缺一，review 时打回。

禁止使用文件级 `// ignore_for_file:`，除非是生成文件或测试替身这类整文件性质特殊的情况。

### 1.3 语言约定

| 场景 | 语言 | 理由 |
| --- | --- | --- |
| 代码注释、dartdoc | **英文** | 开源项目里所有读者都能看懂；dartdoc 会发布到 pub.dev |
| `docs/`、README、PR 描述、issue | **中文** | 主要作者与用户是中文使用者 |
| commit message | **英文** | 与 Conventional Commits 工具链一致 |
| 用户可见文案 | **ARB 文件** | 禁止硬编码，见 §6.3 |
| 标识符 | **英文** | 不允许拼音（`shujia` ❌ → `bookshelf` ✅） |

拼音例外：中文专有概念无法翻译时（如 `zhangjie` 没有，用 `chapter`）。术语表在 `docs/DEVELOPMENT_PLAN.md` 附录 A。

### 1.4 底线

**CI 是唯一裁判。** 本地觉得"应该能过"不算过；`dart run tool/tasks.dart check` 绿灯才算完成。详见 §2.3。

---

## 2. 工具链与自动化

### 2.1 必装与必配

| 工具 | 配置 | 强制 |
| --- | --- | --- |
| `dart format` | `--line-length 100` | ✅ 提交前必须格式化 |
| `flutter analyze` | strict 模式，见附录 A | ✅ |
| `flutter_lints` | 基线规则集 | ✅ |
| `custom_lint` | 自研分层规则（§3.2，M1 接入） | 计划 M1 |
| `riverpod_lint` | provider 误用检测（M1 接入） | 计划 M1 |
| `tool/tasks.dart` | 仓库统一任务入口（替代 melos） | ✅ |
| `commitlint` | 提交信息校验 | ✅（CI + 本地 hook） |
| `dart fix` | 自动修复 | 建议 |

行长统一 **100**，不允许各包自定义。理由：移动端分屏 + diff 可读性的折中；团队只有一套设置时，争议成本最低。

### 2.2 生成代码

build_runner 生成的文件一律不手写、不 review、不格式化：

```
*.g.dart          # Drift / json_serializable
*.freezed.dart    # freezed
*.gr.dart         # go_router（若启用）
lib/generated/    # gen-l10n
```

改完模型/表/ARB 后必须跑 `dart run tool/tasks.dart gen`，并把生成结果一起提交。CI 会检查「生成后是否产生未提交的 diff」，有 diff 即失败。

### 2.3 标准命令

```bash
flutter pub get            # 安装所有包依赖
dart run tool/tasks.dart gen              # build_runner + gen-l10n + gen-registry
dart run tool/tasks.dart gen:registry     # 只重生成插件注册表（gen 的子集）
dart run tool/tasks.dart format           # 格式化全仓
dart run tool/tasks.dart analyze          # 静态分析（含 custom_lint）
dart run tool/tasks.dart test             # 全部测试
dart run tool/tasks.dart check            # format --set-exit-if-changed + analyze + test（提交前必跑）
dart run tool/tasks.dart test --scope core,domain,reader,plugin_api,plugin_host,data        # 只跑核心包，日常高频
dart run tool/tasks.dart build:apk        # 构建 release APK
dart run tool/new_plugin.dart --name format_fb2   # 插件脚手架
```

`dart run tool/tasks.dart check` 是**唯一可信的完成标准**，任何"我本地跑过单个测试"都不算。

---

## 3. 项目结构与分层

### 3.1 目录与包名映射

目录名用短名，pub 包名加前缀避免与 pub.dev 冲突：

| 目录 | 包名 | 职责 |
| --- | --- | --- |
| `apps/mobile` | `modoo_reader` | App 壳：启动、路由装配、插件注册 |
| `packages/core` | `modoo_core` | DI 容器、日志、异常基类、平台端口 |
| `packages/domain` | `modoo_domain` | 实体、用例、仓库接口（尽量纯 Dart） |
| `packages/data` | `modoo_data` | Drift schema、DAO、仓库实现、迁移 |
| `packages/ui` | `modoo_ui` | 设计 token、主题、通用组件 |
| `packages/reader` | `modoo_reader_engine` | 分章、分页、定位、翻页动画 |
| `packages/plugin_api` | `modoo_plugin_api` | 插件契约（**唯一对外稳定 API**） |
| `packages/plugin_host` | `modoo_plugin_host` | 注册表、生命周期、设置渲染 |
| `packages/source_engine` | `modoo_source_engine` | 书源 DSL、抓取、JS 沙箱 |
| `packages/sync` | `modoo_sync` | WebDAV、合并、加密 |
| `packages/l10n` | `modoo_l10n` | ARB 与生成代码 |
| `plugins/*` | `modoo_<capability>_<name>` | 具体插件，如 `modoo_format_txt`；模板插件 `plugins/example_hello` 是例外，包名 `modoo_example_hello` |

新包命名：`modoo_` + 小写下划线。插件 id 用点分：`modoo.format.txt`。

### 3.2 依赖矩阵（可被 lint 强制）

行 = 包，列 = 允许依赖。

| 包 | 允许依赖 | 绝对禁止 |
| --- | --- | --- |
| `plugin_api` | Dart 核心库 | 任何 `modoo_*` |
| `core` | dart/flutter 基础库、`logging` | domain、data、reader、ui、features |
| `domain` | `core` | flutter/material、data、ui |
| `data` | `core`、`domain`、`drift` | ui、reader、features、plugins |
| `ui` | `core` | domain、data、reader |
| `reader` | `core`、`domain` | data、ui、features、plugins |
| `plugin_host` | `core`、`plugin_api` | data、ui、具体插件 |
| `source_engine` | `core`、`plugin_api` | ui、features |
| `sync` | `core`、`domain` | data（直接）、ui |
| `features/*` | 上述所有包 + 经 registry 暴露的能力 | 插件内部实现 |
| `plugins/*` | **仅** `plugin_api` | core、data、ui、reader、features |

三条最容易破的线，写清楚为什么：

1. **`reader` 不许 import `data`**：分页引擎不该知道 SQLite 存在。它只认 `ChapterRepository` 接口，测试时传内存实现。
2. **`plugins` 只许依赖 `plugin_api`**：否则 API 一改，所有插件陪葬，插件作者也会开始依赖内部实现。
3. **`ui` 不许依赖 `domain`**：设计系统一旦认识业务实体，就再也复用不到第二个 App。

### 3.3 插件装配的唯一入口

全仓库**只有一处**允许 import `plugins/*`：

```
apps/mobile/lib/src/plugins/registry.g.dart
```

内容由 `tool/gen_registry.dart` 生成（扫描 `plugins/` 下的 pubspec，要求每个插件在
`lib/<包名>.dart` 导出顶层 `ModooPlugin createPlugin()`），**不接受手工维护** —— 手写一定会漏：

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: dart run tool/gen_registry.dart

import 'package:modoo_plugin_api/modoo_plugin_api.dart';
import 'package:modoo_format_txt/modoo_format_txt.dart' as modoo_format_txt;

List<ModooPlugin> buildPluginList() => <ModooPlugin>[
  modoo_format_txt.createPlugin(),
];
```

App 壳只调用 `buildPluginList()`，把结果交给 `PluginRegistry`；`main.dart` 是唯一 import 这个生成文件的地方。
新增插件后跑 `dart run tool/tasks.dart gen:registry` 即可，不要手改这份清单。

### 3.4 feature 内部结构

`features/` 内部按 **feature-first** 组织，不按技术分层：

```
features/reader/
├─ reader_page.dart          # 页面入口（只有 UI）
├─ widgets/                  # 该 feature 私有组件
├─ controllers/              # Riverpod notifier
└─ models/                   # 仅该 feature 用的视图模型
```

判据：**删掉这个 feature，不应该需要动其他 feature 的文件**。需要动，说明它该下沉到 `packages/`。

### 3.5 包的公共入口（一包一个出口）

每个包**有且只有一个**公共入口：`lib/<包名>.dart`（如 `packages/core/lib/modoo_core.dart`），用 `export ... show ...` 显式列出公共 API。跨包一律 `import 'package:modoo_core/modoo_core.dart';`。

- 禁止第二个聚合文件（`all.dart`、`exports.dart`、`index.dart`）。
- 禁止 `export` 其他包的文件；跨包依赖必须显式写进 `pubspec.yaml`。
- 禁止跨包 `package:xxx/src/...` 导入 —— 会触发 `implementation_imports`，CI 直接拦。
- 包内互相引用可以走相对路径进 `src/`，`<包名>.dart` 内部也用相对路径。

为什么不是「完全禁止 export」：Dart 没有模块系统，若实现全放 `lib/src/` 又禁 `export`，跨包就只剩 `package:x/src/` 一条路，而那正是 `implementation_imports` 要拦的。正确规则是「**一个包一个出口**」，而不是「一个项目一堆 barrel」。barrel 的真正问题在于把多个包/多个 feature 聚成一个「什么都能 import」的万能入口 —— 那才是要禁的东西。

---

## 4. 命名

### 4.1 文件与目录

| 对象 | 规则 | 示例 |
| --- | --- | --- |
| 文件 | `snake_case.dart`，按**主类型**命名 | `reader_controller.dart` |
| 目录 | `snake_case/` | `chapter_parser/` |
| 测试 | 镜像 lib 路径 + `_test.dart` | `lib/src/pager.dart` → `test/src/pager_test.dart` |
| 生成文件 | 源文件名 + `.g.dart` | `database.g.dart` |
| 扩展方法 | `xxx_extensions.dart` | `string_extensions.dart` |

禁止 `utils.dart`、`helpers.dart`、`common.dart`、`misc.dart`。这类名字等于承认"我不知道它属于哪"，正确做法是按领域命名：`encoding_detector.dart`、`chapter_splitter.dart`。

### 4.2 标识符

| 对象 | 规则 | 示例 |
| --- | --- | --- |
| 类/枚举/扩展/typedef | `UpperCamelCase` | `ChapterSplitter` |
| 接口 | `abstract interface class` | `BookFormatParser` |
| 变量/参数/方法 | `lowerCamelCase` | `pageHeight` |
| 常量 | `lowerCamelCase`（Dart 惯例，不用 SCREAMING） | `defaultLineHeight` |
| 私有 | `_` 前缀 | `_currentPage` |
| 布尔 | `is/has/can/should` 开头 | `isPaginating` |
| 回调/事件 | `on` 前缀 | `onChapterChanged` |
| 异步方法 | 动词开头；返回 Future 不加 `Async` 后缀 | `loadChapter()` |

### 4.3 领域专有命名

这些名字会出现在文档、日志、数据库里，定死后不要改：

| 对象 | 规则 | 示例 |
| --- | --- | --- |
| Riverpod provider | `<名词>Provider` | `booksProvider`、`readerControllerProvider` |
| Notifier 类 | `<名词>Controller` | `ReaderController` |
| 状态类 | `<名词>State`，必须 freezed / 不可变 | `ReaderState` |
| Drift 表类 | 复数名词 | `Books`、`Chapters`、`Annotations` |
| DAO | `<表名单数>Dao` | `BookDao` |
| 迁移 | `schema_v<N>_to_v<M>` | `schema_v2_to_v3` |
| 插件 id | `modoo.<能力>.<名字>` | `modoo.format.txt` |
| l10n key | `<feature><Element>` 驼峰 | `readerSettingsTitle` |
| 路由名 | `k<Name>Route` | `kReaderRoute` |
| commit scope | 见 §14.1 | `reader`、`data`、`plugin` |

---

## 5. Dart 语言约定

### 5.1 类型

- **公共 API 必须显式声明返回类型**，包括 `void`。`always_declare_return_types` 已开启。
- **禁止 `dynamic`**。需要"任意值"时用 `Object?`，并在使用处显式收窄。
- 局部变量一律 `final`；**只有需要重新赋值时**才用 `var`（`prefer_final_locals` 会拦，`final page = Page.empty();` 是常态）。类型从右侧一眼可见时不必重复写类型；从 `await` 或复杂表达式来的值写显式类型。
- 泛型不要省略：`List` ❌ → `List<Chapter>` ✅（`strict-raw-types` 已开）。

### 5.2 空安全

- **禁止裸 `!`**。改用 `??` 默认值、局部变量提升、或提前 `if (x == null) return;`。
- `late` 仅允许两处：DI 容器字段、`initState` 后初始化的 controller，且必须写一行注释说明为何不能构造期赋值。
- 可空集合用 `List<T>?` 而非 `List<T?>`，语义更清楚。

### 5.3 不可变

- 所有跨层传递的数据模型用 `freezed`，`final` 字段。
- 对外返回集合时返回不可变视图：

```dart
List<Chapter> get chapters => List.unmodifiable(_chapters);
```

- 禁止在 `build()` 里修改任何外部状态（见 §6.1）。

### 5.4 控制流

- `switch` 对 sealed 类型必须穷尽，不加 `default`（让编译器帮你发现漏分支）。
- 优先用 switch 表达式代替 `if/else` 链：

```dart
final label = switch (format) {
  BookFormat.txt => 'TXT',
  BookFormat.epub => 'EPUB',
  BookFormat.cbz => 'CBZ',
};
```

- 单行 `if` 允许不加花括号，仅限无 `else` 的早返回。

### 5.5 扩展与顶层函数

- 扩展方法放 `*_extensions.dart`，命名 `on` 具体类型，不要 `on Object`。
- 顶层函数仅限**无状态纯函数**（`formatBytes`、`clampInt`）。带业务语义的一律进类或用例。
- 不使用 `part` / `part of`，生成文件除外。

### 5.6 集合与内存

- 大集合避免 `map().toList()` 链式多次遍历，合并成一次循环（阅读热路径尤其注意，见 §10）。
- 需要判空集合时返回 `const []`，不要返回 `null`。

### 5.7 其他

- `const` 构造函数优先，能 `const` 就 `const`。
- 禁止 `print`（`avoid_print`）；用 `AppLogger`，见 §11.3。
- 禁止 `DateTime.now()` 直接出现在业务逻辑里 —— 通过 `Clock` 注入，否则测试无法固定时间。
- 禁止 `Random()` 无种子用于可复现逻辑（分页测试要确定性）。

---

## 6. Flutter 与 UI

### 6.1 Widget

- `build()` 必须是**纯函数**：只读状态、只建 widget。禁止 I/O、禁止 `ref.read(...).method()` 触发副作用、禁止 `setState`。
- 默认 `StatelessWidget`；只有需要 `AnimationController` / `ScrollController` / `TextEditingController` 时才用 `StatefulWidget`，并全部在 `dispose` 释放。
- 单个 widget 文件 **≤ 300 行**，超了拆 `widgets/` 子目录。
- 列表项必须有稳定 `Key`：

```dart
ListView.builder(
  itemBuilder: (context, i) => BookTile(key: ValueKey(books[i].id), book: books[i]),
);
```

- 回调命名 `onXxx`，不要 `callback`、`handler`。

### 6.2 主题与设计 token

**禁止硬编码颜色、字号、圆角、间距。** 一律走 `modoo_ui`：

```dart
// ❌
Container(color: const Color(0xFFF5F5F5), padding: const EdgeInsets.all(12))
Text('第 3 章', style: const TextStyle(fontSize: 16))

// ✅
Container(color: context.colors.surfaceContainer, padding: EdgeInsets.all(context.spacing.md))
Text(context.l10n.chapterTitle(3), style: context.textTheme.bodyMedium)
```

例外只有两类，且必须注释原因：自定义着色器、书封渐变色板。新增 token 时先改 `modoo_ui`，不要在调用处创建设计值。

深色模式必须与浅色模式**同时**验证，不允许"先上浅色后面补"。

### 6.3 文案与国际化

- 所有用户可见文本走 `context.l10n.xxx`，包括错误提示、空态、按钮、`Semantics` 标签。
- ARB 文件在 `packages/l10n/lib/l10n/`：`app_zh.arb`（模板）、`app_en.arb`。新增 key 必须同时补英文占位，否则 CI 失败。
- 带参数的文案用占位符，不要字符串拼接（语序会变）：

```dart
// ❌ '第 $n 章'
// ✅ context.l10n.chapterTitle(n)  // ARB: "第 {n} 章"
```

- 中文标点用全角，英文语境用半角；不要在文案里混用省略号（统一 `…`）。

### 6.4 可访问性

- 可点击区域 ≥ 48×48 dp（视觉可以小，热区必须够）。
- 图标按钮必须有 `tooltip` 或 `Semantics(label:)`。
- 正文对比度 ≥ 4.5:1；禁用态允许 3:1。
- 阅读器内部字号缩放 clamp 到 `[0.8, 1.6]` 倍系统缩放，并在设置页说明原因（再大会破版）。

### 6.5 动画

- 动画控制器生命周期跟 State 走，`dispose` 必须 `dispose()`。
- 驱动重绘用 `AnimatedBuilder` + `ValueListenableBuilder`，**不要**用 `setState` 每帧重建整棵树。
- 尊重系统「减弱动态效果」（`MediaQuery.disableAnimationsOf`），开启时降级为直接切页。
- 帧预算 16.7ms；翻页动画里禁止分配大对象、禁止 `Opacity`（用 `Color.withValues(alpha:)` 或 `FadeTransition`）。

### 6.6 图片与资源

- 资源放 `assets/`，按 `images/`、`fonts/`、`icons/` 分目录，文件名 `snake_case`。
- 加载大图必须给 `cacheWidth` / `cacheHeight`，否则解码内存会爆。
- 字体走「系统字体 + 可选下载」（ADR-0007）；随包字体必须是 OFL/Apache 许可，并在 `THIRD_PARTY.md` 登记。

### 6.7 布局与滚动

- 用 `MediaQuery.sizeOf(context)` / `textScalerOf(context)`，**不要**用 `MediaQuery.of(context)`（会让整棵树跟着无关变化重建）。
- 固定高度列表用 `itemExtent` 或 `prototypeItem`，否则滚动会反复测量。
- 嵌套滚动要显式 `shrinkWrap` + `physics`，不要靠猜。
- 禁止在 `build()` 里 `MediaQuery` + `LayoutBuilder` + `IntrinsicHeight` 三件套叠用，性能必崩。

---

## 7. 状态管理（Riverpod）

### 7.1 基本形态

- 全部 provider 用 `@riverpod` 代码生成，不手写 `Provider((ref) => ...)`。
- 状态类必须不可变；Notifier 只暴露意图明确的方法（`nextPage()`、`jumpTo(chapter)`），不暴露 `setState` 式万能 setter。
- `autoDispose` 是默认；要 `keepAlive` 必须在代码里写注释说明为什么（例如阅读会话跨页面存活）。

```dart
@riverpod
class ReaderController extends _$ReaderController {
  @override
  Future<ReaderState> build(String bookId) async {
    final book = await ref.watch(bookProvider(bookId).future);
    return ReaderState.initial(book);
  }
}
```

### 7.2 读写纪律

| 场景 | 用法 |
| --- | --- |
| `build()` 中依赖其他 provider | `ref.watch` |
| 回调 / 事件处理中触发动作 | `ref.read(...notifier)` |
| 只需要状态的一小部分 | `ref.watch(p.select((s) => s.chapterIndex))` |
| 异步依赖 | `ref.watch(p.future)` 或在 `AsyncNotifier` 里 `await` |

禁止在 `build()` 里 `ref.read`（会失去响应式），禁止在回调里 `ref.watch`（没有重建上下文，等于误用）。

### 7.3 async gap

`await` 之后 `ref` / `context` 都可能已经失效：

```dart
// ❌
Future<void> save() async {
  await repo.save();
  ref.read(toastProvider).show('已保存'); // ref 可能已 dispose
}

// ✅
Future<void> save() async {
  final toast = ref.read(toastProvider);
  await repo.save();
  if (!ref.mounted) return;
  toast.show(...);
}
```

Widget 回调里对应的是 `if (!context.mounted) return;`。

`ref.mounted` 从 **Riverpod 3.0** 才有（本项目锁 3.x，见计划 ADR-0009）。若某个分支被迫退回 2.x，用 `ref.onDispose` 打标记替代，不要写 `ref.mounted` —— 那是编译错误，不是运行时问题。

### 7.4 依赖注入

- 所有外部依赖（Repository、HttpClient、Clock、Logger）通过 provider 注入，禁止在 widget 里 `new`。
- 禁止全局可变单例；唯一例外是 `AppLogger`（只写不读业务状态）。
- 测试通过 `ProviderScope(overrides: [...])` 替换实现，不 mock 全局变量。

### 7.5 provider 放置

| 类型 | 位置 |
| --- | --- |
| 数据源/仓库 provider | `packages/data/lib/src/providers/` |
| 引擎/服务 provider | 对应 package 内 |
| 页面级状态 | `features/<name>/controllers/` |
| 跨 feature 共享的 UI 状态 | `packages/ui` 或 `features/shared/` |

---

## 8. 数据层（Drift）

### 8.1 表定义

- 表类放 `packages/data/lib/src/tables/`，一个文件一张表。
- 列名 snake_case，Dart 字段 lowerCamelCase。
- 每张表必须有主键；有时间语义的表必须有 `created_at` / `updated_at`。
- 需要"可恢复删除"的表加 `deleted_at`（软删除），查询默认过滤 `deletedAt IS NULL`。
- 字符串列给长度约束（`withLength`），避免脏数据。

### 8.2 访问

- **禁止在 DAO 之外拼 SQL**。所有查询是 DAO 的具名方法（`watchBooksSorted(BookSort sort)`），不接受 SQL 片段参数。
- DAO 返回 domain 实体，映射逻辑放 `mappers/`，不让上层见到 Drift 的 `DataClass`。
- 多条写操作必须包事务。
- 大结果集分页（`limit` + `offset` 或 keyset），禁止 `select(all)` 后内存过滤。

### 8.3 迁移

- `schemaVersion` **只增不减**。
- **已发布的迁移步骤永久冻结**：不允许修改历史 `onUpgrade` 分支，只能追加新分支。
- 每次迁移必须有测试：`test/migrations/` 放旧版本 DB 样本，断言迁移后结构与数据正确。
- 迁移脚本必须能处理"空库直建"与"逐版本升级"两条路径。

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async => m.createAll(),
  onUpgrade: stepByStep(
    from1To2: (m, schema) async { ... },
    from2To3: (m, schema) async { ... },
  ),
);
```

### 8.4 生成文件

`database.g.dart` 不手改、不在 PR 里手 diff、必须随模型变更一起提交。CI 校验生成物是否有未提交 diff。

---

## 9. 插件规范

插件是**对外契约**，标准比 App 内部更严。

### 9.1 依赖与纯度

- 只允许依赖 `plugin_api` + Dart 核心库。
- **禁止** UI（`flutter/material`）、`BuildContext`、`dart:io`、平台 channel。文件通过 `FileHandle` 传入，网络通过 `PluginContext` 提供的客户端。
- 禁止全局可变状态；插件实例可能被复用，方法必须无隐藏状态。
- 禁止 `print`；用 `ctx.logger`。

### 9.2 Manifest

```dart
@override
PluginManifest get manifest => const PluginManifest(
      id: 'modoo.format.txt',
      name: 'TXT',                   // 英文兜底名，本地化由宿主按 id 查 ARB
      version: '1.0.0',              // 必须与 pubspec version 一致，测试会校验
      sdkConstraint: '>=1.0.0 <2.0.0',
      capabilities: {BookFormatParser},
    );
```

- `manifest` 必须是 `const`。
- 新增能力必须先改 `plugin_api` 并写 ADR，不允许插件"偷偷"实现未声明能力。
- **文案归属**：`name`、`description`、设置项的 `label` 只是英文兜底值。插件不能 import l10n（更不可能 import Flutter），所以用户可见文案由宿主负责 —— 按 `manifest.id` 和设置项 key 去 `modoo_l10n` 查，查不到才回落到兜底值。这样插件零依赖、文案仍可翻译。新增插件时在 ARB 里加 `plugin_<id>_name` 一类条目。

### 9.3 行为契约

- `register()` 必须幂等，且不抛可预期异常；不可恢复的错误交给 host 记录。
- 长任务必须支持**协作取消**：接口给了 `CancelToken` 的必须响应；只给了 `ImportSink` 的（如 `import(FileHandle, ImportSink)`）用 `sink.isCancelled` 检查，且每处理一个数据块检查一次。
- 解析必须流式上报进度（`sink.progress`），不允许 5 分钟无反馈。
- 任何方法不得阻塞主线程超过 16ms。

### 9.4 测试

- 每个插件必须有 `test/`，且能在**无 Flutter binding** 的纯 Dart 环境跑通。
- 必须包含：正常输入、损坏输入、超大输入、边界编码四类用例。
- 测试夹具放 `test/fixtures/`，体积小的真实样本进仓库。

### 9.5 版本

- 插件独立 SemVer；`plugin_api` 破坏性变更时，所有内置插件同 PR 升级 `sdkConstraint`。
- 对外发布的插件在 README 里写明兼容的 `plugin_api` 版本区间。

---

## 10. 并发与性能

### 10.1 线程纪律

**主线程（UI isolate）禁止**：

- 文件读写、解压、图片解码
- 正则扫描 > 100KB 文本
- 解析 > 100KB 的 JSON
- 同步数据库查询（用 `watch`/`Future`）

一律走 `TaskRunner.run()`（封装 `Isolate.run`，Web 端降级为分块 + `Future` 让步）：

```dart
final chapters = await taskRunner.run(
  () => ChapterSplitter.split(bytes, pattern),
  debugLabel: 'split-chapters',
);
```

**唯一例外：文本布局 / 分页不走 isolate。** `TextPainter.layout` / `computeLineMetrics` 依赖 UI isolate 的字体环境，搬到后台 isolate 会拿到错误的字体度量。分页在主线程用空闲帧分片（每片 ≤ 8ms）做，见计划 §3.5.3；同理 `charset_converter` 这类 platform channel 也只能在主 isolate 调用。

### 10.2 取消

- 页面 `dispose` 时取消进行中的解析/请求。
- 有 `CancelToken` 的必须响应它，并在循环里检查 `token.isCancelled`；只有 `ImportSink` 的接口用 `sink.isCancelled`，每处理一块检查一次（见 §9.3）。
- 恢复阅读位置再切章时，先取消上一章的排版任务，避免旧结果覆盖新页。

### 10.3 缓存

- 分页结果按 `layoutHash` 缓存，LRU 上限 5 章，超出淘汰（见计划 §3.5.3）。
- 图片解码按显示尺寸缩放，禁止原图直出。
- 禁止"为了快"把整本书读进内存；20MB 书的峰值内存预算 200MB。

### 10.4 加载态

- 禁止 `Future.delayed` 伪造加载动画。
- 加载态必须反映真实进度（导入显示已解析字节数/总字节数）。

---

## 11. 错误处理与日志

### 11.1 异常层次

`modoo_core` 定义 sealed 异常，业务层只抛这些：

```dart
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause, this.stackTrace});
  final String message;       // 英文，面向日志
  final Object? cause;
  final StackTrace? stackTrace;
}

final class StorageException extends AppException {}
final class ParseException extends AppException {}         // 文件损坏/编码失败
final class UnsupportedFormatException extends AppException {}
final class NetworkException extends AppException {}
final class PluginException extends AppException {}
final class SyncException extends AppException {}
```

### 11.2 捕获纪律

- 边界捕获：repository / usecase / plugin host 把底层异常翻译成 `AppException` 再抛出。
- UI 层只处理 `AsyncValue.error`，不写 `try/catch`（除非处理可恢复的交互错误）。
- **禁止 `catch (e)` 裸捕获**（`avoid_catches_without_on_clauses`）；至少 `on Exception`。
- **禁止捕获 `Error`**（那是 bug，应该让它崩）。
- 重新抛出时保留原始栈：`throw StorageException(..., cause: e, stackTrace: st);`

### 11.3 日志

```dart
logger.debug('paginate chapter', fields: {'bookId': bookId, 'chapter': idx});
logger.error('import failed', error: e, stackTrace: st);
```

- 级别：`debug`（本地调试）/ `info`（生命周期）/ `warn`（可恢复异常）/ `error`（用户可见失败）。
- **禁止记录**：书籍正文、完整文件路径、URL 的查询参数、任何用户标识。隐私承诺（计划 §6.5）靠这条守。
- release 构建默认只写 `warn` 以上，且落本地文件、滚动保留 7 天。

### 11.4 用户可见错误

必须可操作：说明发生了什么 + 用户能做什么。

```
❌ "解析失败"
✅ "这个文件可能是 GBK 编码但含无效字节，试试在导入时手动指定编码"
```

文案走 l10n，禁止把异常 `toString()` 直接显示给用户。

---

## 12. 测试

### 12.1 命名与结构

- 测试文件 `*_test.dart`，镜像源码路径。
- 用例名用英文：`should split chapters when text uses 第X章`。
- 结构 `arrange / act / assert` 三段，中间空行分隔。
- 一个用例只断言一件事；断言失败信息要能直接定位。

### 12.2 禁止事项

- 禁止真实网络、真实文件系统（用 fixtures + 内存 DB）、`DateTime.now()`（用注入的 Clock）。
- 禁止 `sleep`；用 `fakeAsync` 或 `tester.pump`。
- 禁止为了让测试过而改生产代码的可见行为（那是 bug 被测试发现了）。

### 12.3 分层要求

| 层 | 要求 |
| --- | --- |
| 单元 | `core` / `reader` / `plugins/format_*` 行覆盖 ≥ 70%（CI 卡口） |
| 组件 | 阅读器交互、设置联动必须覆盖 |
| Golden | 四个主题的阅读页；固定字体；只在 Linux CI 生成与比对 |
| 集成 | 导入 → 阅读 → 翻页 → 重启恢复 一条主链路 |

### 12.4 Golden 注意事项

Windows 与 Linux 的字体渲染不同，本地跑 golden 必然失败。规则：

- 只在 Linux CI 上 `--update-goldens`（用容器或 CI 手动 job）。
- 本地验证 UI 用截图，不提交 golden。
- golden 文件命名 `goldens/<feature>_<theme>.png`。

### 12.5 回归

修 bug 必须先写一个失败的测试，再改代码让它通过。PR 里贴「修复前失败 / 修复后通过」的证据。

---

## 13. 文档与注释

### 13.1 注释写什么

注释解释 **why**，不解释 **what**。代码本身能说清 what。

```dart
// ❌ 遍历章节
for (final c in chapters) { ... }

// ✅ 只预分页下一章：再往后用户大概率不会连续跳两章，预取会挤占解码内存
await prefetch(chapters[i + 1]);
```

### 13.2 dartdoc

- `plugin_api`、`core`、`domain` 的**所有公共成员**必须有 `///` 文档（英文）。
- 文档第一行是一句话摘要（会被 pub.dev 索引）。
- 复杂 API 给一个最小可运行示例。
- 废弃用 `@Deprecated('use xxx instead, removed in 3.0')`。

### 13.3 TODO

```dart
// TODO(harness): 支持 EPUB 脚注跳转 (issue #128)
```

必须有 owner 名字 + issue 编号。禁止裸 `// TODO`。

### 13.4 包级 README

每个 package 的 README 三段：**做什么 / 怎么用（最小示例）/ 依赖与限制**。

### 13.5 ADR

以下变更必须写 ADR（`docs/adr/NNNN-title.md`）：架构分层调整、公共 API 破坏性变更、引入重量级依赖、数据模型语义变化、放弃某项已承诺能力。模板：背景 / 选项 / 决策 / 后果。

---

## 14. 提交与评审

> 本节定义规则；GitHub 侧的落地操作（分支保护设置、推送禁令、tag 与发版、冲突与报错处置）见 [GIT_WORKFLOW.md](GIT_WORKFLOW.md)。

### 14.1 提交信息

Conventional Commits，英文，祈使句，首行 ≤ 72 字符：

```
feat(reader): support seamless chapter transition on scroll
fix(data): correct progress restore after schema v3 migration
docs(plan): add plugin SDK milestone
chore(deps): bump drift to 2.20.0
```

允许的 scope：

| scope | 范围 |
| --- | --- |
| `app` | 应用壳、路由、启动 |
| `reader` | 分页、排版、翻页 |
| `data` | 数据库、迁移、仓库 |
| `ui` | 设计系统、主题 |
| `plugin` | 插件 API 与内置插件 |
| `source` | 书源引擎 |
| `sync` | WebDAV 同步 |
| `i18n` | 文案与本地化 |
| `ci` | 流水线、脚本 |
| `docs` | 文档 |
| `deps` | 依赖升级 |

body 写**为什么**，不写"改了哪些文件"（diff 已经说明）。

### 14.2 分支与合并

- trunk-based：`main` 常绿，功能分支存活 ≤ 3 天。
- 分支名 `feat/reader-pagination`、`fix/txt-gbk-detection`。
- 禁止直接 push `main`；禁止 `--force` 到 `main`。
- 合并用 **squash**，保留一条干净的 commit。

### 14.3 PR 规模

- 单 PR **≤ 400 行**改动（不含生成文件、fixtures）。
- 超了必须拆，或说明为什么不能拆（例如机械重命名）。
- 一个 PR 只做一件事；"顺手重构"单独开 PR。

### 14.4 评审

单人阶段用「CI + 自查清单（附录 C）」替代人工 review，但**不降低标准**：

- CI 不绿不合并。
- 自己 review 一遍 diff，特别看是否有调试代码残留。
- 架构相关变更必须附 ADR 链接。

---

## 15. 依赖管理

新增依赖前回答四个问题，并把答案写进 PR 描述：

1. **许可证**是否与 MIT 兼容？（GPL/AGPL ❌）
2. **维护状态**：最近一次发布是否在 12 个月内？是否有未处理的严重 issue？
3. **体积代价**：APK 增量多少？（预算：单个依赖 ≤ 2MB）
4. **替代方案**：能否用 30 行代码自己写？能就别加。

规则：

- 优先 `dart.dev` / `flutter.dev` 官方包。
- 版本用 caret 约束（`^2.1.0`），`pubspec.lock` 必须提交。
- 升级依赖单独 PR，不与功能混在一起。
- 新增依赖同步更新 `THIRD_PARTY.md`。
- 禁止使用已归档（discontinued）的包。

---

## 16. 反模式速查

| 反模式 | 为什么错 | 正确做法 |
| --- | --- | --- |
| `build()` 里发请求 / 改状态 | 每帧可能执行，行为不可预测 | 交给 Notifier 的 `build` 或回调 |
| `catch (e) { print(e); }` | 吞异常且泄露信息 | 翻译成 `AppException` + `logger.error` |
| 裸 `!` | 运行时崩溃且难定位 | 判空 / `??` / 局部变量提升 |
| 硬编码颜色字号 | 主题切换失效、视觉不一致 | `modoo_ui` token |
| 硬编码中文文案 | 无法国际化 | `context.l10n` |
| `MediaQuery.of(context)` | 全树重建 | `sizeOf` / `textScalerOf` |
| widget 里 `new Repository()` | 无法测试、无法替换 | provider 注入 |
| `utils.dart` 大杂烩 | 职责不清、循环依赖 | 按领域命名文件 |
| 多余的 barrel / `package:x/src/` 导入 | 依赖不可见、编译变慢、绕过公共 API | 每包一个 `lib/<包名>.dart` 出口 |
| 主线程解压/大正则 | 掉帧、ANR | `TaskRunner.run` |
| 改已发布迁移 | 老用户升级必炸 | 追加新迁移 |
| 手改 `*.g.dart` | 下次生成被覆盖 | 改源模型 + `dart run tool/tasks.dart gen` |
| `print` 调试残留 | 泄露信息、性能 | `logger.debug`，提交前 grep |
| 用 `Future.delayed` 假装加载 | 掩盖真实性能问题 | 真实状态 |

---

## 17. 附录 A：`analysis_options.yaml` 参考

根目录一份，所有包 `include` 它：

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    # 全仓唯一豁免：freezed / json_serializable 的 @JsonKey 落在构造参数上，
    # 是官方已知误报（dart-lang/language#1515），不是我们写错了。见 AGENTS 硬规则 5。
    invalid_annotation_target: ignore
    missing_required_param: error
    missing_return: error
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.gr.dart"
    - "lib/generated/**"
  plugins:
    - custom_lint

linter:
  rules:
    # 类型与安全
    always_declare_return_types: true
    avoid_dynamic_calls: true
    avoid_catches_without_on_clauses: true
    only_throw_errors: true
    # 异步
    unawaited_futures: true
    discarded_futures: true
    # 风格
    prefer_single_quotes: true
    require_trailing_commas: true
    directives_ordering: true
    sort_constructors_first: true
    prefer_final_locals: true
    use_super_parameters: true
    # 质量
    avoid_print: true
    depend_on_referenced_packages: true
    unnecessary_lambdas: true
    avoid_redundant_argument_values: true
```

`discarded_futures` 与 fire-and-forget 冲突时，用 `unawaited(future)` 显式标记，不要加 ignore。

**自研 custom_lint 规则**（`tool/lints/`）：

| 规则名 | 拦截 |
| --- | --- |
| `layer_dependency` | 违反 §3.2 依赖矩阵的 import |
| `plugin_import_boundary` | 除 registry 外 import `plugins/*` |
| `no_dart_io_in_shared` | 在跨端共享包中 import `dart:io` |

---

## 18. 附录 B：好/坏对照

### B.1 build 里做副作用

```dart
// ❌ 每次重建都会触发，且无 await
Widget build(BuildContext context) {
  ref.read(importServiceProvider).start(book);
  return const BookTileSkeleton();
}

// ✅ 由 Notifier 拥有生命周期
@riverpod
class ImportController extends _$ImportController {
  @override
  Future<ImportState> build(String path) async {
    final service = ref.watch(importServiceProvider);
    return service.start(path); // 真实进度通过 stream 上报
  }
}
```

### B.2 await 之后继续用 ref

```dart
// ❌
await repository.delete(book);
ref.invalidate(booksProvider);

// ✅
if (!ref.mounted) return;
ref.invalidate(booksProvider);
```

### B.3 异常翻译

```dart
// ❌ 吞掉，且把英文异常抛给用户
try {
  return await file.readAsBytes();
} catch (e) {
  return Uint8List(0);
}

// ✅
try {
  return await file.readAsBytes();
} on FileSystemException catch (e, st) {
  throw StorageException('failed to read book file', cause: e, stackTrace: st);
}
```

### B.4 主题 token

```dart
// ❌
const Text('第 3 章', style: TextStyle(fontSize: 16, color: Color(0xFF333333)))

// ✅
Text(
  context.l10n.chapterTitle(3),
  style: context.textTheme.titleMedium?.copyWith(color: context.colors.onSurface),
)
```

### B.5 日志隐私

```dart
// ❌ 把正文与路径写进日志
logger.debug('loaded ${chapter.text} from ${file.path}');

// ✅ 只记结构化元数据
logger.debug('chapter loaded', fields: {'bookId': book.id, 'chapter': idx, 'chars': text.length});
```

---

## 19. 附录 C：PR 自查清单

提交前逐条过，全部 ✅ 才算完成：

- [ ] `dart run tool/tasks.dart check` 通过（format + analyze + test）
- [ ] 没有 `print`、没有调试代码残留、没有注释掉的代码块
- [ ] 没有新增 `// ignore` 缺理由的情况
- [ ] 新代码有测试；修 bug 有回归测试
- [ ] 用户可见文案走 l10n，中英文都补了
- [ ] 颜色/字号/间距来自 token，没有硬编码
- [ ] 依赖方向没有跨界（`layer_dependency` 无告警）
- [ ] 新增文件放对了位置，没有 `utils.dart`
- [ ] 改动了模型/表/ARB → 已跑 `dart run tool/tasks.dart gen` 并提交生成物
- [ ] 数据库变更 → 迁移测试 + 未修改历史迁移
- [ ] 公共 API 有英文 dartdoc
- [ ] PR ≤ 400 行，只做一件事
- [ ] PR 描述写了「为什么」

---

## 变更记录

| 版本 | 日期 | 变更 |
| --- | --- | --- |
| v1.0 | 2026-10-31 | 首版：分层规则、命名、Dart/Flutter 约定、Riverpod/Drift/插件规范、测试与提交规范 |
| v1.1 | 2026-10-31 | 评审修正：§3.5 改为「一包一个公共出口」（原「禁止 barrel」+「只许 `lib/src/`」无法共存）；§7.3 标注 `ref.mounted` 需 Riverpod 3.x；§10.1 明确分页不得进后台 isolate；§5.1 局部变量统一 `final`；§9.2 补插件文案归属；§9.3/§10.2 补协作取消；§12.3 覆盖率口径改 `plugins/format_*` |
| v1.2 | 2026-10-31 | §14 增指向 `docs/GIT_WORKFLOW.md` 的说明（本节定义规则，该文档负责 GitHub 侧落地） |
