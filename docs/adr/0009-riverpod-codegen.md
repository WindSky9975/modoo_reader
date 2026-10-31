# ADR-0009：Riverpod 锁 3.x，统一走 `@riverpod` 代码生成

- 状态：已接受
- 日期：2026-10-31
- 相关：`docs/CODE_STYLE.md` §7、`apps/mobile/lib/src/providers/`、`docs/DEVELOPMENT_PLAN.md` §4.1

## 背景

Riverpod 提供了两种写法：手写 `Provider` / `StateNotifierProvider`，或用 `@riverpod` 注解 + 生成器。
手写更「透明」，但 provider 类型签名冗长、`autoDispose` 与 `family` 容易忘写、重构时改名要同步多处。
本项目 provider 数量会随 M1–M5 快速增加，一致性比「少一个生成文件」更重要。

## 决策

- 所有 provider 一律用 `@riverpod`（或 `@Riverpod(keepAlive: true)`）注解，由 `riverpod_generator` 生成；
  不手写 `Provider(...)` 构造函数（测试里的 `overrideWithValue` 除外）。
- 锁 `flutter_riverpod` **3.3.x**、`riverpod_annotation` **4.x**、`riverpod_generator` **>=4.0.3 <4.0.9**。
- `ref.mounted` 是 3.0 才有的 API，异步代码在 `await` 之后必须用它检查；2.x 无此 API。
- 生成器上界是刻意的：4.0.9+ 要求 `analyzer >=13`，而 `freezed 3.2.5` 只接受 `analyzer <11`，
  两者无法共存。升级必须同 PR 处理 `freezed` 与 `riverpod_generator`。

## 后果

**正面**

- provider 定义短，`autoDispose` 与依赖注入风格统一。
- 改 provider 名字时生成物会跟着变，漏改会直接编译失败。
- 与 `riverpod_lint` 配合能拦住 `ref` 跨 async gap 之类的经典错误。

**负面**

- 多一层代码生成：忘跑 `dart run tool/tasks.dart gen` 就编译失败，CI 用 `git diff --exit-code` 兜住。
- 依赖解析被 `analyzer` 版本绑死，升级窗口窄（见 ADR 正文的版本约束）。
- 生成物让 diff 变大，review 时要忽略 `*.g.dart`。

## 替代方案

| 方案 | 为什么不选 |
| --- | --- |
| 手写 provider | 类型噪音大、一致性靠人记，长期维护成本更高 |
| 不用 Riverpod（Provider / GetX / bloc） | 需要编译期安全的依赖注入与可测试的 override，Riverpod 更合适 |
| 停留在 Riverpod 2.x | 无法使用 `ref.mounted`，异步生命周期检查只能靠 `ref.onDispose` 打标记 |

## 复审条件

`freezed 4` 稳定且与 `riverpod_generator` 新版共用同一 `analyzer` 区间时，安排一次同 PR 升级并复审本 ADR。
