/// One sentence (or paragraph) to speak.
final class Utterance {
  const Utterance({required this.text, this.language = 'zh-CN', this.rate = 1, this.pitch = 1});

  final String text;
  final String language;

  /// 0.5..2.0, platform-defined scale.
  final double rate;
  final double pitch;
}

/// Observable progress of a [TtsEngine].
sealed class TtsEvent {
  const TtsEvent();
}

/// Started speaking [Utterance].
final class TtsStarted extends TtsEvent {
  const TtsStarted(this.utterance);

  final Utterance utterance;
}

/// Finished the utterance normally.
final class TtsCompleted extends TtsEvent {
  const TtsCompleted();
}

/// Engine failed. [message] is log-safe English.
final class TtsFailed extends TtsEvent {
  const TtsFailed(this.message);

  final String message;
}

/// Converts text into speech.
///
/// Implementations own playback only; queueing, chapters and sleep timers
/// belong to the host (DEVELOPMENT_PLAN §5.3 M4).
abstract interface class TtsEngine {
  String get engineId;

  /// Whether the platform voice for [language] exists.
  Future<bool> isAvailable(String language);

  Future<void> speak(Utterance utterance);

  Future<void> stop();

  Stream<TtsEvent> get events;
}
