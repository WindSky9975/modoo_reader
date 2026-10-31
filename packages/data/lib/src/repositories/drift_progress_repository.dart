import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:modoo_domain/modoo_domain.dart';

import '../database/app_database.dart';
import '../database/tables.dart';

/// Drift-backed [ProgressRepository].
///
/// Saves are idempotent and monotonic in [ReadingProgress.revision]: the
/// newest revision wins, which is what makes WebDAV conflicts explainable
/// (DEVELOPMENT_PLAN §3.8).
final class DriftProgressRepository implements ProgressRepository {
  DriftProgressRepository(this._db);

  final AppDatabase _db;

  @override
  Future<ReadingProgress?> read(int bookId) async {
    final row = await (_db.select(
      _db.progressRows,
    )..where((ProgressRows table) => table.bookId.equals(bookId))).getSingleOrNull();
    if (row == null) return null;
    return ReadingProgress(
      bookId: row.bookId,
      chapterIndex: row.chapterIndex,
      charOffset: row.charOffset,
      pageIndex: row.pageIndex,
      updatedAt: row.updatedAt,
      deviceId: row.deviceId,
      revision: row.revision,
    );
  }

  @override
  Future<void> save(ReadingProgress progress) async {
    await _db.transaction(() async {
      final existing =
          await (_db.select(_db.progressRows)..where(
                (ProgressRows table) =>
                    table.bookId.equals(progress.bookId) & table.deviceId.equals(progress.deviceId),
              ))
              .getSingleOrNull();
      final nextRevision = math.max(existing?.revision ?? 0, progress.revision) + 1;
      await _db
          .into(_db.progressRows)
          .insertOnConflictUpdate(
            ProgressRowsCompanion.insert(
              bookId: progress.bookId,
              chapterIndex: progress.chapterIndex,
              charOffset: progress.charOffset,
              updatedAt: progress.updatedAt,
              deviceId: progress.deviceId,
              pageIndex: Value<int>(progress.pageIndex),
              revision: Value<int>(nextRevision),
            ),
          );
    });
  }
}
