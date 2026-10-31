import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:modoo_domain/modoo_domain.dart';

import '../database/app_database.dart';
import '../database/tables.dart';

/// Drift-backed [PageLayoutRepository].
///
/// Rows are pure cache. Reading with a stale `layoutHash` simply misses and the
/// caller re-lays out (DEVELOPMENT_PLAN §3.5.3).
final class DriftPageLayoutRepository implements PageLayoutRepository {
  DriftPageLayoutRepository(this._db);

  final AppDatabase _db;

  @override
  Future<CachedPageLayout?> read({
    required int bookId,
    required int chapterIndex,
    required int layoutHash,
  }) async {
    final PageLayoutRow? row =
        await (_db.select(_db.pageLayouts)..where(
              (PageLayouts table) =>
                  table.bookId.equals(bookId) &
                  table.chapterIndex.equals(chapterIndex) &
                  table.layoutHash.equals(layoutHash),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return CachedPageLayout(
      bookId: row.bookId,
      chapterIndex: row.chapterIndex,
      layoutHash: row.layoutHash,
      pages: _decodeSpans(row.spans),
      computedAt: row.computedAt,
    );
  }

  @override
  Future<void> write(CachedPageLayout layout) async {
    // The natural key is (bookId, chapterIndex, layoutHash), not the auto
    // increment id, so a plain `insertOnConflictUpdate` would not upsert.
    await _db
        .into(_db.pageLayouts)
        .insert(
          PageLayoutsCompanion.insert(
            bookId: layout.bookId,
            chapterIndex: layout.chapterIndex,
            layoutHash: layout.layoutHash,
            pageCount: Value<int>(layout.pageCount),
            spans: _encodeSpans(layout.pages),
            computedAt: layout.computedAt,
          ),
          onConflict: DoUpdate(
            (PageLayouts old) => PageLayoutsCompanion(
              pageCount: Value<int>(layout.pageCount),
              spans: Value<String>(_encodeSpans(layout.pages)),
              computedAt: Value<DateTime>(layout.computedAt),
            ),
            target: <Column<Object>>[
              _db.pageLayouts.bookId,
              _db.pageLayouts.chapterIndex,
              _db.pageLayouts.layoutHash,
            ],
          ),
        );
  }

  @override
  Future<void> deleteForBook(int bookId) async {
    await (_db.delete(
      _db.pageLayouts,
    )..where((PageLayouts table) => table.bookId.equals(bookId))).go();
  }

  @override
  Future<int> deleteOlderThan(DateTime before) => (_db.delete(
    _db.pageLayouts,
  )..where((PageLayouts table) => table.computedAt.isSmallerThanValue(before))).go();

  static String _encodeSpans(List<PageExtent> pages) => jsonEncode(
    pages.map((PageExtent page) => <int>[page.startOffset, page.endOffset]).toList(growable: false),
  );

  static List<PageExtent> _decodeSpans(String encoded) {
    final Object? decoded = jsonDecode(encoded);
    if (decoded is! List<Object?>) return const <PageExtent>[];
    return decoded
        .whereType<List<Object?>>()
        .map(
          (List<Object?> pair) =>
              PageExtent(startOffset: pair[0]! as int, endOffset: pair[1]! as int),
        )
        .toList(growable: false);
  }
}
