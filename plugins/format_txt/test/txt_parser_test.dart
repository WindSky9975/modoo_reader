import 'dart:convert';
import 'dart:typed_data';

import 'package:modoo_format_txt/modoo_format_txt.dart';
import 'package:modoo_plugin_api/modoo_plugin_api.dart';
import 'package:test/test.dart';

final class _MemoryHandle implements FileHandle {
  _MemoryHandle(this.bytes);

  final Uint8List bytes;

  @override
  final String displayName = 'sample.txt';

  @override
  Future<int> length() async => bytes.length;

  @override
  Stream<List<int>> openRead() => Stream<List<int>>.value(bytes);
}

final class _RecordingSink implements ImportSink {
  final List<ChapterMeta> chapters = <ChapterMeta>[];
  final List<double> progress = <double>[];

  @override
  bool isCancelled = false;

  @override
  void addChapter(ChapterMeta meta) => chapters.add(meta);

  @override
  void reportProgress(double fraction, {String? detail}) => progress.add(fraction);
}

void main() {
  const parser = TxtFormatParser();

  _MemoryHandle handleOf(String text) => _MemoryHandle(Uint8List.fromList(utf8.encode(text)));

  test('manifest advertises the txt extension', () {
    expect(parser.formatId, 'txt');
    expect(parser.extensions, contains('.txt'));
  });

  test('probe accepts utf-8 and rejects non-utf8 bytes', () async {
    expect((await parser.probe(handleOf('第一章 开始\n正文'))).supported, isTrue);
    final gbk = _MemoryHandle(Uint8List.fromList(<int>[0xB5, 0xDA, 0xD2, 0xBB, 0xD5, 0xC2]));
    final result = await parser.probe(gbk);
    expect(result.supported, isFalse);
    expect(result.reason, contains('UTF-8'));
  });

  test('import splits chapters and reports offsets that slice the text', () async {
    const text = '序章内容。\n\n第一章 起点\n正文一。\n\n第二章 终点\n正文二。\n';
    final sink = _RecordingSink();
    final result = await parser.import(handleOf(text), sink);

    expect(result.chapterCount, 3);
    expect(result.encoding, 'utf-8');
    expect(sink.chapters.map((ChapterMeta c) => c.title), <String>[
      'Chapter 1',
      '第一章 起点',
      '第二章 终点',
    ]);
    expect(sink.chapters.first.startOffset, 0);
    for (final chapter in sink.chapters) {
      final slice = text.substring(chapter.startOffset, chapter.endOffset);
      expect(slice.trim(), isNotEmpty);
    }
  });

  test('loadChapter returns the body without the heading line', () async {
    const text = '第一章 甲\n甲内容\n第二章 乙\n乙内容\n';
    final sink = _RecordingSink();
    await parser.import(handleOf(text), sink);
    final doc = await parser.loadChapter(
      handleOf(text),
      ChapterRef(
        index: 1,
        title: '第二章 乙',
        startOffset: sink.chapters[1].startOffset,
        endOffset: sink.chapters[1].endOffset,
      ),
    );
    expect(doc.text.trim(), '乙内容');
  });

  test('import honours cancellation', () async {
    final sink = _RecordingSink()..isCancelled = true;
    final result = await parser.import(handleOf('第一章 甲\n正文\n'), sink);
    expect(result.warnings, contains('import cancelled'));
  });

  test('a very long line is body text, not a heading', () async {
    final long = '第${'一' * 60}章';
    final sink = _RecordingSink();
    await parser.import(handleOf('$long\n正文\n'), sink);
    expect(sink.chapters.single.title, 'Chapter 1');
  });
}
