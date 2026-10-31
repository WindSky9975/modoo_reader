import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart' show Archive, ArchiveFile, CompressionType, ZipEncoder;
import 'package:modoo_format_epub/modoo_format_epub.dart';
import 'package:modoo_plugin_api/modoo_plugin_api.dart';
import 'package:test/test.dart';

/// Minimal in-memory [FileHandle] over the bytes of a container.
final class _BytesHandle implements FileHandle {
  _BytesHandle(this.bytes);

  final Uint8List bytes;

  @override
  String get displayName => 'book.epub';

  @override
  Future<int> length() async => bytes.length;

  @override
  Stream<List<int>> openRead() => Stream<List<int>>.value(bytes);
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

String _containerXml(String opfPath) =>
    '<?xml version="1.0"?>'
    '<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">'
    '<rootfiles><rootfile full-path="$opfPath" '
    'media-type="application/oebps-package+xml"/></rootfiles></container>';

String _package({
  String title = '测试书名',
  String spine = '<itemref idref="ch1"/><itemref idref="ch2"/>',
  String manifest =
      '<item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>'
      '<item id="ch1" href="text/ch1.xhtml" media-type="application/xhtml+xml"/>'
      '<item id="ch2" href="text/ch2.xhtml" media-type="application/xhtml+xml"/>',
}) =>
    '<?xml version="1.0"?>'
    '<package xmlns="http://www.idpf.org/2007/opf" version="2.0">'
    '<metadata xmlns:dc="http://purl.org/dc/elements/1.1/">'
    '<dc:title>$title</dc:title><dc:creator>某作者</dc:creator></metadata>'
    '<manifest>$manifest</manifest>'
    '<spine toc="ncx">$spine</spine></package>';

String _ncx(String tocDir) =>
    '<?xml version="1.0"?>'
    '<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/">'
    '<navMap>'
    '<navPoint id="n1"><navLabel><text>第一章 起点</text></navLabel>'
    '<content src="$tocDir/ch1.xhtml"/></navPoint>'
    '<navPoint id="n2"><navLabel><text>第二章 归来</text></navLabel>'
    '<content src="$tocDir/ch2.xhtml"/></navPoint>'
    '</navMap></ncx>';

String _chapter(String title, List<String> paragraphs) =>
    '<?xml version="1.0" encoding="utf-8"?>'
    '<html xmlns="http://www.w3.org/1999/xhtml"><head><title>$title</title>'
    '<style>p { color: red; }</style></head><body>'
    '<h1>$title</h1>'
    '${paragraphs.map((String text) => '<p>$text</p>').join()}'
    '</body></html>';

Uint8List _buildEpub({
  bool withContainer = true,
  String? opf,
  String? ncx,
  List<({String path, String body})> chapters = const <({String path, String body})>[],
}) {
  final Archive archive = Archive();
  void add(String name, String content, {bool store = false}) {
    final ArchiveFile file = ArchiveFile.bytes(name, utf8.encode(content));
    if (store) file.compression = CompressionType.none;
    archive.addFile(file);
  }

  add('mimetype', 'application/epub+zip', store: true);
  if (withContainer) {
    add('META-INF/container.xml', _containerXml('OEBPS/content.opf'));
  }
  add('OEBPS/content.opf', opf ?? _package());
  add('OEBPS/toc.ncx', ncx ?? _ncx('text'));
  for (final ({String path, String body}) chapter in chapters) {
    add(chapter.path, chapter.body);
  }
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

Uint8List _defaultBook() => _buildEpub(
  chapters: <({String path, String body})>[
    (path: 'OEBPS/text/ch1.xhtml', body: _chapter('第一章 起点', <String>['他站在门口。', '风从北面吹来。'])),
    (path: 'OEBPS/text/ch2.xhtml', body: _chapter('第二章 归来', <String>['三年后他回来了。'])),
  ],
);

void main() {
  const EpubFormatParser parser = EpubFormatParser();

  test('probe accepts an EPUB container and rejects other files', () async {
    final ProbeResult epub = await parser.probe(_BytesHandle(_defaultBook()));
    expect(epub.supported, isTrue);
    expect(epub.confidence, 1);

    final ProbeResult text = await parser.probe(
      _BytesHandle(Uint8List.fromList(utf8.encode('just some text'))),
    );
    expect(text.supported, isFalse);
    expect(text.reason, contains('zip'));
  });

  test('import walks the spine, uses the NCX titles and strips markup', () async {
    final _RecordingSink sink = _RecordingSink();
    final ImportResult result = await parser.import(_BytesHandle(_defaultBook()), sink);

    expect(result.chapterCount, 2);
    expect(result.title, '测试书名');
    expect(result.encoding, 'utf-8');
    expect(sink.chapters.map((ChapterMeta meta) => meta.title), <String>['第一章 起点', '第二章 归来']);

    // The heading is dropped: the reader draws the title itself.
    final String text = sink.text.toString();
    expect(text, isNot(contains('第一章 起点')));
    expect(text, contains('他站在门口。'));
    expect(text, isNot(contains('color: red')));

    // Offsets index exactly what the sink emitted.
    for (final ChapterMeta meta in sink.chapters) {
      final String slice = text.substring(meta.startOffset, meta.endOffset);
      expect(slice.trim(), isNotEmpty);
      expect(slice, isNot(contains('\u0000')));
    }
    expect(
      text.substring(sink.chapters.first.startOffset, sink.chapters.first.endOffset),
      '他站在门口。\n风从北面吹来。',
    );
    expect(sink.progress, isNotEmpty);
  });

  test('import prefers a leading heading match over the TOC label', () async {
    // No NCX: the H1 becomes the title, and the body keeps its first line.
    final Uint8List book = _buildEpub(
      opf: _package(
        spine: '<itemref idref="ch1"/>',
        manifest: '<item id="ch1" href="text/ch1.xhtml" media-type="application/xhtml+xml"/>',
      ),
      chapters: <({String path, String body})>[
        (path: 'OEBPS/text/ch1.xhtml', body: _chapter('Chapter One', <String>['Hello world.'])),
      ],
    );
    final _RecordingSink sink = _RecordingSink();
    final ImportResult result = await parser.import(_BytesHandle(book), sink);

    expect(result.chapterCount, 1);
    expect(sink.chapters.single.title, 'Chapter One');
    expect(sink.text.toString().trim(), 'Hello world.');
  });

  test('a container without container.xml fails loudly', () async {
    final Uint8List book = _buildEpub(withContainer: false);
    await expectLater(
      parser.import(_BytesHandle(book), _RecordingSink()),
      throwsA(isA<FormatException>()),
    );
  });

  test('skips spine items with no readable text', () async {
    final Uint8List book = _buildEpub(
      opf: _package(
        spine: '<itemref idref="cover"/><itemref idref="ch1"/>',
        manifest:
            '<item id="cover" href="text/cover.xhtml" media-type="application/xhtml+xml"/>'
            '<item id="ch1" href="text/ch1.xhtml" media-type="application/xhtml+xml"/>',
      ),
      chapters: <({String path, String body})>[
        (path: 'OEBPS/text/cover.xhtml', body: '<html><body><img src="cover.jpg"/></body></html>'),
        (path: 'OEBPS/text/ch1.xhtml', body: _chapter('Chapter One', <String>['Hello world.'])),
      ],
    );
    final _RecordingSink sink = _RecordingSink();

    final ImportResult result = await parser.import(_BytesHandle(book), sink);

    expect(result.chapterCount, 1);
    expect(sink.chapters.single.index, 0);
  });
}
