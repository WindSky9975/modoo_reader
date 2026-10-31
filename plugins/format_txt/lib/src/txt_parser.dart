import 'dart:convert';

import 'package:modoo_plugin_api/modoo_plugin_api.dart';

/// Chapter heading used by Chinese and English plain-text books.
///
/// Duplicated from the reader engine on purpose: a plugin may only depend on
/// `modoo_plugin_api` (CODE_STYLE §3.2), and hoisting this into the contract
/// is a public-API change that should wait for the second text format.
const String chapterPattern =
    r'^[ \t\u3000]*(?:第[0-9零一二三四五六七八九十百千万两]+[章节回卷][^\n]{0,30}'
    r'|(?:Chapter|CHAPTER)\s+[0-9]+[^\n]{0,30})[ \t\u3000]*$';

/// Parses `.txt` books.
///
/// Import streams the file: at most one line is buffered, so a 20 MB book does
/// not need 20 MB of heap (CODE_STYLE §9.3 / plugin contract).
final class TxtFormatParser implements BookFormatParser {
  const TxtFormatParser({this.maxTitleLength = 40, this.probeBytes = 4096});

  /// A "heading" longer than this is treated as body text.
  final int maxTitleLength;

  /// How much of the file [probe] decodes to guess the encoding.
  final int probeBytes;

  @override
  String get formatId => 'txt';

  @override
  Set<String> get extensions => const <String>{'.txt'};

  @override
  bool get handlesBinaryContainers => false;

  @override
  Future<ProbeResult> probe(FileHandle file) async {
    final head = await _readHead(file, probeBytes);
    if (head.isEmpty) {
      return const ProbeResult.unsupported('file is empty');
    }
    if (_hasUtf16Bom(head)) {
      return const ProbeResult.unsupported(
        'UTF-16 text is not supported by the txt plugin yet; the importer '
        'transcodes it to UTF-8 before probing',
      );
    }
    try {
      utf8.decode(_stripBom(head));
      return const ProbeResult(supported: true, confidence: 0.9, detectedEncoding: 'utf-8');
    } on FormatException {
      return const ProbeResult.unsupported(
        'not valid UTF-8; the importer transcodes legacy encodings before probing',
      );
    }
  }

  @override
  Future<ImportResult> import(FileHandle file, ImportSink sink) async {
    final totalBytes = await file.length();
    var bytesRead = 0;
    var pending = '';
    var consumed = 0;

    var chapterStart = 0;
    var chapterTitle = '';
    var chapterWords = 0;
    var chapterCount = 0;
    var totalWords = 0;

    void emitChapter(int endOffset) {
      if (endOffset <= chapterStart) {
        return;
      }
      sink.addChapter(
        ChapterMeta(
          index: chapterCount,
          title: chapterTitle.isEmpty ? 'Chapter ${chapterCount + 1}' : chapterTitle,
          startOffset: chapterStart,
          endOffset: endOffset,
          wordCount: chapterWords,
        ),
      );
      chapterCount++;
      totalWords += chapterWords;
    }

    /// Chapters hold body text only: the heading line is the chapter title, so
    /// the reader can render it as a heading without showing it twice.
    void onLine(String line, int lineStart, int nextLineStart) {
      if (_isHeading(line, maxTitleLength)) {
        emitChapter(lineStart);
        chapterStart = nextLineStart;
        chapterTitle = line.trim();
        chapterWords = 0;
      } else {
        chapterWords += _wordCount(line);
      }
    }

    // `utf8.decoder` as a stream transformer keeps partial multi-byte
    // sequences across chunk boundaries; decoding each chunk separately would
    // corrupt Chinese text at every buffer edge.
    final textStream = _counting(
      file.openRead(),
      (int n) => bytesRead += n,
    ).transform(utf8.decoder);

    await for (final text in textStream) {
      if (sink.isCancelled) {
        return ImportResult(
          chapterCount: chapterCount,
          wordCount: totalWords,
          encoding: 'utf-8',
          warnings: const <String>['import cancelled'],
        );
      }
      pending += text;

      var start = 0;
      var newline = pending.indexOf('\n', start);
      while (newline != -1) {
        final line = pending.substring(start, newline);
        final lineStart = consumed;
        consumed += line.length + 1;
        onLine(line, lineStart, consumed);
        start = newline + 1;
        newline = pending.indexOf('\n', start);
      }
      pending = pending.substring(start);

      if (totalBytes > 0) {
        sink.reportProgress(bytesRead / totalBytes, detail: 'chapter $chapterCount');
      }
    }

    if (pending.isNotEmpty) {
      onLine(pending, consumed, consumed + pending.length);
      consumed += pending.length;
    }
    emitChapter(consumed);
    sink.reportProgress(1, detail: 'done');

    return ImportResult(chapterCount: chapterCount, wordCount: totalWords, encoding: 'utf-8');
  }

  @override
  Future<ChapterDoc> loadChapter(FileHandle file, ChapterRef chapter) async {
    final start = chapter.startOffset;
    final end = chapter.endOffset;
    if (start == null) {
      return const ChapterDoc(text: '');
    }
    var consumed = 0;
    final out = StringBuffer();
    await for (final text in file.openRead().transform(utf8.decoder)) {
      var chunk = text;
      if (consumed == 0 && chunk.startsWith('\uFEFF')) {
        chunk = chunk.substring(1);
      }
      final chunkStart = consumed;
      consumed += chunk.length;
      if (consumed <= start) {
        continue;
      }
      final from = start - chunkStart;
      final to = end == null ? chunk.length : (end - chunkStart).clamp(0, chunk.length);
      out.write(chunk.substring(from.clamp(0, chunk.length), to));
      if (end != null && consumed >= end) {
        break;
      }
    }
    return ChapterDoc(text: out.toString(), title: chapter.title, encoding: 'utf-8');
  }
}

Future<List<int>> _readHead(FileHandle file, int maxBytes) async {
  final bytes = <int>[];
  await for (final chunk in file.openRead()) {
    bytes.addAll(chunk);
    if (bytes.length >= maxBytes) {
      break;
    }
  }
  return bytes.length > maxBytes ? bytes.sublist(0, maxBytes) : bytes;
}

bool _hasUtf16Bom(List<int> bytes) {
  if (bytes.length < 2) {
    return false;
  }
  return (bytes[0] == 0xFF && bytes[1] == 0xFE) || (bytes[0] == 0xFE && bytes[1] == 0xFF);
}

List<int> _stripBom(List<int> bytes) {
  if (bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
    return bytes.sublist(3);
  }
  return bytes;
}

bool _isHeading(String line, int maxTitleLength) {
  final trimmed = line.trim();
  if (trimmed.isEmpty || trimmed.length > maxTitleLength) {
    return false;
  }
  return RegExp(chapterPattern).hasMatch(trimmed);
}

int _wordCount(String line) {
  var count = 0;
  for (final unit in line.codeUnits) {
    final isSpace = unit == 0x20 || unit == 0x09 || unit == 0x0D || unit == 0x0A || unit == 0x3000;
    if (!isSpace) {
      count++;
    }
  }
  return count;
}

Stream<List<int>> _counting(Stream<List<int>> source, void Function(int) onChunk) async* {
  await for (final chunk in source) {
    onChunk(chunk.length);
    yield chunk;
  }
}
