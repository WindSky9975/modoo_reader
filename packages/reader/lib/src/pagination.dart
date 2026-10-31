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
