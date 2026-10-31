import 'dart:convert';

import 'package:modoo_format_html/modoo_format_html.dart';
import 'package:modoo_plugin_api/modoo_plugin_api.dart';
import 'package:test/test.dart';

final class _TextHandle implements FileHandle {
  _TextHandle(this.text);

  final String text;

  @override
  String get displayName => 'book.html';

  @override
  Future<int> length() async => utf8.encode(text).length;

  @override
  Stream<List<int>> openRead() => Stream<List<int>>.value(utf8.encode(text));
}

final class _RecordingSink implements ImportSink {
  final List<ChapterMeta> chapters = <ChapterMeta>[];
  final StringBuffer text = StringBuffer();

  @override
  bool isCancelled = false;

  @override
  void addChapter(ChapterMeta meta) => chapters.add(meta);

  @override
  void addText(String value) => text.write(value);

  @override
  void reportProgress(double fraction, {String? detail}) {}
}

void main() {
  const HtmlFormatParser parser = HtmlFormatParser();

  test('probe accepts a page and rejects plain text', () async {
    expect((await parser.probe(_TextHandle('<html><body>hi</body></html>'))).supported, isTrue);
    expect((await parser.probe(_TextHandle('just words, no tags'))).supported, isFalse);
    expect(parser.rewritesContent, isTrue);
  });

  test('headings become chapters and scripts are dropped', () async {
    const String source = '''
<html><head><title>夜色与破晓</title>
<script>var tracking = 1;</script>
<style>p { color: red; }</style></head>
<body>
<h1>第一章 长夜</h1>
<p>夜色压在<b>城市</b>上。</p>
<p>风从北面吹来。</p>
<h2>第二章 破晓</h2>
<p>天亮的时候，雨停了。</p>
</body></html>
''';
    final _RecordingSink sink = _RecordingSink();
    final ImportResult result = await parser.import(_TextHandle(source), sink);

    expect(result.title, '夜色与破晓');
    expect(result.chapterCount, 2);
    expect(sink.chapters.map((ChapterMeta meta) => meta.title), <String>['第一章 长夜', '第二章 破晓']);

    final String text = sink.text.toString();
    expect(text, contains('夜色压在城市上。'));
    expect(text, isNot(contains('tracking')));
    expect(text, isNot(contains('color: red')));
    expect(text, isNot(contains('<p>')));

    for (final ChapterMeta meta in sink.chapters) {
      final String slice = text.substring(meta.startOffset, meta.endOffset);
      expect(slice.trim(), isNotEmpty);
      expect(slice, isNot(contains('<b>')));
    }
  });

  test('a page without headings falls back to the chapter pattern', () async {
    const String source = '''
<html><body>
<p>第一章 起点</p>
<p>他说：你好，世界。</p>
<p>第二章 归来</p>
<p>故事继续。</p>
</body></html>
''';
    final _RecordingSink sink = _RecordingSink();
    final ImportResult result = await parser.import(_TextHandle(source), sink);

    expect(result.chapterCount, 2);
    expect(sink.chapters.map((ChapterMeta meta) => meta.title), <String>['第一章 起点', '第二章 归来']);
    expect(sink.text.toString(), contains('他说：你好，世界。'));
  });

  test('a page with no words fails loudly', () async {
    await expectLater(
      parser.import(_TextHandle('<html><body><img src="a.png"/></body></html>'), _RecordingSink()),
      throwsA(isA<FormatException>()),
    );
  });
}
