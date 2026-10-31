import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modoo_data/modoo_data.dart';
import 'package:modoo_domain/modoo_domain.dart';
import 'package:modoo_l10n/modoo_l10n.dart';
import 'package:modoo_reader/src/features/reader/reading_session_recorder.dart';
import 'package:modoo_reader/src/features/stats/stats_page.dart';
import 'package:modoo_reader/src/providers/app_providers.dart';

/// In-memory stand-in for the sessions table.
final class _RecordingStatsRepository implements StatsRepository {
  final List<ReadingSession> sessions = <ReadingSession>[];

  @override
  Future<int> add(ReadingSession session) async {
    sessions.add(session);
    return sessions.length;
  }

  @override
  Stream<List<ReadingSession>> watchAll() => Stream<List<ReadingSession>>.value(sessions);
}

void main() {
  group('ReadingSessionRecorder', () {
    final DateTime start = DateTime(2026, 10, 31, 9);

    test('writes a session once the minimum duration passed', () async {
      final _RecordingStatsRepository repository = _RecordingStatsRepository();
      final ReadingSessionRecorder recorder = ReadingSessionRecorder(
        repository: repository,
        bookId: 7,
      )..start(start);
      recorder.addCharacters(500);

      await recorder.flush(start.add(const Duration(minutes: 20)));

      expect(repository.sessions, hasLength(1));
      final ReadingSession session = repository.sessions.single;
      expect(session.bookId, 7);
      expect(session.characters, 500);
      expect(session.duration, const Duration(minutes: 20));
    });

    test('drops a glance shorter than the minimum', () async {
      final _RecordingStatsRepository repository = _RecordingStatsRepository();
      final ReadingSessionRecorder recorder = ReadingSessionRecorder(
        repository: repository,
        bookId: 7,
      )..start(start);

      await recorder.flush(start.add(const Duration(seconds: 2)));

      expect(repository.sessions, isEmpty);
    });

    test('a second flush does not duplicate the session', () async {
      final _RecordingStatsRepository repository = _RecordingStatsRepository();
      final ReadingSessionRecorder recorder = ReadingSessionRecorder(
        repository: repository,
        bookId: 7,
      )..start(start);

      await recorder.flush(start.add(const Duration(minutes: 1)));
      await recorder.flush(start.add(const Duration(minutes: 2)));

      expect(repository.sessions, hasLength(1));
    });
  });

  testWidgets('statistics screen explains itself before any reading', (WidgetTester tester) async {
    final database = AppDatabase.memory();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          localizationsDelegates: ModooLocalizations.localizationsDelegates,
          supportedLocales: ModooLocalizations.supportedLocales,
          home: const StatsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The app bar and the empty state share the same title.
    expect(find.text('Reading stats'), findsWidgets);
    expect(find.textContaining('No reading yet'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await database.close();
  });

  testWidgets('statistics screen sums the recorded sessions', (WidgetTester tester) async {
    final database = AppDatabase.memory();
    final bookId = await DriftBookRepository(database).insert(
      Book(
        id: 0,
        title: 'Stats Book',
        formatId: 'txt',
        filePath: '/tmp/stats-book.txt',
        fileSizeBytes: 10,
        addedAt: DateTime.utc(2026),
        chapterCount: 1,
      ),
    );
    final DateTime now = DateTime.now();
    final int id = await DriftStatsRepository(database).add(
      ReadingSession(
        id: 0,
        bookId: bookId,
        startedAt: now.subtract(const Duration(minutes: 12)),
        endedAt: now,
        characters: 2400,
      ),
    );
    expect(id, greaterThan(0));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          localizationsDelegates: ModooLocalizations.localizationsDelegates,
          supportedLocales: ModooLocalizations.supportedLocales,
          home: const StatsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('12 min'), findsWidgets);
    expect(find.text('2400 chars'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await database.close();
  });
}
