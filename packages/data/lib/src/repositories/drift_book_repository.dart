import 'package:drift/drift.dart';
import 'package:modoo_domain/modoo_domain.dart';

import '../database/app_database.dart';
import '../database/tables.dart';

/// Drift-backed [BookRepository].
final class DriftBookRepository implements BookRepository {
  DriftBookRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Book>> watchAll() {
    final query = _db.select(_db.books)
      ..where((Books table) => table.deletedAt.isNull())
      ..orderBy(<OrderClauseGenerator<$BooksTable>>[
        (Books table) => OrderingTerm.desc(table.lastOpenedAt),
        (Books table) => OrderingTerm.asc(table.title),
      ]);
    return query.watch().map((List<BookRow> rows) => rows.map(_toEntity).toList(growable: false));
  }

  @override
  Future<Book?> findById(int id) async {
    final row = await (_db.select(
      _db.books,
    )..where((Books table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<int> insert(Book book) => _db
      .into(_db.books)
      .insert(
        BooksCompanion.insert(
          title: book.title,
          formatId: book.formatId,
          filePath: book.filePath,
          fileSizeBytes: book.fileSizeBytes,
          addedAt: book.addedAt,
          author: Value<String?>(book.author),
          coverPath: Value<String?>(book.coverPath),
          encoding: Value<String?>(book.encoding),
          chapterCount: Value<int>(book.chapterCount),
        ),
      );

  @override
  Future<void> markOpened(int id, DateTime at) async {
    await (_db.update(_db.books)..where((Books table) => table.id.equals(id))).write(
      BooksCompanion(lastOpenedAt: Value<DateTime>(at)),
    );
  }

  @override
  Future<void> softDelete(int id) async {
    await (_db.update(_db.books)..where((Books table) => table.id.equals(id))).write(
      BooksCompanion(deletedAt: Value<DateTime>(DateTime.now().toUtc())),
    );
  }

  Book _toEntity(BookRow row) => Book(
    id: row.id,
    title: row.title,
    formatId: row.formatId,
    filePath: row.filePath,
    fileSizeBytes: row.fileSizeBytes,
    addedAt: row.addedAt,
    author: row.author,
    coverPath: row.coverPath,
    encoding: row.encoding,
    chapterCount: row.chapterCount,
    lastOpenedAt: row.lastOpenedAt,
    deletedAt: row.deletedAt,
  );
}
