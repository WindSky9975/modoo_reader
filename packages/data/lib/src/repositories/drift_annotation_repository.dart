import 'package:drift/drift.dart';
import 'package:modoo_domain/modoo_domain.dart';

import '../database/app_database.dart';
import '../database/tables.dart';

/// Drift-backed [AnnotationRepository].
///
/// `(bookId, chapterIndex, startOffset)` is unique, so annotating the same
/// paragraph again replaces the body instead of stacking duplicates.
final class DriftAnnotationRepository implements AnnotationRepository {
  DriftAnnotationRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Annotation>> watchForBook(int bookId) {
    final SimpleSelectStatement<Annotations, AnnotationRow> query = _db.select(_db.annotations)
      ..where((Annotations table) => table.bookId.equals(bookId));
    query.orderBy(<OrderClauseGenerator<Annotations>>[
      (Annotations table) => OrderingTerm.asc(table.chapterIndex),
      (Annotations table) => OrderingTerm.asc(table.startOffset),
    ]);
    return query.watch().map(
      (List<AnnotationRow> rows) => rows.map(_toDomain).toList(growable: false),
    );
  }

  @override
  Future<int> add(Annotation annotation) async {
    await _db
        .into(_db.annotations)
        .insert(
          AnnotationsCompanion.insert(
            bookId: annotation.bookId,
            chapterIndex: annotation.chapterIndex,
            startOffset: annotation.startOffset,
            endOffset: annotation.endOffset,
            excerpt: annotation.excerpt,
            body: annotation.body,
            createdAt: annotation.createdAt,
          ),
          onConflict: DoUpdate(
            (Annotations old) => AnnotationsCompanion(
              endOffset: Value<int>(annotation.endOffset),
              excerpt: Value<String>(annotation.excerpt),
              body: Value<String>(annotation.body),
              createdAt: Value<DateTime>(annotation.createdAt),
            ),
            target: <Column<Object>>[
              _db.annotations.bookId,
              _db.annotations.chapterIndex,
              _db.annotations.startOffset,
            ],
          ),
        );
    final AnnotationRow row =
        await (_db.select(_db.annotations)..where(
              (Annotations table) =>
                  table.bookId.equals(annotation.bookId) &
                  table.chapterIndex.equals(annotation.chapterIndex) &
                  table.startOffset.equals(annotation.startOffset),
            ))
            .getSingle();
    return row.id;
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.annotations)..where((Annotations table) => table.id.equals(id))).go();
  }

  static Annotation _toDomain(AnnotationRow row) => Annotation(
    id: row.id,
    bookId: row.bookId,
    chapterIndex: row.chapterIndex,
    startOffset: row.startOffset,
    endOffset: row.endOffset,
    excerpt: row.excerpt,
    body: row.body,
    createdAt: row.createdAt,
  );
}
