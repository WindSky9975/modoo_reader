# Changelog

本文件记录所有值得注意的变更。格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，
版本号遵循 [SemVer](https://semver.org/lang/zh-CN/)：`0.x` 阶段允许破坏性变更，但必须在条目里写明迁移方式。

分类固定为：`Added` / `Changed` / `Deprecated` / `Removed` / `Fixed` / `Security`。
用户可见的行为变化必须单独写一条，不能混在「重构」里。

---

## [Unreleased]

### Added

- **Markdown / HTML 导入（P1）**：
  - 两个新插件 `plugins/format_markdown`、`plugins/format_html`。Markdown 的 ATX 标题（`#`/`##`）
    变成章节；HTML 的 `h1`/`h2` 变成章节；两者都拿不到标题时退回中文「第 N 章 / 第 N 节」正则，
    再不行就整篇当一章。
  - 正文会被**重写成纯文本**再入库：行内标记（`**`、`` ` ``、链接、图片、引用、列表符号、
    `<script>`/`<style>`/`<nav>` 等）全部剥掉。因此库文件与 TXT 走的还是同一条阅读链路，字符偏移、
    书签、批注、搜索、分页缓存都不受影响。
  - 解析器契约再加一个加法成员 `BookFormatParser.rewritesContent`：可读但需要重写正文的格式
    （Markdown/HTML）仍由宿主先做编码嗅探与 UTF-8 转码，再由插件给出正文。
  - Markdown 文档开头的单个 `#` 标题当作书名；HTML 用 `<title>` 作为书名。
- **EPUB 导入（P0）**：
  - 新增第一个**容器格式插件** `plugins/format_epub`：用 `archive` 解压、`html` 解析 XHTML，
    按 OPF 的 spine 顺序抽正文，标题优先取 EPUB3 nav，其次 NCX，最后退回文档首个 `h1/h2/h3/title`。
  - 解析器契约扩了三处（都是加法）：`BookFormatParser.handlesBinaryContainers`（容器格式拿原始
    字节，自己决定正文）、`ImportSink.addText`（插件把正文吐给宿主）、`ImportResult.title`（书名
    来自文件元数据，宿主回退到文件名）。
  - 导入管线的**不变量没变**：容器格式的正文抽出来之后同样写成一份 UTF-8 库文件，字符偏移与磁盘
    一致，所以阅读页、书签、批注、分页缓存全都照旧工作。
  - 文件选择器与导入校验的扩展名改成「注册表里所有解析器声明的扩展名」，以后加格式不用再改 app。
  - 上限：容器 64 MB（防 zip 炸弹）、只抽文本不处理样式与图片，封面与插图留到后续里程碑。
- **M2 阅读统计**：
  - 设置页新增「阅读统计」入口，副标题实时显示今日阅读时长；点进去是统计页：今日 / 近 7 天 /
    连续阅读三张卡片、最近 7 天柱状图（最右是今天）、累计时长与累计字数。
  - 每次退出阅读页记一条会话：只存 `started_at` / `ended_at` / `characters` 原始行（schema v5
    新增 `reading_sessions` 表），今日/近 7 天/连续天数等聚合都在 Dart 里算，所以以后改「一天」
    的定义不需要写迁移。
  - 不到 5 秒的停留不算阅读，不落库——否则每次误点封面都会在统计里留一条。
- **M2 目录抽屉**：
  - 目录改成**从左侧滑出的抽屉**（原来是底部弹层），顶部长书名与「N 章」，下面是章节列表，
    当前章高亮，点一章直接跳过去并收起抽屉——长书在抽屉里滚动比在弹层里舒服。
  - 正文页增加**状态栏内边距**：沉浸模式下首行不再钻到状态栏底下，页高与绘制用同一组 inset。
- **M2 书架封面网格**：
  - 书架从列表改成**封面网格**（双列，按屏幕宽度自适应），点封面进阅读，长按弹出删除。
  - 数据库还没有封面图，封面由书名**确定性生成**（同一书名永远同色，取自 code units 的哈希，
    不用 `String.hashCode`，因为它跨进程不稳定），左下角显示书名首字。
  - 封面底部一条细进度条 + 右下角 `已读章/总章数`，进度来自 `ReadingProgress.chapterIndex`。
  - 网格滚到底部留出 FAB 空间，避免最后一行被浮动按钮压住。
- **M2 本地段评（批注）**：
  - 阅读页「更多」菜单新增**本页批注**与**批注**两项。
  - 本页批注：按段列出当前页的每一段，点一段即可写批注（同一段重复写是修改，不产生重复行），
    已写过的段在列表里显示批注正文并标出。
  - 批注列表：全书范围的批注，显示正文与「章节名 · 原文摘录」，点一条跳回该段，右侧可删除。
  - 数据落在本机 SQLite（schema v4 新增 `annotations` 表，`(bookId, chapterIndex, startOffset)` 唯一），
    **没有后端、没有社交元素**，这是原计划里「段评/章评」在不做服务器前提下的形态。
  - 新增 8 个中英 ARB 键（批注、本页批注、提示、已保存、已删除、空态、编辑、段落序号）。
- **M2 沉浸式阅读界面（参照番茄小说）**：
  - 阅读页不再有常驻 `AppBar`：正文占满全屏，点屏幕中间呼出/收起顶栏与底栏，
    左 30% 上一页、右 30% 下一页。
  - 顶栏：返回、书名章节、`章节/总数 · 百分比`、搜索、更多（添加书签 / 书签列表）。
  - 底栏：进度条（可拖动跳章）+ 百分比 + 四个动作（目录 / 听书 / 主题 / 排版）。
    「听书」目前提示将在 M4 插件 SDK 后提供。
  - 排版面板新增**背景色圆形色块**（纸白 / 米黄 / 夜间 / 纯黑）与**三档翻页**（上下 / 左右 / 无动画），
    底栏的主题按钮可一键循环四个主题。
  - 页表缓存键补上**内容盒尺寸**：`pageCacheHash(spec, pageWidth, pageHeight)`。之前只用
    `layoutHash`，隐藏顶栏/底栏后可用高度变化会复用旧页表，导致整页只剩一行字、页码虚高。
  - 点按改用指针级监听（`Listener` + 8px 滑动阈值），避免 `SelectionArea` 抢走中间点击。
- **M2 搜索与选中复制**：
  - 阅读页支持**长按选中文字**并复制（`SelectionArea`，走系统复制菜单），点按翻页不受影响。
  - **全书搜索**：阅读页搜索面板输入即查，结果按阅读顺序列出（摘录 + 章节 + 章内偏移），
    点一条直接跳到该位置；匹配是字面量、大小写不敏感，空查询不搜索，默认最多 200 条。
  - 搜索实现放在 `modoo_reader_engine`（纯 Dart，`searchBook`），返回 `(chapterIndex, charOffset)`，
    因此跳转复用阅读进度那套坐标，不需要第二套定位逻辑。
  - 新增 4 个中英 ARB 键（搜索、搜索提示、无结果、结果数复数）。
  - 阅读页顶栏改为「搜索 / 目录 / 更多」，书签与排版收进更多菜单，章节标题不再被图标挤掉。
- **M2 书签与预分页**：
  - 书签：阅读页右上角可**添加书签**（可写备注，同一位置重复添加只更新备注），
    **书签列表**列出全文书签（摘录、章节、备注），点一条直接跳回该位置，右侧删除按钮移除；
    `Bookmark` 以 `(chapterIndex, charOffset)` 定位，摘录只用于展示。
  - 章节预分页：翻页停止 700ms 后预排下一章的页表并写入缓存，跨章切换不再看到加载圈。
    Flutter 没有公开的 idle 回调 API，因此用「停止翻页后防抖」代替计划里的 `scheduleIdleCallback`。
  - Drift schema **v3**：新增 `bookmarks`（`bookId + chapterIndex + charOffset` 唯一），迁移只追加分支。
  - 新增 7 个中英 ARB 键（书签列表、添加书签、已添加、已删除、备注提示、空态、保存）。
  - 修复：`PageView` 在换章后首次渲染时控制器还没有 clients，导致页码显示正确但停在首页——
    改为在换页后的下一帧再 `jumpToPage`。
  - 测试：书签按阅读顺序列出、删除、同位置重复添加只更新备注；schema v3 六张表。
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

- 阅读页只有分页 + 点按翻页，**没有覆盖式翻页、双指捏合调字号**（M2 后续）。
- 全书搜索在 UI isolate 上同步扫描：几 MB 的 TXT 会有可感知卡顿（大书应挪到 isolate，见 M3）。
- 排版扩展（页边距、段首缩进、对齐、字体选择）尚未开放，只有字号、行距、主题、翻页模式。
- 预分页只预排**下一章**，且要等翻页停止 700ms；快速连翻仍可能看到一次加载。
- TXT 仅支持 UTF-8 / UTF-16 / GBK(GB2312 范围)；GB18030 四字节区与 Big5 尚未覆盖。
- 书架不支持重命名、封面、排序自定义；导入只接受 `.txt`（EPUB 在 M2 后续）。
- 数据库 schema v3 尚未发布，M1/M2 之前仍可调整；一旦发布 `v0.1.0`，迁移即冻结。
- 多选导入、文件夹扫描、自定义切章正则、阅读统计、全书搜索均未实现。
