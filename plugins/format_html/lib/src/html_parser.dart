import 'dart:convert';

import 'package:html/dom.dart' show Document, Element, Node, Text;
import 'package:html/parser.dart' as html_parser;
import 'package:modoo_plugin_api/modoo_plugin_api.dart';

const Set<String> _blockTags = <String>{
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
  'table',
  'header',
  'footer',
  'nav',
  'aside',
};

const Set<String> _skipTags = <String>{
  'head',
  'script',
  'style',
  'noscript',
  'nav',
  'header',
  'footer',
  'aside',
};

/// Heading tags that start a new chapter.
const Set<String> _chapterTags = <String>{'h1', 'h2'};

/// Chapter heading used when the page has no headings at all.
///
/// Duplicated from the txt plugin on purpose: a plugin may only depend on
/// `modoo_plugin_api` (CODE_STYLE §3.2).
final RegExp _fallbackChapterPattern = RegExp(
  r'^[ \t\u3000]*(?:第[0-9一二三四五六七八九十百千万零两]+[章节回卷][^\n]{0,30}'
  r'|(?:Chapter|CHAPTER)\s+[0-9]+[^\n]{0,30})[ \t\u3000]*$',
);

/// Parses single-file `.html` books (saved pages, hand-made compilations).
///
/// EPUB is a container and has its own plugin; this one takes a readable page
/// the host already transcoded to UTF-8 and rewrites it as plain text, so the
/// library copy carries no tags.
final class HtmlFormatParser implements BookFormatParser {
  const HtmlFormatParser({this.probeBytes = 4096});

  /// How much of the file [probe] looks at.
  final int probeBytes;

  @override
  String get formatId => 'html';

  @override
  Set<String> get extensions => const <String>{'.html', '.htm', '.xhtml'};

  @override
  bool get handlesBinaryContainers => false;

  @override
  bool get rewritesContent => true;

  @override
  Future<ProbeResult> probe(FileHandle file) async {
    final String head = (await _readHead(file, probeBytes)).toLowerCase();
    if (head.trim().isEmpty) {
      return const ProbeResult.unsupported('file is empty');
    }
    final bool looksLikeHtml =
        head.contains('<html') ||
        head.contains('<!doctype html') ||
        head.contains('<body') ||
        head.contains('<p>') ||
        head.contains('<div');
    if (!looksLikeHtml) {
      return const ProbeResult.unsupported('no html tags in the first few kB');
    }
    return const ProbeResult(supported: true, confidence: 0.85, detectedEncoding: 'utf-8');
  }

  @override
  Future<ImportResult> import(FileHandle file, ImportSink sink) async {
    final int totalBytes = await file.length();
    final StringBuffer raw = StringBuffer();
    await for (final String chunk in file.openRead().transform(utf8.decoder)) {
      if (sink.isCancelled) {
        return ImportResult(
          chapterCount: 0,
          wordCount: 0,
          encoding: 'utf-8',
          warnings: const <String>['import cancelled'],
        );
      }
      raw.write(chunk);
      if (totalBytes > 0) {
        sink.reportProgress((raw.length / totalBytes).clamp(0, 1) * 0.3, detail: 'reading');
      }
    }

    final Document document = html_parser.parse(raw.toString());
    final String? title = document.querySelector('title')?.text.trim();
    final List<_Chapter> chapters = _split(document);

    final StringBuffer text = StringBuffer();
    int chapterCount = 0;
    int totalWords = 0;
    for (final _Chapter chapter in chapters) {
      final String body = chapter.body.trim();
      if (body.isEmpty) {
        continue;
      }
      final int start = text.length;
      text.write(body);
      text.write('\n');
      final int end = text.length - 1;
      sink.addText(body);
      sink.addText('\n');
      sink.addChapter(
        ChapterMeta(
          index: chapterCount,
          title: chapter.title?.trim().isNotEmpty ?? false
              ? chapter.title!.trim()
              : 'Chapter ${chapterCount + 1}',
          startOffset: start,
          endOffset: end,
          wordCount: _wordCount(body),
        ),
      );
      totalWords += _wordCount(body);
      chapterCount++;
      sink.reportProgress(
        0.3 + 0.7 * (chapterCount / chapters.length),
        detail: 'chapter $chapterCount',
      );
    }
    sink.reportProgress(1, detail: 'done');

    if (chapterCount == 0) {
      throw const FormatException('HTML page has no readable text');
    }
    return ImportResult(
      chapterCount: chapterCount,
      wordCount: totalWords,
      encoding: 'utf-8',
      title: title != null && title.isNotEmpty ? title : null,
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

  /// Splits the page on `h1`/`h2`, falling back to the chapter pattern.
  static List<_Chapter> _split(Document document) {
    final Element? root = document.body ?? document.documentElement;
    if (root == null) {
      return const <_Chapter>[];
    }

    final List<_Chapter> chapters = <_Chapter>[];
    StringBuffer body = StringBuffer();
    String? heading;

    void flush() {
      if (body.toString().trim().isNotEmpty) {
        chapters.add(_Chapter(heading, body.toString()));
      }
      body = StringBuffer();
    }

    void walk(Node node) {
      if (node is Text) {
        body.write(node.text);
        return;
      }
      if (node is Element) {
        final String tag = node.localName ?? '';
        if (_skipTags.contains(tag)) {
          return;
        }
        if (_chapterTags.contains(tag)) {
          final String title = _normalize(node.text).replaceAll('\n', ' ').trim();
          if (title.isNotEmpty && body.toString().trim().isNotEmpty) {
            flush();
            heading = title;
            return;
          }
          if (title.isNotEmpty) {
            heading = title;
            return;
          }
        }
        if (tag == 'br') {
          body.write('\n');
          return;
        }
        final bool block = _blockTags.contains(tag);
        if (block) {
          body.write('\n');
        }
        for (final Node child in node.nodes) {
          walk(child);
        }
        if (block) {
          body.write('\n');
        }
        return;
      }
      for (final Node child in node.nodes) {
        walk(child);
      }
    }

    walk(root);
    flush();

    if (chapters.length >= 2) {
      return chapters;
    }

    // No usable headings: treat the whole page as one text and reuse the
    // chapter rule plain-text books rely on.
    final String whole = _normalize(chapters.map((_Chapter c) => c.body).join('\n'));
    final List<_Chapter> byPattern = <_Chapter>[];
    String? currentTitle;
    StringBuffer current = StringBuffer();
    void flushPattern() {
      if (current.toString().trim().isNotEmpty) {
        byPattern.add(_Chapter(currentTitle, current.toString()));
      }
      current = StringBuffer();
    }

    for (final String line in whole.split('\n')) {
      final String trimmed = line.trim();
      if (trimmed.isNotEmpty && trimmed.length <= 40 && _fallbackChapterPattern.hasMatch(trimmed)) {
        flushPattern();
        currentTitle = trimmed;
        continue;
      }
      current.writeln(line);
    }
    flushPattern();
    return byPattern;
  }

  /// Collapses whitespace and drops blank lines, like the EPUB extractor.
  static String _normalize(String raw) {
    final List<String> lines = <String>[];
    for (final String line in raw.split('\n')) {
      final String cleaned = line.replaceAll(RegExp(r'[ \t\u00a0]+'), ' ').trim();
      if (cleaned.isNotEmpty) {
        lines.add(cleaned);
      }
    }
    return lines.join('\n');
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

final class _Chapter {
  const _Chapter(this.title, this.body);

  final String? title;
  final String body;
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
