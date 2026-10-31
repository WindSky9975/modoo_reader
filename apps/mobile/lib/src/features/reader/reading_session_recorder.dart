import 'dart:async';

import 'package:modoo_domain/modoo_domain.dart';

/// Accumulates one reading stretch and writes it as a [ReadingSession].
///
/// The clock is passed in rather than read from a [Stopwatch] so the flush can
/// be tested without waiting in real time; the reader starts it in `initState`
/// and flushes it from `dispose`.
final class ReadingSessionRecorder {
  ReadingSessionRecorder({
    required this.repository,
    required this.bookId,
    this.minimum = const Duration(seconds: 5),
  });

  final StatsRepository repository;
  final int bookId;

  /// Anything shorter is a glance, not reading, and is not recorded.
  final Duration minimum;

  DateTime? _startedAt;
  int _characters = 0;

  /// Characters the reader moved through; an upper bound, since a skimmed page
  /// still counts once.
  void addCharacters(int count) {
    if (count > 0) _characters += count;
  }

  void start(DateTime now) {
    _startedAt ??= now;
  }

  /// Writes the session if it is long enough; safe to call more than once.
  Future<void> flush(DateTime now) async {
    final DateTime? startedAt = _startedAt;
    if (startedAt == null) return;
    _startedAt = null;
    final Duration elapsed = now.difference(startedAt);
    if (elapsed < minimum) return;
    await repository.add(
      ReadingSession(
        id: 0,
        bookId: bookId,
        startedAt: startedAt,
        endedAt: now,
        characters: _characters,
      ),
    );
  }
}
