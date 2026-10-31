import 'book.dart';
import 'bookmark.dart';
import 'chapter.dart';
import 'page_layout.dart';
import 'reader_settings.dart';
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

/// Cache of pagination results, keyed by `(bookId, chapterIndex, layoutHash)`.
///
/// Every method must tolerate a cold cache: a miss is never an error.
abstract interface class PageLayoutRepository {
  Future<CachedPageLayout?> read({
    required int bookId,
    required int chapterIndex,
    required int layoutHash,
  });

  Future<void> write(CachedPageLayout layout);

  /// Called when a book is removed or re-imported: offsets may have changed.
  Future<void> deleteForBook(int bookId);

  /// Drops rows older than [before] so the cache cannot grow forever.
  Future<int> deleteOlderThan(DateTime before);
}

/// Saved spots inside one book.
///
/// Adding the same offset twice updates the note instead of duplicating the
/// row, so the reader can offer "bookmark this page" without checking first.
abstract interface class BookmarkRepository {
  Stream<List<Bookmark>> watchForBook(int bookId);

  /// Returns the row id, whether the row was inserted or updated.
  Future<int> add(Bookmark bookmark);

  Future<void> delete(int id);
}

/// Persisted reader preferences (font size, line height, theme, page turn).
abstract interface class SettingsRepository {
  Future<ReaderSettings> read();

  Future<void> save(ReaderSettings settings);
}
