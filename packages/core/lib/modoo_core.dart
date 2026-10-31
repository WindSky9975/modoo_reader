/// Platform-agnostic foundations shared by every business package.
///
/// Anything here must stay free of Flutter and `dart:io` so that it can run in
/// an isolate, in a test and (later) on Web.
library;

export 'src/errors/app_exception.dart';
export 'src/logging/logger.dart';
export 'src/ports/file_system_port.dart';
export 'src/ports/task_runner.dart';
export 'src/text/encoding.dart';
