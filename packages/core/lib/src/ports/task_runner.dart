import 'dart:async';

/// Moves CPU-heavy work off the UI isolate.
///
/// Note the deliberate limit: layout and pagination never go through here,
/// because `TextPainter` needs the UI isolate's font environment
/// (DEVELOPMENT_PLAN §3.5.3).
abstract interface class TaskRunner {
  Future<R> run<R>(FutureOr<R> Function() task);
}

/// Runs the task on the calling isolate. Useful in tests and on single-core
/// platforms where spawning is pure overhead.
final class InlineTaskRunner implements TaskRunner {
  const InlineTaskRunner();

  @override
  Future<R> run<R>(FutureOr<R> Function() task) async => await task();
}
