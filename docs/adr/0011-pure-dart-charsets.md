# 0011 字符集解码用纯 Dart 的 enough_convert

- 状态：已接受
- 日期：2026-10-31
- 相关：[ADR-0002](0002-char-offset-as-truth.md)、`docs/DEVELOPMENT_PLAN.md` §3.6

## 背景

M1 要求导入 GBK/GB18030 编码的 TXT：中文书站导出的文件大量是 GBK，用户不会自己转码。
候选方案有三条：

1. `charset_converter`（platform channel，底层用系统 ICU/Java 的 Charset）；
2. 用脚本生成 GBK→Unicode 映射表放进 `modoo_core`，零依赖；
3. `enough_convert`（纯 Dart，MPL-2.0）。

方案 1 已实测被淘汰：它 2.5.1 的 `android/build.gradle` 无条件 `apply plugin:
'org.jetbrains.kotlin.android'`，在 AGP 9 的 built-in Kotlin 下直接构建失败（`The
'org.jetbrains.kotlin.android' plugin is no longer required for Kotlin support since AGP
9.0`）；而 AGP 9 下关掉 built-in Kotlin 又会让 file_picker 的 Kotlin 源码不参与编译。
两条路都走不通，这个依赖在当前的 Android 工具链上不可用。

方案 2 能避开许可证问题，但表要自己生成、自己测，且只覆盖 GBK，将来加 Big5 得再来一遍。

## 决策

`modoo_core` 依赖 `enough_convert: ^1.7.1`，只用它的 `GbkCodec`。`decodeText()` 对它做一层
薄封装：`allowInvalid: true`，保证畸形字节降级为替换字符而不是抛异常。

对应的取舍：

- **放在 `core` 而不是 app 壳**：它是纯 Dart，可以在 isolate 里跑，也不碰 Flutter；放进
  `core` 让「检测 + 解码」这套逻辑成为一个可单测的整体。
- **导入时转码成 UTF-8 副本**，之后所有下游只面对 UTF-8（见 `ImportService` 与 ADR-0002）。
  字符偏移始终与磁盘文件一致，插件不需要知道原始编码。
- **GB18030 的四字节序列暂不支持**：`enough_convert` 只覆盖 GBK/GB2312 范围，落在这部分
  的字符会变成 `�`。M1 的验收标准只要求中文正文可读，四字节区（生僻字、部分 emoji）记入
  CHANGELOG 的已知限制。

## 后果

正面：

- 导入 GBK 书不需要平台通道，解析链可以整段搬到 isolate（M2 的预分页会用到）。
- 同时拿到 Big5、Windows-125x 等代码页，M4 的漫画/其他文本格式可以直接复用。
- 离线可用，不依赖系统 ICU 的版本差异。

负面：

- **引入 MPL-2.0 依赖**。它是文件级弱 copyleft：我们不修改它的源码，只在
  `THIRD_PARTY.md` 登记来源与许可证；如果将来 patch 它的文件，那部分文件必须继续以 MPL 发布。
- 只覆盖 GBK 子集，GB18030 四字节区不支持。
- 依赖解析多了一个包（无传递依赖，体积可忽略）。

## 替代方案

| 方案 | 否决原因 |
| --- | --- |
| `charset_converter` | AGP 9 + file_picker 组合下无法构建（见背景） |
| 自建 GBK 表 | 零许可证负担，但要自己生成/测试映射，且只覆盖 GBK；等真有第二个编码需求时再评估 |
| 让用户自己转成 UTF-8 | 把成本推给用户，等于不支持中文 TXT，与 M1 目标冲突 |
| 只支持 UTF-8 + 提示 | 中文书源绝大多数是 GBK，会砍掉主要使用场景 |

## 复审条件

- `enough_convert` 停止维护或出现 GBK 解码正确性缺陷；
- Flutter/AGP 修复了 `charset_converter` 的构建问题，且我们需要 4 字节 GB18030；
- 需要支持的编码超出它覆盖的范围（例如 GB18030 全量、Shift-JIS）。
