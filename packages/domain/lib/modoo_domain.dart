/// The business model: immutable entities plus the contracts that read and
/// write them.
///
/// This package knows nothing about Flutter, SQL or files; implementations
/// live in modoo_data (CODE_STYLE §3.2).
library;

export 'src/book.dart';
export 'src/bookmark.dart';
export 'src/chapter.dart';
export 'src/page_layout.dart';
export 'src/reader_settings.dart';
export 'src/reading_progress.dart';
export 'src/repositories.dart';
