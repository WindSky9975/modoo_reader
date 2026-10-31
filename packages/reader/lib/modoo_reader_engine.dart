/// The pagination engine: text in, pages out.
///
/// Pure Dart on purpose: splitting and layout math must be testable without a
/// widget tree, and the Flutter-side renderer (`TextPainter`) lives in
/// packages/ui. See DEVELOPMENT_PLAN §3.5.
library;

export 'src/chapter_splitter.dart';
export 'src/layout_spec.dart';
export 'src/pagination.dart';
export 'src/search.dart';
