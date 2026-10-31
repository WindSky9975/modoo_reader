import 'package:drift/drift.dart';
import 'package:modoo_domain/modoo_domain.dart';

import '../database/app_database.dart';
import '../database/tables.dart';

/// Drift-backed [ChapterRepository].
final class DriftChapterRepository implements ChapterRepository {
  DriftChapterRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<Chapter>> listForBook(int bookId) async {
    final query = _db.select(_db.chapters)
      ..where((Chapters table) => table.bookId.equals(bookId))
      ..orderBy(<OrderClauseGenerator<$ChaptersTable>>[
        (Chapters table) => OrderingTerm.asc(table.idx),
      ]);
    final rows = await query.get();
    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<Chapter?> findAt(int bookId, int index) async {
    final query = _db.select(_db.chapters)
      ..where((Chapters table) => table.bookId.equals(bookId) & table.idx.equals(index))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<void> replaceAll(int bookId, List<Chapter> chapters) async {
    await _db.transaction(() async {
      await (_db.delete(_db.chapters)..where((Chapters t) => t.bookId.equals(bookId))).go();
      if (chapters.isEmpty) {
        return;
      }
      await _db.batch((Batch batch) {
        batch.insertAll(
          _db.chapters,
          chapters
              .map(
                (Chapter chapter) => ChaptersCompanion.insert(
                  bookId: bookId,
                  idx: chapter.index,
                  title: chapter.title,
                  startOffset: chapter.startOffset,
                  endOffset: chapter.endOffset,
                  wordCount: Value<int>(chapter.wordCount),
                ),
              )
              .toList(growable: false),
        );
      });
    });
  }

  Chapter _toEntity(ChapterRow row) => Chapter(
    id: row.id,
    bookId: row.bookId,
    index: row.idx,
    title: row.title,
    startOffset: row.startOffset,
    endOffset: row.endOffset,
    wordCount: row.wordCount,
  );
}
