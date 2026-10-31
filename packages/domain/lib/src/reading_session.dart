import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_session.freezed.dart';

/// One stretch of reading, recorded when the reader leaves a book.
///
/// Sessions are the raw material for the statistics screen: they are small,
/// append-only rows, and every aggregate (today, this week, streak) is derived
/// from them in [summarizeSessions] rather than stored, so the numbers can be
/// recomputed if the definition changes.
@freezed
abstract class ReadingSession with _$ReadingSession {
  const factory ReadingSession({
    required int id,
    required int bookId,
    required DateTime startedAt,
    required DateTime endedAt,
    @Default(0) int characters,
  }) = _ReadingSession;

  const ReadingSession._();

  Duration get duration => endedAt.difference(startedAt);
}

/// Reading time on one calendar day (local time).
@freezed
abstract class ReadingDay with _$ReadingDay {
  const factory ReadingDay({
    required DateTime day,
    @Default(Duration.zero) Duration duration,
    @Default(0) int characters,
  }) = _ReadingDay;

  const ReadingDay._();
}

/// Aggregate shown on the statistics screen.
@freezed
abstract class ReadingStats with _$ReadingStats {
  const factory ReadingStats({
    @Default(Duration.zero) Duration total,
    @Default(0) int characters,
    @Default(0) int sessionCount,
    @Default(0) int streakDays,
    @Default(<ReadingDay>[]) List<ReadingDay> days,
  }) = _ReadingStats;

  const ReadingStats._();

  /// Reading time on the day [now] falls on.
  Duration durationOn(DateTime now) {
    final DateTime today = DateTime(now.year, now.month, now.day);
    for (final ReadingDay day in days) {
      if (day.day == today) return day.duration;
    }
    return Duration.zero;
  }

  /// Reading time over the trailing seven days, including today.
  Duration get lastSevenDays {
    if (days.isEmpty) return Duration.zero;
    final int cutoff =
        DateTime.now().millisecondsSinceEpoch - const Duration(days: 7).inMilliseconds;
    Duration sum = Duration.zero;
    for (final ReadingDay day in days) {
      if (day.day.millisecondsSinceEpoch >= cutoff) sum += day.duration;
    }
    return sum;
  }
}

/// Folds [sessions] into the numbers the statistics screen shows.
///
/// Everything is bucketed by local calendar day. [today] is passed in rather
/// than read from the clock so the streak logic stays testable.
ReadingStats summarizeSessions(
  List<ReadingSession> sessions, {
  required DateTime today,
  int days = 7,
}) {
  final DateTime todayStart = DateTime(today.year, today.month, today.day);
  final Map<DateTime, ({Duration duration, int characters})> byDay =
      <DateTime, ({Duration duration, int characters})>{};

  Duration total = Duration.zero;
  int characters = 0;
  for (final ReadingSession session in sessions) {
    // A clock that jumped backwards would otherwise produce negative time.
    final Duration duration = session.duration.isNegative ? Duration.zero : session.duration;
    total += duration;
    characters += session.characters;

    final DateTime localStart = session.startedAt.toLocal();
    final DateTime day = DateTime(localStart.year, localStart.month, localStart.day);
    final ({Duration duration, int characters}) previous =
        byDay[day] ?? (duration: Duration.zero, characters: 0);
    byDay[day] = (
      duration: previous.duration + duration,
      characters: previous.characters + session.characters,
    );
  }

  final List<ReadingDay> summaries =
      byDay.entries
          .map(
            (MapEntry<DateTime, ({Duration duration, int characters})> entry) => ReadingDay(
              day: entry.key,
              duration: entry.value.duration,
              characters: entry.value.characters,
            ),
          )
          .toList()
        ..sort((ReadingDay a, ReadingDay b) => a.day.compareTo(b.day));

  return ReadingStats(
    total: total,
    characters: characters,
    sessionCount: sessions.length,
    streakDays: _streak(byDay.keys, todayStart),
    days: summaries.length > days ? summaries.sublist(summaries.length - days) : summaries,
  );
}

/// Consecutive days with reading, ending today or yesterday.
///
/// Yesterday still counts as "current streak": a reader who has not read yet
/// today should not see their streak reset at midnight.
int _streak(Iterable<DateTime> readDays, DateTime todayStart) {
  final Set<DateTime> days = readDays.toSet();
  DateTime cursor = todayStart;
  if (!days.contains(cursor)) {
    cursor = todayStart.subtract(const Duration(days: 1));
    if (!days.contains(cursor)) return 0;
  }
  int streak = 0;
  while (days.contains(cursor)) {
    streak += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}
