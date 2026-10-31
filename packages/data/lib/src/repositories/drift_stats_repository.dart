import 'package:drift/drift.dart';
import 'package:modoo_domain/modoo_domain.dart';

import '../database/app_database.dart';

/// Stores one row per reading stretch.
///
/// The row is written when the reader leaves a book, so writes are rare and
/// reads happen only on the statistics screen; no index beyond the primary key
/// is needed at this size.
final class DriftStatsRepository implements StatsRepository {
  DriftStatsRepository(this._db);

  final AppDatabase _db;

  @override
  Future<int> add(ReadingSession session) => _db
      .into(_db.readingSessions)
      .insert(
        ReadingSessionsCompanion.insert(
          bookId: session.bookId,
          startedAt: session.startedAt.toUtc(),
          endedAt: session.endedAt.toUtc(),
          characters: Value<int>(session.characters),
        ),
      );

  @override
  Stream<List<ReadingSession>> watchAll() {
    final query = _db.select(_db.readingSessions)
      ..orderBy(<OrderingTerm Function($ReadingSessionsTable)>[
        ($ReadingSessionsTable t) => OrderingTerm.asc(t.startedAt),
      ]);
    return query.watch().map(
      (List<ReadingSessionRow> rows) => rows.map(_toDomain).toList(growable: false),
    );
  }

  ReadingSession _toDomain(ReadingSessionRow row) => ReadingSession(
    id: row.id,
    bookId: row.bookId,
    startedAt: row.startedAt.toLocal(),
    endedAt: row.endedAt.toLocal(),
    characters: row.characters,
  );
}
