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
@DriftDatabase(tables: <Type>[Books, Chapters, ProgressRows])
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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) => migrator.createAll(),
    onUpgrade: (Migrator migrator, int from, int to) async {
      // Append steps here, e.g.:
      // if (from < 2) await migrator.addColumn(books, books.someColumn);
      // Never modify the branches above: they already ran on user devices.
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
