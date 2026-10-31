import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:modoo_core/modoo_core.dart';
import 'package:modoo_domain/modoo_domain.dart';
import 'package:modoo_plugin_api/modoo_plugin_api.dart';
import 'package:modoo_plugin_host/modoo_plugin_host.dart';
import 'package:path/path.dart' as p;

/// A book that made it onto the shelf.
final class ImportOutcome {
  const ImportOutcome({required this.book, required this.chapterCount});

  final Book book;
  final int chapterCount;
}

/// Turns one picked file into a shelf row plus its chapters.
///
/// The pipeline is deliberately boring and repeatable:
///
/// 1. read the bytes once, detect the encoding;
/// 2. transcode to UTF-8 and write our own copy into the library folder, so
///    the rest of the app (reader, plugins, future sync) only ever deals with
///    UTF-8 and character offsets keep matching the file on disk;
/// 3. let the format plugin parse the copy and report chapters;
/// 4. insert the book, then replace all chapters in one transaction.
///
/// Any failure after step 2 deletes the copy: a half-imported file must never
/// be visible on the shelf.
final class ImportService {
  ImportService({
    required this.registry,
    required this.books,
    required this.chapters,
    required this.libraryDirectory,
  });

  final PluginRegistry registry;
  final BookRepository books;
  final ChapterRepository chapters;
  final Directory libraryDirectory;

  /// Extensions the shelf accepts today; grows with the plugin set.
  static const Set<String> supportedExtensions = <String>{'.txt'};

  /// Imports [sourcePath]; [onProgress] receives 0..1.
  Future<ImportOutcome> importFile({
    required String sourcePath,
    void Function(double fraction)? onProgress,
  }) async {
    final String extension = p.extension(sourcePath).toLowerCase();
    final BookFormatParser? parser = registry.parserForExtension(extension);
    if (parser == null) {
      throw UnsupportedFormatException('No plugin handles $extension', formatId: extension);
    }

    final File source = File(sourcePath);
    final Uint8List raw = await source.readAsBytes();
    final EncodingGuess guess = detectEncoding(raw);
    onProgress?.call(0.05);

    final String text = decodeText(raw, guess.encoding);
    onProgress?.call(0.2);

    final File copy = await _writeUtf8Copy(source, text);
    try {
      final _PathFileHandle handle = _PathFileHandle(copy.path, p.basename(copy.path));
      final ProbeResult probe = await parser.probe(handle);
      if (!probe.supported) {
        throw UnsupportedFormatException(
          probe.reason ?? 'Unsupported file',
          formatId: parser.formatId,
        );
      }

      final _CollectingSink sink = _CollectingSink(
        onProgress: (double value) => onProgress?.call(0.2 + value * 0.6),
      );
      final ImportResult result = await parser.import(handle, sink);
      onProgress?.call(0.85);

      final DateTime now = DateTime.now().toUtc();
      final int bookId = await books.insert(
        Book(
          id: 0,
          title: _titleFor(sourcePath),
          formatId: parser.formatId,
          filePath: copy.path,
          fileSizeBytes: raw.length,
          addedAt: now,
          encoding: 'utf-8',
          chapterCount: result.chapterCount,
        ),
      );

      await chapters.replaceAll(
        bookId,
        sink.chapters
            .map(
              (ChapterMeta meta) => Chapter(
                id: 0,
                bookId: bookId,
                index: meta.index,
                title: meta.title,
                startOffset: meta.startOffset,
                endOffset: meta.endOffset,
                wordCount: meta.wordCount,
              ),
            )
            .toList(growable: false),
      );
      onProgress?.call(1);

      final Book? stored = await books.findById(bookId);
      if (stored == null) {
        throw StorageException('Book $bookId vanished right after insert');
      }
      return ImportOutcome(book: stored, chapterCount: result.chapterCount);
    } on Object {
      await _deleteQuietly(copy);
      rethrow;
    }
  }

  /// Writes `text` as UTF-8 under a fresh name, creating the library folder.
  Future<File> _writeUtf8Copy(File source, String text) async {
    await libraryDirectory.create(recursive: true);
    final String stamp = DateTime.now().microsecondsSinceEpoch.toString();
    final String base = p.basenameWithoutExtension(source.path);
    final File target = File(p.join(libraryDirectory.path, '${stamp}_$base.txt'));
    return target.writeAsBytes(utf8.encode(text), flush: true);
  }

  static String _titleFor(String path) {
    final String name = p.basenameWithoutExtension(path).trim();
    return name.isEmpty ? 'Untitled' : name;
  }

  static Future<void> _deleteQuietly(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } on FileSystemException {
      // Nothing to do: a leftover temp file is harmless, a thrown import is not.
    }
  }
}

final class _CollectingSink implements ImportSink {
  _CollectingSink({required this.onProgress});

  final void Function(double fraction) onProgress;
  final List<ChapterMeta> chapters = <ChapterMeta>[];

  @override
  bool get isCancelled => false;

  @override
  void reportProgress(double fraction, {String? detail}) => onProgress(fraction);

  @override
  void addChapter(ChapterMeta meta) => chapters.add(meta);
}

/// Minimal [FileHandle] over a path we own.
final class _PathFileHandle implements FileHandle {
  _PathFileHandle(this.path, this.displayName);

  final String path;

  @override
  final String displayName;

  @override
  Future<int> length() => File(path).length();

  @override
  Stream<List<int>> openRead() => File(path).openRead();
}
