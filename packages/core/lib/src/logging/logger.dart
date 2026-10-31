import 'dart:developer' as developer;

/// Severity of a log line.
enum LogLevel { debug, info, warn, error }

/// Logging seam.
///
/// Never log book text, file paths, search queries or source payloads
/// (CODE_STYLE §12.4). Log what happened, not what the user was reading.
abstract base class ModooLogger {
  const ModooLogger();

  void log(LogLevel level, String message, {Object? error, StackTrace? stackTrace});

  void debug(String message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.debug, message, error: error, stackTrace: stackTrace);

  void info(String message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.info, message, error: error, stackTrace: stackTrace);

  void warn(String message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.warn, message, error: error, stackTrace: stackTrace);

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.error, message, error: error, stackTrace: stackTrace);
}

/// Writes to the Dart developer log (visible in DevTools and `flutter logs`).
final class DeveloperLogger extends ModooLogger {
  const DeveloperLogger({this.name = 'modoo'});

  final String name;

  @override
  void log(LogLevel level, String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(message, name: name, level: level.severity, error: error, stackTrace: stackTrace);
  }
}

/// Discards everything. Use in tests and in the no-telemetry default path.
final class SilentLogger extends ModooLogger {
  const SilentLogger();

  @override
  void log(LogLevel level, String message, {Object? error, StackTrace? stackTrace}) {}
}

extension on LogLevel {
  int get severity => switch (this) {
    LogLevel.debug => 500,
    LogLevel.info => 800,
    LogLevel.warn => 900,
    LogLevel.error => 1000,
  };
}
