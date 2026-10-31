import 'package:drift/drift.dart';
import 'package:modoo_domain/modoo_domain.dart';

import '../database/app_database.dart';
import '../database/tables.dart';

/// Drift-backed [BookmarkRepository].
///
/// `(bookId, chapterIndex, charOffset)` is unique: adding the same spot twice
/// refreshes the note and the excerpt instead of growing the list.
final class DriftBookmarkRepository implements BookmarkRepository {
  DriftBookmarkRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Bookmark>> watchForBook(int bookId) {
    final SimpleSelectStatement<Bookmarks, BookmarkRow> query = _db.select(_db.bookmarks)
      ..where((Bookmarks table) => table.bookId.equals(bookId))
      ..orderBy(<OrderClauseGenerator<Bookmarks>>[
        (Bookmarks table) => OrderingTerm.asc(table.chapterIndex),
        (Bookmarks table) => OrderingTerm.asc(table.charOffset),
      ]);
    return query.watch().map(
      (List<BookmarkRow> rows) => rows.map(_toDomain).toList(growable: false),
    );
  }

  @override
  Future<int> add(Bookmark bookmark) async {
    await _db
        .into(_db.bookmarks)
        .insert(
          BookmarksCompanion.insert(
            bookId: bookmark.bookId,
            chapterIndex: bookmark.chapterIndex,
            charOffset: bookmark.charOffset,
            excerpt: bookmark.excerpt,
            createdAt: bookmark.createdAt,
            note: Value<String?>(bookmark.note),
          ),
          onConflict: DoUpdate(
            (Bookmarks old) => BookmarksCompanion(
              excerpt: Value<String>(bookmark.excerpt),
              note: Value<String?>(bookmark.note),
              createdAt: Value<DateTime>(bookmark.createdAt),
            ),
            target: <Column<Object>>[
              _db.bookmarks.bookId,
              _db.bookmarks.chapterIndex,
              _db.bookmarks.charOffset,
            ],
          ),
        );
    final BookmarkRow row =
        await (_db.select(_db.bookmarks)..where(
              (Bookmarks table) =>
                  table.bookId.equals(bookmark.bookId) &
                  table.chapterIndex.equals(bookmark.chapterIndex) &
                  table.charOffset.equals(bookmark.charOffset),
            ))
            .getSingle();
    return row.id;
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.bookmarks)..where((Bookmarks table) => table.id.equals(id))).go();
  }

  static Bookmark _toDomain(BookmarkRow row) => Bookmark(
    id: row.id,
    bookId: row.bookId,
    chapterIndex: row.chapterIndex,
    charOffset: row.charOffset,
    excerpt: row.excerpt,
    createdAt: row.createdAt,
    note: row.note,
  );
}
