import 'layout_spec.dart';

/// A page expressed in character offsets of its chapter text.
///
/// Offsets, not line boxes: the same page can be re-rendered at any DPI and
/// progress stays valid across devices (DEVELOPMENT_PLAN §3.5.3).
final class PageSpan {
  const PageSpan({required this.startOffset, required this.endOffset});

  final int startOffset;

  /// Exclusive.
  final int endOffset;

  @override
  String toString() => 'PageSpan($startOffset..$endOffset)';
}

/// Input of one pagination run.
final class PaginationRequest {
  const PaginationRequest({
    required this.chapterIndex,
    required this.text,
    required this.spec,
    required this.pageWidth,
    required this.pageHeight,
  });

  final int chapterIndex;
  final String text;
  final LayoutSpec spec;

  /// Content box in logical pixels, padding already removed.
  final double pageWidth;
  final double pageHeight;
}

/// Pagination seam.
///
/// The only implementation that ships measures text with `TextPainter`, which
/// requires the UI isolate's font environment: it therefore lives in
/// packages/ui and is exercised by widget tests, while the contract stays
/// here so callers do not depend on Flutter.
abstract interface class TextLayoutEngine {
  Future<List<PageSpan>> paginate(PaginationRequest request);
}

/// Index of the page that contains [charOffset].
///
/// Offsets are the only position that survives a font-size change, so the
/// reader restores by offset and then asks this function which page to show
/// (DEVELOPMENT_PLAN §3.5.4). Returns 0 for an empty page list and clamps to
/// the last page when the offset is past the end.
int pageIndexForOffset(List<PageSpan> pages, int charOffset) {
  if (pages.isEmpty) return 0;
  for (int i = 0; i < pages.length; i++) {
    if (charOffset < pages[i].endOffset) return i;
  }
  return pages.length - 1;
}

/// The page that contains [charOffset], or `null` when there are no pages.
PageSpan? pageForOffset(List<PageSpan> pages, int charOffset) {
  if (pages.isEmpty) return null;
  return pages[pageIndexForOffset(pages, charOffset)];
}
