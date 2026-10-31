import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart' show Archive, ArchiveFile, ZipDecoder;
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:modoo_plugin_api/modoo_plugin_api.dart';
import 'package:path/path.dart' as p;

/// Parses `.epub` books into one canonical text.
///
/// An EPUB is an OCF container: a ZIP whose `META-INF/container.xml` points at
/// an OPF package document listing the spine, i.e. the reading order. Only the
/// spine order and the text matter here — styling, fonts and CSS stay in the
/// file, because the reader lays text out itself (DEVELOPMENT_PLAN §3.6).
///
/// A book is usually a few megabytes, so the whole container is decoded in
/// memory; [maxContainerBytes] keeps a maliciously large file from exhausting
/// the heap.
final class EpubFormatParser implements BookFormatParser {
  const EpubFormatParser({this.maxContainerBytes = 64 * 1024 * 1024});

  /// Refuse containers bigger than this; an EPUB that large is almost always a
  /// zip bomb rather than a book.
  final int maxContainerBytes;

  @override
  String get formatId => 'epub';

  @override
  Set<String> get extensions => const <String>{'.epub'};

  @override
  bool get handlesBinaryContainers => true;

  @override
  bool get rewritesContent => true;

  @override
  Future<ProbeResult> probe(FileHandle file) async {
    final Uint8List head = await _readHead(file, 512);
    if (head.length < 4 || head[0] != 0x50 || head[1] != 0x4b) {
      return const ProbeResult.unsupported('not a zip container');
    }
    final String sniff = latin1.decode(head, allowInvalid: true);
    // A conforming EPUB starts with an uncompressed `mimetype` entry.
    if (sniff.contains('application/epub+zip')) {
      return const ProbeResult(supported: true);
    }
    if (sniff.contains('META-INF')) {
      return const ProbeResult(supported: true, confidence: 0.8);
    }
    return const ProbeResult.unsupported('zip without an EPUB signature');
  }

  @override
  Future<ImportResult> import(FileHandle file, ImportSink sink) async {
    final int size = await file.length();
    if (size > maxContainerBytes) {
      throw FormatException('EPUB is larger than $maxContainerBytes bytes');
    }
    final Uint8List bytes = await _readAll(file);
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } on Object catch (error) {
      throw FormatException('cannot open the EPUB container: $error');
    }

    final String? containerXml = _readEntry(archive, 'META-INF/container.xml');
    if (containerXml == null) {
      throw const FormatException('EPUB is missing META-INF/container.xml');
    }
    final String? opfPath = _firstMatch(
      containerXml,
      RegExp(r'<rootfile\b[^>]*full-path\s*=\s*"([^"]+)"'),
    );
    if (opfPath == null) {
      throw const FormatException('EPUB container does not name a package document');
    }
    final String opf = _normalizePath(opfPath);
    final String? packageXml = _readEntry(archive, opf);
    if (packageXml == null) {
      throw FormatException('EPUB package document $opf is missing');
    }

    final String baseDir = p.url.dirname(opf);
    final _Package package = _Package.parse(packageXml, baseDir);
    if (package.spine.isEmpty) {
      throw const FormatException('EPUB spine is empty');
    }

    final Map<String, String> titles = _tocTitles(archive, package);
    final List<String> warnings = <String>[];
    final StringBuffer text = StringBuffer();
    int chapterCount = 0;
    int totalWords = 0;

    for (int index = 0; index < package.spine.length; index++) {
      if (sink.isCancelled) {
        warnings.add('import cancelled');
        break;
      }
      final String href = package.spine[index];
      final String? source = _readEntry(archive, href);
      if (source == null) {
        warnings.add('missing spine item: $href');
        continue;
      }
      final _Extracted extracted = _extract(source);
      if (extracted.text.isEmpty) {
        // A cover page or a blank title page is not a chapter.
        continue;
      }
      final String rawTitle = titles[href] ?? extracted.heading ?? 'Chapter ${chapterCount + 1}';
      final String title = _cleanTitle(rawTitle);
      // The heading usually sits at the top of the document; the reader draws
      // the title itself, so drop the duplicate line.
      final String chapterText = _dropLeadingTitle(extracted.text, title);
      if (chapterText.isEmpty) {
        continue;
      }
      final int start = text.length;
      text.write(chapterText);
      text.write('\n');
      final int end = text.length - 1;
      final int words = _wordCount(chapterText);
      totalWords += words;
      sink.addText(chapterText);
      sink.addText('\n');
      sink.addChapter(
        ChapterMeta(
          index: chapterCount,
          title: title,
          startOffset: start,
          endOffset: end,
          wordCount: words,
        ),
      );
      chapterCount++;
      sink.reportProgress(chapterCount / package.spine.length, detail: 'chapter $chapterCount');
    }

    if (chapterCount == 0) {
      throw const FormatException('EPUB has no readable text');
    }

    return ImportResult(
      chapterCount: chapterCount,
      wordCount: totalWords,
      title: package.title,
      encoding: 'utf-8',
      warnings: warnings,
    );
  }

  /// The host stores the extracted text, so a chapter is a slice of it; there
  /// is nothing left to load from the container at reading time.
  @override
  Future<ChapterDoc> loadChapter(FileHandle file, ChapterRef chapter) async {
    throw UnsupportedError('EPUB chapters are read from the extracted text');
  }

  /// Package metadata needed by the importer.
  static Map<String, String> _tocTitles(Archive archive, _Package package) {
    final Map<String, String> titles = <String, String>{};

    if (package.navPath != null) {
      final String? nav = _readEntry(archive, package.navPath!);
      if (nav != null) {
        final Document document = html_parser.parse(nav);
        for (final Element anchor in document.querySelectorAll('nav a[href]')) {
          final String? href = anchor.attributes['href'];
          final String text = anchor.text.trim();
          if (href == null || text.isEmpty) continue;
          final String target = _normalizePath(
            p.url.join(p.url.dirname(package.navPath!), href.split('#').first),
          );
          titles.putIfAbsent(target, () => text);
        }
      }
    }

    if (titles.isNotEmpty) {
      return titles;
    }

    final String? ncxPath = package.tocPath;
    if (ncxPath == null) {
      return titles;
    }
    final String? ncx = _readEntry(archive, ncxPath);
    if (ncx == null) {
      return titles;
    }
    final RegExp navPoint = RegExp(
      r'<navPoint\b[\s\S]*?<text[^>]*>([\s\S]*?)</text>[\s\S]*?<content\b[^>]*src\s*=\s*"([^"]+)"',
      caseSensitive: false,
    );
    for (final RegExpMatch match in navPoint.allMatches(ncx)) {
      final String label = _stripTags(match.group(1) ?? '').trim();
      final String src = match.group(2) ?? '';
      if (label.isEmpty || src.isEmpty) continue;
      final String target = _normalizePath(
        p.url.join(p.url.dirname(ncxPath), src.split('#').first),
      );
      titles.putIfAbsent(target, () => label);
    }
    return titles;
  }

  static String _cleanTitle(String raw) {
    final String text = _stripTags(raw).replaceAll(RegExp(r'\s+'), ' ').trim();
    return text.isEmpty ? 'Untitled' : text;
  }

  /// Removes a leading line that repeats [title]; readers show the title as a
  /// heading, and two identical lines look like a bug.
  static String _dropLeadingTitle(String body, String title) {
    final List<String> lines = body.split('\n');
    if (lines.isEmpty) return body;
    final String first = lines.first.trim();
    if (first == title || first.replaceAll(' ', '') == title.replaceAll(' ', '')) {
      return lines.skip(1).join('\n').trim();
    }
    return body;
  }

  static int _wordCount(String text) => text.replaceAll(RegExp(r'\s'), '').length;

  static const Set<String> _blockTags = <String>{
    'p',
    'div',
    'section',
    'article',
    'br',
    'li',
    'ul',
    'ol',
    'tr',
    'td',
    'th',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'blockquote',
    'pre',
    'figure',
    'hr',
  };

  /// Turns one XHTML document into plain text plus the heading it starts with.
  static _Extracted _extract(String source) {
    final Document document = html_parser.parse(source);
    final Element? root = document.body ?? document.documentElement;
    if (root == null) return const _Extracted('', null);
    final StringBuffer buffer = StringBuffer();

    void walk(Node node) {
      if (node is Text) {
        buffer.write(node.text);
        return;
      }
      if (node is Element) {
        final String tag = node.localName ?? '';
        if (tag == 'head' || tag == 'script' || tag == 'style') return;
        if (tag == 'br') {
          buffer.write('\n');
          return;
        }
        final bool block = _blockTags.contains(tag);
        if (block) buffer.write('\n');
        for (final Node child in node.nodes) {
          walk(child);
        }
        if (block) buffer.write('\n');
        return;
      }
      for (final Node child in node.nodes) {
        walk(child);
      }
    }

    walk(root);
    // Books without an NCX often still label their files, so fall back to the
    // first heading before settling for "Chapter n".
    final Element? heading = document.querySelector('h1, h2, h3, title');
    final String? headingText = heading == null
        ? null
        : _normalizeText(heading.text).replaceAll('\n', ' ');
    return _Extracted(
      _normalizeText(buffer.toString()),
      headingText == null || headingText.isEmpty ? null : headingText,
    );
  }

  /// Collapses runs of spaces inside a line and drops blank lines, so chapter
  /// text does not inherit the source indentation.
  static String _normalizeText(String raw) {
    final List<String> lines = <String>[];
    for (final String line in raw.split('\n')) {
      final String cleaned = line.replaceAll(RegExp(r'[ \t\u00a0]+'), ' ').trim();
      if (cleaned.isNotEmpty) lines.add(cleaned);
    }
    return lines.join('\n');
  }

  static String _stripTags(String raw) => raw.replaceAll(RegExp(r'<[^>]*>'), ' ');

  static String? _firstMatch(String source, RegExp pattern) {
    final RegExpMatch? match = pattern.firstMatch(source);
    return match?.group(1);
  }

  static String _normalizePath(String path) {
    String decoded;
    try {
      decoded = Uri.decodeFull(path);
    } on ArgumentError {
      decoded = path;
    }
    return p.url.normalize(decoded).replaceFirst(RegExp(r'^\./'), '');
  }

  static String? _readEntry(Archive archive, String name) {
    final ArchiveFile? file = archive.findFile(name);
    if (file == null) return null;
    final Uint8List bytes = file.content;
    return utf8.decode(bytes, allowMalformed: true);
  }

  static Future<Uint8List> _readHead(FileHandle file, int limit) async {
    final BytesBuilder builder = BytesBuilder(copy: false);
    await for (final List<int> chunk in file.openRead()) {
      builder.add(chunk);
      if (builder.length >= limit) break;
    }
    final Uint8List all = builder.takeBytes();
    return all.length <= limit ? all : Uint8List.sublistView(all, 0, limit);
  }

  static Future<Uint8List> _readAll(FileHandle file) async {
    final BytesBuilder builder = BytesBuilder(copy: false);
    await for (final List<int> chunk in file.openRead()) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  }
}

/// The plain text of one spine document and the heading it starts with.
final class _Extracted {
  const _Extracted(this.text, this.heading);

  final String text;
  final String? heading;
}

/// The parts of an OPF package document the importer needs.
final class _Package {
  const _Package({
    required this.title,
    required this.spine,
    required this.manifest,
    this.navPath,
    this.tocPath,
  });

  final String? title;

  /// Manifest paths in reading order.
  final List<String> spine;

  /// Manifest id → normalized path.
  final Map<String, String> manifest;

  /// Navigation document, when the book uses EPUB 3 navigation.
  final String? navPath;

  /// NCX table of contents, used by most EPUB 2 books.
  final String? tocPath;

  static _Package parse(String xml, String baseDir) {
    final String? rawTitle = _match(xml, RegExp(r'<dc:title\b[^>]*>([\s\S]*?)</dc:title>'));
    final String? title = rawTitle == null ? null : _Package._clean(rawTitle);

    final Map<String, String> manifest = <String, String>{};
    String? navPath;
    for (final RegExpMatch item in RegExp(r'<item\b[^>]*>').allMatches(xml)) {
      final String tag = item.group(0)!;
      final String? id = _attribute(tag, 'id');
      final String? href = _attribute(tag, 'href');
      if (id == null || href == null) continue;
      final String path = _join(baseDir, href);
      manifest[id] = path;
      final String? properties = _attribute(tag, 'properties');
      if (properties != null && properties.split(' ').contains('nav')) {
        navPath = path;
      }
    }

    final List<String> spine = <String>[];
    for (final RegExpMatch item in RegExp(r'<itemref\b[^>]*>').allMatches(xml)) {
      final String? idref = _attribute(item.group(0)!, 'idref');
      final String? path = idref == null ? null : manifest[idref];
      if (path != null) spine.add(path);
    }

    final String? tocId = _attribute(_match(xml, RegExp(r'<spine\b[^>]*>')) ?? '', 'toc');
    final String? tocPath = tocId == null ? null : manifest[tocId];

    return _Package(
      title: title,
      spine: List<String>.unmodifiable(spine),
      manifest: Map<String, String>.unmodifiable(manifest),
      navPath: navPath,
      tocPath: tocPath,
    );
  }

  static String _join(String baseDir, String href) {
    final String path = p.url
        .normalize(p.url.join(baseDir, href))
        .replaceFirst(RegExp(r'^\./'), '');
    try {
      return Uri.decodeFull(path);
    } on ArgumentError {
      return path;
    }
  }

  static String? _attribute(String tag, String name) {
    final RegExpMatch? match = RegExp('$name\\s*=\\s*"([^"]*)"').firstMatch(tag);
    return match?.group(1);
  }

  static String? _match(String source, RegExp pattern) {
    final RegExpMatch? match = pattern.firstMatch(source);
    if (match == null) return null;
    // Only the patterns with a capture group keep the part we want.
    return match.groupCount >= 1 ? match.group(1) : match.group(0);
  }

  static String _clean(String raw) =>
      raw.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}
