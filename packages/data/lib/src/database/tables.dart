import 'package:drift/drift.dart';

/// The shelf.
///
/// Rows are never deleted for real before the user empties the trash, which is
/// why `deletedAt` exists: annotations and progress reference `bookId`.
@DataClassName('BookRow')
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text().withLength(min: 1, max: 500)();

  TextColumn get author => text().nullable()();

  TextColumn get formatId => text()();

  TextColumn get filePath => text().unique()();

  IntColumn get fileSizeBytes => integer()();

  TextColumn get coverPath => text().nullable()();

  TextColumn get encoding => text().nullable()();

  IntColumn get chapterCount => integer().withDefault(const Constant(0))();

  DateTimeColumn get addedAt => dateTime()();

  DateTimeColumn get lastOpenedAt => dateTime().nullable()();

  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/// Chapters of a book, ordered by [idx].
///
/// Offsets are the source of truth for position; nothing here depends on
/// layout, font size or screen size.
@DataClassName('ChapterRow')
class Chapters extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get bookId => integer().references(Books, #id)();

  IntColumn get idx => integer()();

  TextColumn get title => text()();

  IntColumn get startOffset => integer()();

  IntColumn get endOffset => integer()();

  IntColumn get wordCount => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{bookId, idx},
  ];
}

/// One reading position per book and device, synced through WebDAV.
@DataClassName('ProgressRow')
class ProgressRows extends Table {
  IntColumn get bookId => integer().references(Books, #id)();

  IntColumn get chapterIndex => integer()();

  IntColumn get charOffset => integer()();

  IntColumn get pageIndex => integer().withDefault(const Constant(0))();

  DateTimeColumn get updatedAt => dateTime()();

  TextColumn get deviceId => text()();

  IntColumn get revision => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{bookId, deviceId};
}
