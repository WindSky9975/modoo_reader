/// The only stable contract between modoo_reader and its plugins.
///
/// Rules for this package (CODE_STYLE §9):
/// - pure Dart: no Flutter, no `dart:io`, no other modoo_* dependency;
/// - additive changes only; anything breaking needs a major bump plus an ADR;
/// - every public member carries an English dartdoc, because plugin authors
///   read this package without the rest of the repo.
library;

export 'src/api_version.dart';
export 'src/book_format.dart';
export 'src/plugin.dart';
export 'src/sync.dart';
export 'src/tts.dart';
