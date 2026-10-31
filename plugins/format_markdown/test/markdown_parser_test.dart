import 'dart:convert';

import 'package:modoo_format_markdown/modoo_format_markdown.dart';
import 'package:modoo_plugin_api/modoo_plugin_api.dart';
import 'package:test/test.dart';

final class _TextHandle implements FileHandle {
  _TextHandle(this.text);

  final String text;

  @override
  String get displayName => 'book.md';

  @override
  Future<int> length() async => utf8.encode(text).length;

  @override
  Stream<List<int>> openRead() => Stream<List<int>>.value(utf8.encode(text));
}

final class _RecordingSink implements ImportSink {
  final List<ChapterMeta> chapters = <ChapterMeta>[];
  final List<double> progress = <double>[];
  final StringBuffer text = StringBuffer();

  @override
  bool isCancelled = false;

  @override
  void addChapter(ChapterMeta meta) => chapters.add(meta);

  @override
  void addText(String value) => text.write(value);

  @override
  void reportProgress(double fraction, {String? detail}) => progress.add(fraction);
}

void main() {
  const MarkdownFormatParser parser = MarkdownFormatParser();

  test('probe accepts text and rejects an empty file', () async {
    expect((await parser.probe(_TextHandle('# 标题\n正文'))).supported, isTrue);
    expect((await parser.probe(_TextHandle('   \n\n'))).supported, isFalse);
    expect(parser.rewritesContent, isTrue);
    expect(parser.handlesBinaryContainers, isFalse);
  });

  test('headings become chapters and inline markup is stripped', () async {
    const String source = '''
# 夜色与破晓

前言里的一段话。

## 第一章 长夜

夜色压在**城市**上，他站在[窗前](http://example.com)，看着远处零星的灯。

- 第一句 `代码`
- 第二句 ~~删掉~~留下

## 第二章 破晓

> 天亮了。

天亮的时候，雨停了。
''';
    final _RecordingSink sink = _RecordingSink();
    final ImportResult result = await parser.import(_TextHandle(source), sink);

    expect(result.title, '夜色与破晓');
    expect(result.chapterCount, 2);
    expect(sink.chapters.map((ChapterMeta meta) => meta.title), <String>['第一章 长夜', '第二章 破晓']);

    final String text = sink.text.toString();
    expect(text, isNot(contains('**')));
    expect(text, isNot(contains('](')));
    expect(text, contains('夜色压在城市上，他站在窗前，看着远处零星的灯。'));
    expect(text, contains('第一句 代码'));
    expect(text, isNot(contains('> 天亮了')));

    // The prologue is kept with the first chapter so no text is lost.
    expect(text, contains('前言里的一段话。'));

    // Offsets index the emitted text exactly.
    for (final ChapterMeta meta in sink.chapters) {
      final String slice = text.substring(meta.startOffset, meta.endOffset);
      expect(slice.trim(), isNotEmpty);
      expect(slice, isNot(contains('\n\n')));
    }
  });

  test('plain manuscripts fall back to the chapter pattern', () async {
    const String source = '''
第一章 起点
他说：你好，世界。

第二章 归来
故事继续。
''';
    final _RecordingSink sink = _RecordingSink();
    final ImportResult result = await parser.import(_TextHandle(source), sink);

    expect(result.chapterCount, 2);
    expect(sink.chapters.first.title, '第一章 起点');
    expect(sink.text.toString(), contains('他说：你好，世界。'));
    expect(sink.text.toString(), isNot(contains('第一章 起点')));
  });

  test('an empty document fails loudly', () async {
    await expectLater(
      parser.import(_TextHandle('\n\n   \n'), _RecordingSink()),
      throwsA(isA<FormatException>()),
    );
  });
}
