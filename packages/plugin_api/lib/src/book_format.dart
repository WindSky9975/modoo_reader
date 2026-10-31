/// Turns a file into chapters and text.
///
/// Implementations must be pure Dart (runnable in a background isolate), must
/// not touch the UI and must honour cooperative cancellation through
/// [ImportSink.isCancelled] at least once per chunk (CODE_STYLE §9.3).
abstract interface class BookFormatParser {
  /// Stable identifier, also stored in the database: `txt`, `epub`, `cbz`.
  String get formatId;

  /// Lower-case extensions including the dot, e.g. `{'.txt'}`.
  Set<String> get extensions;

  /// True when the file is a container (ZIP, database, image bundle) rather
  /// than readable text.
  ///
  /// The importer transcodes plain-text files to UTF-8 before probing them, so
  /// a `.txt` book in GBK still reaches its parser as clean UTF-8. Container
  /// formats get the original bytes instead: only the plugin knows how to pull
  /// text out of them, and it must emit that text through [ImportSink.addText].
  bool get handlesBinaryContainers => false;

  /// True when the text this parser emits differs from the file on disk.
  ///
  /// Markdown and HTML are readable, so the importer still transcodes them to
  /// UTF-8 first (and detects their encoding on the way), but the chapter text
  /// is markup-free: it is what the parser sends through [ImportSink.addText],
  /// and that is what the importer stores as the library copy.
  bool get rewritesContent => false;

  /// Cheap check: does this file belong to me? Must not throw for garbage.
  Future<ProbeResult> probe(FileHandle file);

  /// Full parse. Progress is reported through [sink], never by writing to disk.
  Future<ImportResult> import(FileHandle file, ImportSink sink);

  /// Loads one chapter's text, for reading and re-pagination.
  Future<ChapterDoc> loadChapter(FileHandle file, ChapterRef chapter);
}

/// Opaque access to a book file.
///
/// Deliberately exposes no absolute path: plugins must not learn where the
/// user keeps their library (CODE_STYLE §12.4).
abstract interface class FileHandle {
  /// File name for display and diagnostics, not a path.
  String get displayName;

  /// Size in bytes.
  Future<int> length();

  /// Streaming read. Never load a whole book into memory.
  Stream<List<int>> openRead();
}

/// Answer to [BookFormatParser.probe].
final class ProbeResult {
  const ProbeResult({
    required this.supported,
    this.confidence = 1.0,
    this.detectedEncoding,
    this.reason,
  });

  const ProbeResult.unsupported(String this.reason)
    : supported = false,
      confidence = 0,
      detectedEncoding = null;

  final bool supported;

  /// 0..1; lets the host pick the best of several matching parsers.
  final double confidence;

  /// Encoding guessed while probing, if any.
  final String? detectedEncoding;

  /// Why the file was rejected. Log-safe, no user content.
  final String? reason;
}

/// Streaming progress sink handed to [BookFormatParser.import].
abstract interface class ImportSink {
  /// True once the user cancelled; long loops must check this.
  bool get isCancelled;

  /// Reports overall progress in 0..1. [detail] is a log-safe stage name.
  void reportProgress(double fraction, {String? detail});

  /// Emits one chapter as soon as it is known, so the shelf can show progress.
  void addChapter(ChapterMeta meta);

  /// Appends decoded text to the book's canonical text.
  ///
  /// Only needed by container formats, which have no text file to hand over.
  /// The host writes the concatenation to the library and reads it back later,
  /// so [ChapterMeta.startOffset] and [ChapterMeta.endOffset] must index
  /// exactly what [addText] produced, in call order.
  void addText(String text);
}

/// Result of a completed import.
final class ImportResult {
  const ImportResult({
    required this.chapterCount,
    required this.wordCount,
    this.title,
    this.encoding,
    this.warnings = const <String>[],
  });

  final int chapterCount;
  final int wordCount;

  /// Title from the file's metadata, when it has any; the host falls back to
  /// the file name.
  final String? title;

  /// Encoding actually used to decode, e.g. `utf-8`, `gb18030`.
  final String? encoding;

  /// Non-fatal problems worth surfacing in the import summary.
  final List<String> warnings;
}

/// One chapter discovered during import.
final class ChapterMeta {
  const ChapterMeta({
    required this.index,
    required this.title,
    required this.startOffset,
    required this.endOffset,
    required this.wordCount,
  });

  final int index;
  final String title;

  /// Character offsets into the decoded text: the single source of truth.
  final int startOffset;
  final int endOffset;

  final int wordCount;
}

/// Reference to a chapter already stored by the host.
final class ChapterRef {
  const ChapterRef({
    required this.index,
    required this.title,
    this.startOffset,
    this.endOffset,
    this.href,
  });

  final int index;
  final String title;

  /// Character offsets (TXT).
  final int? startOffset;
  final int? endOffset;

  /// Document path inside the container (EPUB spine item).
  final String? href;
}

/// A chapter's text, ready to be laid out.
final class ChapterDoc {
  const ChapterDoc({required this.text, this.title, this.encoding});

  final String text;
  final String? title;
  final String? encoding;
}
