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
