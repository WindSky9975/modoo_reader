/// Storage: the Drift schema and the repositories that read it.
///
/// Queries live here and nowhere else: callers get entities from
/// modoo_domain, never rows (CODE_STYLE §10.2).
library;

export 'src/database/app_database.dart';
export 'src/database/tables.dart';
export 'src/repositories/drift_book_repository.dart';
export 'src/repositories/drift_chapter_repository.dart';
export 'src/repositories/drift_page_layout_repository.dart';
export 'src/repositories/drift_progress_repository.dart';
export 'src/repositories/drift_settings_repository.dart';
