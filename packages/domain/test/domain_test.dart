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

  group('summarizeSessions', () {
    final DateTime today = DateTime(2026, 10, 31, 12);

    ReadingSession session(DateTime start, Duration duration, {int characters = 0}) =>
        ReadingSession(
          id: 0,
          bookId: 1,
          startedAt: start,
          endedAt: start.add(duration),
          characters: characters,
        );

    test('adds durations and characters across days', () {
      final ReadingStats stats = summarizeSessions(<ReadingSession>[
        session(DateTime(2026, 10, 31, 9), const Duration(minutes: 20), characters: 400),
        session(DateTime(2026, 10, 31, 21), const Duration(minutes: 10), characters: 100),
        session(DateTime(2026, 10, 30, 8), const Duration(minutes: 30), characters: 900),
      ], today: today);

      expect(stats.total, const Duration(minutes: 60));
      expect(stats.characters, 1400);
      expect(stats.sessionCount, 3);
      expect(stats.days, hasLength(2));
      expect(stats.durationOn(today), const Duration(minutes: 30));
    });

    test('counts consecutive days ending today', () {
      final ReadingStats stats = summarizeSessions(<ReadingSession>[
        session(DateTime(2026, 10, 31, 9), const Duration(minutes: 5)),
        session(DateTime(2026, 10, 30, 9), const Duration(minutes: 5)),
        session(DateTime(2026, 10, 29, 9), const Duration(minutes: 5)),
        session(DateTime(2026, 10, 26, 9), const Duration(minutes: 5)),
      ], today: today);

      expect(stats.streakDays, 3);
    });

    test('keeps the streak alive when today has no reading yet', () {
      final ReadingStats stats = summarizeSessions(<ReadingSession>[
        session(DateTime(2026, 10, 30, 9), const Duration(minutes: 5)),
        session(DateTime(2026, 10, 29, 9), const Duration(minutes: 5)),
      ], today: today);

      expect(stats.streakDays, 2);
    });

    test('ignores sessions that ended before they started', () {
      final ReadingStats stats = summarizeSessions(<ReadingSession>[
        ReadingSession(
          id: 0,
          bookId: 1,
          startedAt: DateTime(2026, 10, 31, 10),
          endedAt: DateTime(2026, 10, 31, 9),
          characters: 50,
        ),
      ], today: today);

      expect(stats.total, Duration.zero);
      expect(stats.characters, 50);
    });

    test('keeps only the most recent days when asked', () {
      final ReadingStats stats = summarizeSessions(
        <ReadingSession>[
          for (int day = 20; day <= 31; day++)
            session(DateTime(2026, 10, day, 9), const Duration(minutes: 1)),
        ],
        today: today,
        days: 3,
      );

      expect(stats.days, hasLength(3));
      expect(stats.days.last.day, DateTime(2026, 10, 31));
    });

    test('reports zero for an empty history', () {
      final ReadingStats stats = summarizeSessions(<ReadingSession>[], today: today);
      expect(stats.total, Duration.zero);
      expect(stats.streakDays, 0);
      expect(stats.days, isEmpty);
    });
  });
}
