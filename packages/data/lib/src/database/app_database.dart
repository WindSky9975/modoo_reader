import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// The single database of the app.
///
/// Migration policy (AGENTS.md hard rule 3): released branches are frozen.
/// Only ever append a new `if (from < N)` step; never edit history and never
/// rename or repurpose a column. The schema version starts at 1 in M0 and every
/// later milestone appends its own step.
@DriftDatabase(
  tables: <Type>[
    Books,
    Chapters,
    ProgressRows,
    PageLayouts,
    AppSettings,
    Bookmarks,
    Annotations,
    ReadingSessions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Opens (or creates) the database file at [path].
  ///
  /// Runs on a background isolate: the first query must never block the frame
  /// that shows the shelf (CODE_STYLE §11.1).
  factory AppDatabase.openAt(String path) =>
      AppDatabase(NativeDatabase.createInBackground(File(path)));

  /// In-memory database for tests.
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) => migrator.createAll(),
    onUpgrade: (Migrator migrator, int from, int to) async {
      // Append steps here; never modify the branches above.
      // v2: pagination cache + settings, both new tables (M2).
      if (from < 2) {
        await migrator.createTable(pageLayouts);
        await migrator.createTable(appSettings);
      }
      // v3: bookmarks (M2).
      if (from < 3) {
        await migrator.createTable(bookmarks);
      }
      // v4: paragraph annotations (M2).
      if (from < 4) {
        await migrator.createTable(annotations);
      }
      // v5: reading sessions for the statistics screen (M2).
      if (from < 5) {
        await migrator.createTable(readingSessions);
      }
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
