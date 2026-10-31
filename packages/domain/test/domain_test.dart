import 'package:modoo_domain/modoo_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Book', () {
    final addedAt = DateTime.utc(2026, 10, 31);

    test('is a value type', () {
      final a = Book(
        id: 1,
        title: '山海',
        formatId: 'txt',
        filePath: '/books/a.txt',
        fileSizeBytes: 1024,
        addedAt: addedAt,
      );
      final b = a.copyWith(title: '山海');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a.isDeleted, isFalse);
    });

    test('copyWith cannot be used to mutate', () {
      final book = Book(
        id: 1,
        title: '山海',
        formatId: 'txt',
        filePath: '/books/a.txt',
        fileSizeBytes: 1024,
        addedAt: addedAt,
      );
      final deleted = book.copyWith(deletedAt: addedAt);
      expect(book.isDeleted, isFalse);
      expect(deleted.isDeleted, isTrue);
    });
  });

  group('Chapter', () {
    test('length derives from offsets', () {
      const chapter = Chapter(
        id: 1,
        bookId: 1,
        index: 0,
        title: '第一章',
        startOffset: 10,
        endOffset: 30,
        wordCount: 20,
      );
      expect(chapter.length, 20);
    });
  });

  group('ReadingProgress', () {
    test('defaults revision and page index', () {
      final progress = ReadingProgress(
        bookId: 1,
        chapterIndex: 2,
        charOffset: 100,
        updatedAt: DateTime.utc(2026, 10, 31),
        deviceId: 'device-a',
      );
      expect(progress.revision, 0);
      expect(progress.pageIndex, 0);
    });
  });
}
