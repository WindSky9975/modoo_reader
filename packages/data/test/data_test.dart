import 'package:modoo_data/modoo_data.dart';
import 'package:modoo_domain/modoo_domain.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late DriftBookRepository books;
  late DriftChapterRepository chapters;
  late DriftProgressRepository progress;

  setUp(() {
    db = AppDatabase.memory();
    books = DriftBookRepository(db);
    chapters = DriftChapterRepository(db);
    progress = DriftProgressRepository(db);
  });

  tearDown(() => db.close());

  test('schema v4 creates the seven tables', () async {
    expect(db.schemaVersion, 4);
    final names = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .map((row) => row.read<String>('name'))
        .get();
    expect(
      names,
      containsAll(<String>[
        'books',
        'chapters',
        'progress_rows',
        'page_layouts',
        'app_settings',
        'bookmarks',
        'annotations',
      ]),
    );
  });

  test('inserts a book and reads it back through the entity', () async {
    final id = await books.insert(_book());
    final loaded = await books.findById(id);

    expect(loaded, isNotNull);
    expect(loaded!.title, '山海');
    expect(loaded.formatId, 'txt');
    expect(loaded.chapterCount, 0);
    expect(loaded.isDeleted, isFalse);
  });

  test('watchAll emits when the shelf changes', () async {
    final emissions = <List<Book>>[];
    final subscription = books.watchAll().listen(emissions.add);
    addTearDown(subscription.cancel);

    await books.insert(_book());
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(emissions, isNotEmpty);
    expect(emissions.last, hasLength(1));
  });

  test('soft delete hides the book from the shelf but keeps the row', () async {
    final id = await books.insert(_book());
    await books.softDelete(id);

    final shelf = await books.watchAll().first;
    expect(shelf, isEmpty);
    expect((await books.findById(id))!.isDeleted, isTrue);
  });

  test('chapters are returned in order', () async {
    final bookId = await books.insert(_book());
    for (final index in <int>[2, 0, 1]) {
      await db
          .into(db.chapters)
          .insert(
            ChaptersCompanion.insert(
              bookId: bookId,
              idx: index,
              title: '第 $index 章',
              startOffset: index * 100,
              endOffset: index * 100 + 100,
            ),
          );
    }

    final list = await chapters.listForBook(bookId);
    expect(list.map((chapter) => chapter.index), <int>[0, 1, 2]);
    expect((await chapters.findAt(bookId, 1))!.title, '第 1 章');
  });

  test('replaceAll swaps every chapter of one book atomically', () async {
    final bookId = await books.insert(_book());
    await chapters.replaceAll(bookId, <Chapter>[
      _chapter(bookId, 0, '楔子', 0, 100),
      _chapter(bookId, 1, '第一章', 100, 400),
    ]);
    await chapters.replaceAll(bookId, <Chapter>[_chapter(bookId, 0, '只有一章', 0, 50)]);

    final list = await chapters.listForBook(bookId);
    expect(list, hasLength(1));
    expect(list.single.title, '只有一章');
  });

  test('replaceAll with an empty list clears the chapters', () async {
    final bookId = await books.insert(_book());
    await chapters.replaceAll(bookId, <Chapter>[_chapter(bookId, 0, '第一章', 0, 10)]);
    await chapters.replaceAll(bookId, const <Chapter>[]);

    expect(await chapters.listForBook(bookId), isEmpty);
  });

  test('progress saves bump the revision and can be read back', () async {
    final bookId = await books.insert(_book());
    final first = ReadingProgress(
      bookId: bookId,
      chapterIndex: 3,
      charOffset: 120,
      updatedAt: DateTime.utc(2026, 10, 31),
      deviceId: 'device-a',
    );

    await progress.save(first);
    await progress.save(first);

    final stored = await progress.read(bookId);
    expect(stored, isNotNull);
    expect(stored!.chapterIndex, 3);
    expect(stored.charOffset, 120);
    expect(stored.revision, 2);
  });

  test('page layouts are cached per layout hash', () async {
    final layouts = DriftPageLayoutRepository(db);
    final bookId = await books.insert(_book());
    final layout = CachedPageLayout(
      bookId: bookId,
      chapterIndex: 0,
      layoutHash: 12345,
      pages: const <PageExtent>[
        PageExtent(startOffset: 0, endOffset: 100),
        PageExtent(startOffset: 100, endOffset: 260),
      ],
      computedAt: DateTime.utc(2026, 10, 31),
    );

    await layouts.write(layout);
    final hit = await layouts.read(bookId: bookId, chapterIndex: 0, layoutHash: 12345);
    expect(hit, isNotNull);
    expect(hit!.pages, hasLength(2));
    expect(hit.pages.last.endOffset, 260);

    final miss = await layouts.read(bookId: bookId, chapterIndex: 0, layoutHash: 999);
    expect(miss, isNull);
  });

  test('rewriting the same page layout replaces instead of duplicating', () async {
    final layouts = DriftPageLayoutRepository(db);
    final bookId = await books.insert(_book());
    CachedPageLayout layout(int end) => CachedPageLayout(
      bookId: bookId,
      chapterIndex: 1,
      layoutHash: 7,
      pages: <PageExtent>[PageExtent(startOffset: 0, endOffset: end)],
      computedAt: DateTime.utc(2026, 10, 31),
    );

    await layouts.write(layout(50));
    await layouts.write(layout(80));

    final hit = await layouts.read(bookId: bookId, chapterIndex: 1, layoutHash: 7);
    expect(hit!.pages.single.endOffset, 80);
    final rows = await db.select(db.pageLayouts).get();
    expect(rows, hasLength(1));
  });

  test('stale page layouts can be deleted', () async {
    final layouts = DriftPageLayoutRepository(db);
    final bookId = await books.insert(_book());
    await layouts.write(
      CachedPageLayout(
        bookId: bookId,
        chapterIndex: 0,
        layoutHash: 1,
        pages: const <PageExtent>[PageExtent(startOffset: 0, endOffset: 10)],
        computedAt: DateTime.utc(2026),
      ),
    );

    final deleted = await layouts.deleteOlderThan(DateTime.utc(2026, 6));
    expect(deleted, 1);
    expect(await layouts.read(bookId: bookId, chapterIndex: 0, layoutHash: 1), isNull);
  });

  test('reader settings round-trip and clamp out-of-range values', () async {
    final settings = DriftSettingsRepository(db);
    expect(await settings.read(), ReaderSettings.defaults);

    await settings.save(
      const ReaderSettings(fontSize: 40, lineHeight: 5, themeId: 'night', pageTurnId: 'none'),
    );

    final stored = await settings.read();
    expect(stored.fontSize, 30);
    expect(stored.lineHeight, 2.4);
    expect(stored.themeId, 'night');
    expect(stored.pageTurnId, 'none');
  });

  test('deleting every page layout of a book keeps other books intact', () async {
    final layouts = DriftPageLayoutRepository(db);
    final first = await books.insert(_book());
    final second = await books.insert(_book(path: '/books/shanhai-$first.txt'));
    for (final bookId in <int>[first, second]) {
      await layouts.write(
        CachedPageLayout(
          bookId: bookId,
          chapterIndex: 0,
          layoutHash: 1,
          pages: const <PageExtent>[PageExtent(startOffset: 0, endOffset: 10)],
          computedAt: DateTime.utc(2026, 10, 31),
        ),
      );
    }

    await layouts.deleteForBook(first);

    expect(await layouts.read(bookId: first, chapterIndex: 0, layoutHash: 1), isNull);
    expect(await layouts.read(bookId: second, chapterIndex: 0, layoutHash: 1), isNotNull);
  });

  test('bookmarks are listed in reading order and can be deleted', () async {
    final bookmarks = DriftBookmarkRepository(db);
    final bookId = await books.insert(_book());
    await bookmarks.add(_bookmark(bookId, chapterIndex: 1, charOffset: 5, excerpt: '第二章开头'));
    await bookmarks.add(_bookmark(bookId, charOffset: 120, excerpt: '第一章中段'));

    final listed = await bookmarks.watchForBook(bookId).first;
    expect(listed.map((Bookmark b) => b.chapterIndex), <int>[0, 1]);
    expect(listed.first.excerpt, '第一章中段');

    await bookmarks.delete(listed.first.id);
    expect((await bookmarks.watchForBook(bookId).first).length, 1);
  });

  test('bookmarking the same spot twice updates the note instead of duplicating', () async {
    final bookmarks = DriftBookmarkRepository(db);
    final bookId = await books.insert(_book());
    final first = await bookmarks.add(_bookmark(bookId, note: '第一印象'));
    final second = await bookmarks.add(_bookmark(bookId, note: '改过的备注'));

    expect(second, first);
    final listed = await bookmarks.watchForBook(bookId).first;
    expect(listed, hasLength(1));
    expect(listed.single.note, '改过的备注');
  });

  test('annotations are listed in reading order and can be deleted', () async {
    final annotations = DriftAnnotationRepository(db);
    final bookId = await books.insert(_book());
    await annotations.add(_annotation(bookId, chapterIndex: 1, endOffset: 40, body: '第二章的批注'));
    await annotations.add(_annotation(bookId, startOffset: 100, endOffset: 160, body: '第一章中段的想法'));

    final listed = await annotations.watchForBook(bookId).first;
    expect(listed.map((Annotation a) => a.chapterIndex), <int>[0, 1]);
    expect(listed.first.body, '第一章中段的想法');
    expect(listed.first.length, 60);

    await annotations.delete(listed.first.id);
    expect((await annotations.watchForBook(bookId).first).length, 1);
  });

  test('annotating the same paragraph twice replaces the body', () async {
    final annotations = DriftAnnotationRepository(db);
    final bookId = await books.insert(_book());
    final first = await annotations.add(
      _annotation(bookId, startOffset: 10, endOffset: 80, body: '第一版'),
    );
    final second = await annotations.add(
      _annotation(bookId, startOffset: 10, endOffset: 88, body: '第二版'),
    );

    expect(second, first);
    final listed = await annotations.watchForBook(bookId).first;
    expect(listed, hasLength(1));
    expect(listed.single.body, '第二版');
    expect(listed.single.endOffset, 88);
  });
}

Book _book({String path = '/books/shanhai.txt'}) => Book(
  id: 0,
  title: '山海',
  formatId: 'txt',
  filePath: path,
  fileSizeBytes: 2048,
  addedAt: DateTime.utc(2026, 10, 31),
);

Chapter _chapter(int bookId, int index, String title, int start, int end) => Chapter(
  id: index + 1,
  bookId: bookId,
  index: index,
  title: title,
  startOffset: start,
  endOffset: end,
  wordCount: end - start,
);

Bookmark _bookmark(
  int bookId, {
  int chapterIndex = 0,
  int charOffset = 0,
  String excerpt = '摘录',
  String? note,
}) => Bookmark(
  id: 0,
  bookId: bookId,
  chapterIndex: chapterIndex,
  charOffset: charOffset,
  excerpt: excerpt,
  note: note,
  createdAt: DateTime.utc(2026, 10, 31),
);

Annotation _annotation(
  int bookId, {
  int chapterIndex = 0,
  int startOffset = 0,
  int endOffset = 20,
  String excerpt = '被批注的段落',
  String body = '',
}) => Annotation(
  id: 0,
  bookId: bookId,
  chapterIndex: chapterIndex,
  startOffset: startOffset,
  endOffset: endOffset,
  excerpt: excerpt,
  body: body,
  createdAt: DateTime.utc(2026, 10, 31),
);
