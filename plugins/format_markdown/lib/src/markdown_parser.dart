import 'dart:convert';

import 'package:modoo_plugin_api/modoo_plugin_api.dart';

/// Chapter heading used by Chinese and English plain-text fallbacks.
///
/// Markdown files without headings are usually plain-text manuscripts, so the
/// same rule the txt plugin uses applies here. It is duplicated on purpose: a
/// plugin may only depend on `modoo_plugin_api` (CODE_STYLE §3.2).
const String _fallbackChapterPattern =
    r'^[ \t\u3000]*(?:第[0-9一二三四五六七八九十百千万零两]+[章节回卷][^\n]{0,30}'
    r'|(?:Chapter|CHAPTER)\s+[0-9]+[^\n]{0,30})[ \t\u3000]*$';

final RegExp _headingLine = RegExp(r'^(#{1,2})[ \t]+(.+?)[ \t#]*$');
final RegExp _inlineImage = RegExp(r'!\[[^\]]*\]\([^)]*\)');
final RegExp _inlineLink = RegExp(r'\[([^\]]*)\]\([^)]*\)');
final RegExp _inlineCode = RegExp(r'`+([^`]*)`+');
final RegExp _emphasis = RegExp(r'(\*\*\*|\*\*|\*|___|__|_|~~)');
final RegExp _listMarker = RegExp(r'^[ \t]*(?:[-*+]|\d+[.)])[ \t]+');
final RegExp _blockQuote = RegExp(r'^[ \t]*>[ \t]?');
final RegExp _rule = RegExp(r'^[ \t]*(?:-{3,}|\*{3,}|_{3,})[ \t]*$');

/// Parses `.md` books: ATX headings become chapters, markup is stripped.
///
/// The importer hands over a UTF-8 copy, so this parser only deals with text.
/// It rewrites the content ([BookFormatParser.rewritesContent]): the library
/// copy is the markup-free text, which keeps offsets, search and the page cache
/// identical to the txt path.
final class MarkdownFormatParser implements BookFormatParser {
  const MarkdownFormatParser({this.probeBytes = 4096});

  /// How much of the file [probe] looks at.
  final int probeBytes;

  @override
  String get formatId => 'markdown';

  @override
  Set<String> get extensions => const <String>{'.md', '.markdown'};

  @override
  bool get handlesBinaryContainers => false;

  @override
  bool get rewritesContent => true;

  @override
  Future<ProbeResult> probe(FileHandle file) async {
    final String head = await _readHead(file, probeBytes);
    if (head.trim().isEmpty) {
      return const ProbeResult.unsupported('file is empty');
    }
    return const ProbeResult(supported: true, confidence: 0.8, detectedEncoding: 'utf-8');
  }

  @override
  Future<ImportResult> import(FileHandle file, ImportSink sink) async {
    final int totalBytes = await file.length();
    final StringBuffer raw = StringBuffer();
    int bytesRead = 0;
    // `utf8.decoder` as a stream transformer keeps partial multi-byte sequences
    // across chunk boundaries; decoding each chunk alone would corrupt Chinese
    // text at every buffer edge.
    await for (final String chunk in file.openRead().transform(utf8.decoder)) {
      if (sink.isCancelled) {
        return ImportResult(
          chapterCount: 0,
          wordCount: 0,
          encoding: 'utf-8',
          warnings: const <String>['import cancelled'],
        );
      }
      bytesRead += chunk.length;
      raw.write(chunk);
      if (totalBytes > 0) {
        sink.reportProgress((bytesRead / totalBytes).clamp(0, 1) * 0.3, detail: 'reading');
      }
    }

    final List<String> lines = raw.toString().replaceAll('\r\n', '\n').split('\n');
    final _Plan plan = _Plan.parse(lines);

    final StringBuffer text = StringBuffer();
    int chapterCount = 0;
    int totalWords = 0;

    void emit(String? title, String body) {
      // Markdown separates paragraphs with blank lines; the reader lays out one
      // paragraph per line, so the blanks become paragraph spacing and are
      // dropped here (and would otherwise show up as empty lines).
      final String cleaned = body
          .split('\n')
          .where((String line) => line.trim().isNotEmpty)
          .join('\n')
          .trim();
      if (cleaned.isEmpty) {
        return;
      }
      final String heading = _cleanInline(title ?? 'Chapter ${chapterCount + 1}').trim();
      final int start = text.length;
      text.write(cleaned);
      text.write('\n');
      final int end = text.length - 1;
      sink.addText(cleaned);
      sink.addText('\n');
      sink.addChapter(
        ChapterMeta(
          index: chapterCount,
          title: heading.isEmpty ? 'Chapter ${chapterCount + 1}' : heading,
          startOffset: start,
          endOffset: end,
          wordCount: _wordCount(cleaned),
        ),
      );
      totalWords += _wordCount(cleaned);
      chapterCount++;
      sink.reportProgress(
        0.3 + 0.7 * (chapterCount / plan.chapterCount),
        detail: 'chapter $chapterCount',
      );
    }

    for (final _Draft draft in plan.drafts) {
      emit(draft.title, draft.body);
    }
    sink.reportProgress(1, detail: 'done');

    if (chapterCount == 0) {
      throw const FormatException('Markdown has no readable text');
    }
    return ImportResult(
      chapterCount: chapterCount,
      wordCount: totalWords,
      encoding: 'utf-8',
      title: plan.title,
    );
  }

  @override
  Future<ChapterDoc> loadChapter(FileHandle file, ChapterRef chapter) async {
    final int? start = chapter.startOffset;
    if (start == null) {
      return const ChapterDoc(text: '');
    }
    final int? end = chapter.endOffset;
    final StringBuffer out = StringBuffer();
    int consumed = 0;
    await for (final String chunk in file.openRead().transform(utf8.decoder)) {
      final int chunkStart = consumed;
      consumed += chunk.length;
      if (consumed <= start) {
        continue;
      }
      final int from = (start - chunkStart).clamp(0, chunk.length);
      final int to = end == null ? chunk.length : (end - chunkStart).clamp(0, chunk.length);
      out.write(chunk.substring(from, to));
      if (end != null && consumed >= end) {
        break;
      }
    }
    return ChapterDoc(text: out.toString(), title: chapter.title, encoding: 'utf-8');
  }

  static String _cleanInline(String raw) {
    String line = raw.replaceAll(_inlineImage, '');
    line = line.replaceAllMapped(_inlineLink, (Match match) => match.group(1) ?? '');
    line = line.replaceAllMapped(_inlineCode, (Match match) => match.group(1) ?? '');
    line = line.replaceAll(_emphasis, '');
    line = line.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ');
    line = line.replaceAll(RegExp(r'<[^>]+>'), '');
    line = line.replaceAll(RegExp(r'[ \t\u00a0]+'), ' ');
    return line.trim();
  }

  static int _wordCount(String text) {
    int count = 0;
    for (final int unit in text.codeUnits) {
      final bool space =
          unit == 0x20 || unit == 0x09 || unit == 0x0D || unit == 0x0A || unit == 0x3000;
      if (!space) {
        count++;
      }
    }
    return count;
  }
}

/// One chapter about to be emitted.
final class _Draft {
  const _Draft(this.title, this.body);

  final String? title;
  final String body;
}

/// Splits the document into drafts, deciding once which rule applies.
final class _Plan {
  const _Plan({required this.title, required this.drafts});

  final String? title;
  final List<_Draft> drafts;

  int get chapterCount => drafts.length;

  static _Plan parse(List<String> lines) {
    final List<int> headings = <int>[];
    for (int i = 0; i < lines.length; i++) {
      if (_headingLine.hasMatch(lines[i])) {
        headings.add(i);
      }
    }

    String? title;
    int firstHeading = headings.isEmpty ? lines.length : headings.first;
    // A lone H1 on top acts as the book title, not as a chapter.
    if (headings.length >= 2) {
      final RegExpMatch? match = _headingLine.firstMatch(lines[headings.first]);
      if (match != null && match.group(1) == '#') {
        final String candidate = MarkdownFormatParser._cleanInline(match.group(2) ?? '');
        if (candidate.isNotEmpty) {
          title = candidate;
          headings.removeAt(0);
          firstHeading = headings.isEmpty ? lines.length : headings.first;
        }
      }
    }

    if (headings.isEmpty) {
      return _Plan(title: title, drafts: _splitByChapterPattern(lines));
    }

    final List<_Draft> drafts = <_Draft>[];
    final StringBuffer prologue = StringBuffer();
    for (int i = 0; i < firstHeading; i++) {
      prologue.writeln(lines[i]);
    }
    for (int index = 0; index < headings.length; index++) {
      final int from = headings[index];
      final int to = index + 1 < headings.length ? headings[index + 1] : lines.length;
      final RegExpMatch? match = _headingLine.firstMatch(lines[from]);
      final String heading = MarkdownFormatParser._cleanInline(match?.group(2) ?? '');
      final StringBuffer body = StringBuffer();
      if (index == 0 && prologue.isNotEmpty) {
        body.write(prologue);
      }
      for (int i = from + 1; i < to; i++) {
        body.writeln(_renderBodyLine(lines[i]));
      }
      drafts.add(_Draft(heading.isEmpty ? null : heading, body.toString()));
    }
    return _Plan(title: title, drafts: drafts);
  }

  /// Plain manuscripts: fall back to the chapter rule the txt plugin uses.
  static List<_Draft> _splitByChapterPattern(List<String> lines) {
    final List<_Draft> drafts = <_Draft>[];
    String? heading;
    final StringBuffer body = StringBuffer();
    void flush() {
      if (body.toString().trim().isNotEmpty) {
        drafts.add(_Draft(heading, body.toString()));
      }
      body.clear();
    }

    for (final String line in lines) {
      final String trimmed = line.trim();
      final bool isHeading =
          trimmed.isNotEmpty &&
          trimmed.length <= 40 &&
          RegExp(_fallbackChapterPattern).hasMatch(trimmed);
      if (isHeading) {
        flush();
        heading = trimmed;
        continue;
      }
      body.writeln(_renderBodyLine(line));
    }
    flush();
    return drafts;
  }

  /// Strips the markup a reader does not want to see, keeps the words.
  static String _renderBodyLine(String raw) {
    final String line = raw.replaceAll('\r', '');
    if (_rule.hasMatch(line)) {
      return '';
    }
    if (line.trimLeft().startsWith('```') || line.trimLeft().startsWith('~~~')) {
      return '';
    }
    String cleaned = line.replaceFirst(_blockQuote, '');
    cleaned = cleaned.replaceFirst(_listMarker, '');
    cleaned = MarkdownFormatParser._cleanInline(cleaned);
    // Markdown tables and setext underlines become noise once the pipes go.
    if (cleaned.isNotEmpty && RegExp(r'^[|: -]+$').hasMatch(cleaned)) {
      return '';
    }
    return cleaned;
  }
}

Future<String> _readHead(FileHandle file, int maxBytes) async {
  final List<int> bytes = <int>[];
  await for (final List<int> chunk in file.openRead()) {
    bytes.addAll(chunk);
    if (bytes.length >= maxBytes) {
      break;
    }
  }
  final List<int> head = bytes.length > maxBytes ? bytes.sublist(0, maxBytes) : bytes;
  return utf8.decode(head, allowMalformed: true);
}
