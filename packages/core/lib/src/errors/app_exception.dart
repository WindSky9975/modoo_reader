/// The closed set of failures the app knows how to present to a user.
///
/// Every layer translates low-level failures into exactly one of these before
/// they cross a boundary (CODE_STYLE §11, appendix B.3). A `catch (e)` that
/// rethrows a raw `FileSystemException` is a review blocker.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause, this.stackTrace});

  /// English, log-safe, no user data. The UI maps [code] to localized text.
  final String message;

  final Object? cause;
  final StackTrace? stackTrace;

  /// Stable machine-readable identifier, also used as the l10n key suffix.
  String get code;

  @override
  String toString() => '$runtimeType($code): $message';
}

/// Reading or writing local state failed (file, database, preferences).
///
/// [message] must not contain absolute paths: paths are user data.
final class StorageException extends AppException {
  const StorageException(super.message, {super.cause, super.stackTrace});

  @override
  String get code => 'storage';
}

/// A file was readable but its content was invalid (truncated, malformed).
final class ParseException extends AppException {
  const ParseException(super.message, {super.cause, super.stackTrace});

  @override
  String get code => 'parse';
}

/// No plugin claims the format, or the plugin refused it.
final class UnsupportedFormatException extends AppException {
  const UnsupportedFormatException(super.message, {this.formatId, super.cause, super.stackTrace});

  final String? formatId;

  @override
  String get code => 'unsupported_format';
}

/// A network request failed or was cancelled.
final class NetworkException extends AppException {
  const NetworkException(super.message, {this.statusCode, super.cause, super.stackTrace});

  final int? statusCode;

  @override
  String get code => 'network';
}

/// A plugin misbehaved: bad manifest, failed registration, contract violation.
final class PluginException extends AppException {
  const PluginException(super.message, {this.pluginId, super.cause, super.stackTrace});

  final String? pluginId;

  @override
  String get code => 'plugin';
}

/// WebDAV sync failed (transport, auth, remote conflict).
final class SyncException extends AppException {
  const SyncException(super.message, {super.cause, super.stackTrace});

  @override
  String get code => 'sync';
}
