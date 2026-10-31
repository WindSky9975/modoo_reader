import 'book.dart';
import 'chapter.dart';
import 'reading_progress.dart';

/// Read/write contract for the shelf.
abstract interface class BookRepository {
  /// Emits on every change so the shelf never polls.
  Stream<List<Book>> watchAll();

  Future<Book?> findById(int id);

  /// Returns the new row id.
  Future<int> insert(Book book);

  Future<void> markOpened(int id, DateTime at);

  /// Soft delete: the row and the file stay until the user empties trash.
  Future<void> softDelete(int id);
}

/// Read/write contract for chapters.
abstract interface class ChapterRepository {
  Future<List<Chapter>> listForBook(int bookId);

  Future<Chapter?> findAt(int bookId, int index);

  /// Replaces every chapter of [bookId] in one transaction.
  ///
  /// Used by import and by re-import after a parser upgrade; callers pass
  /// chapters in reading order and must not mix books.
  Future<void> replaceAll(int bookId, List<Chapter> chapters);
}

/// Read/write contract for reading position.
abstract interface class ProgressRepository {
  Future<ReadingProgress?> read(int bookId);

  /// Upserts and bumps [ReadingProgress.revision].
  Future<void> save(ReadingProgress progress);
}
