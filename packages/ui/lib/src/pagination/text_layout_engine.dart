import 'package:flutter/painting.dart';
import 'package:modoo_reader_engine/modoo_reader_engine.dart';

/// The style every page of a [LayoutSpec] is measured and drawn with.
///
/// Both the paginator and the reader page call this, so a page break can never
/// disagree with the glyphs the user sees: one source of truth for family,
/// size, leading and letter spacing.
TextStyle readerTextStyle(LayoutSpec spec) => TextStyle(
  fontFamily: spec.fontFamily,
  fontSize: spec.fontSize,
  height: spec.lineHeight,
  letterSpacing: spec.letterSpacing,
);

/// Maps [LayoutSpec.textAlign] onto the Flutter alignment used for drawing.
TextAlign readerTextAlign(LayoutSpec spec) => switch (spec.textAlign) {
  LayoutTextAlign.start => TextAlign.start,
  LayoutTextAlign.justify => TextAlign.justify,
};

/// Measures a chapter with `TextPainter` and cuts it into pages.
///
/// Why here and not in `packages/reader`: `TextPainter.layout` needs the UI
/// isolate's font environment, so the engine cannot run in a background
/// isolate (DEVELOPMENT_PLAN §3.5.3). The contract stays in the reader package
/// so callers never import Flutter for pagination.
///
/// The algorithm is deliberately line based:
/// 1. lay the whole chapter out once at the content width,
/// 2. ask `getPositionForOffset` for the first character of every line,
/// 3. greedily fill pages until the next line would overflow.
///
/// Pages are therefore always cut on a line boundary, which keeps a page's
/// start offset renderable with any later `LayoutSpec` whose `layoutHash`
/// differs: a cache miss re-runs this method, never re-interprets old pages.
final class TextPainterLayoutEngine implements TextLayoutEngine {
  const TextPainterLayoutEngine();

  @override
  Future<List<PageSpan>> paginate(PaginationRequest request) async {
    final String text = request.text;
    if (text.isEmpty || request.pageWidth <= 0 || request.pageHeight <= 0) {
      return const <PageSpan>[];
    }

    final LayoutSpec spec = request.spec;
    final TextStyle style = readerTextStyle(spec);

    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: readerTextAlign(spec),
    );
    try {
      painter.layout(maxWidth: request.pageWidth);
      final List<LineMetrics> lines = painter.computeLineMetrics();
      if (lines.isEmpty) {
        return <PageSpan>[PageSpan(startOffset: 0, endOffset: text.length)];
      }

      final double paragraphGap = spec.paragraphSpacing * spec.fontSize;
      final List<int> lineStarts = <int>[];
      final List<double> lineHeights = <double>[];
      double top = 0;
      for (final LineMetrics line in lines) {
        lineStarts.add(painter.getPositionForOffset(Offset(0, top + line.height / 2)).offset);
        lineHeights.add(line.height);
        top += line.height;
      }
      // The first line always starts at 0 even if the text opens with spaces.
      lineStarts[0] = 0;

      final List<PageSpan> pages = <PageSpan>[];
      int pageStart = 0;
      double used = 0;
      for (int i = 0; i < lineStarts.length; i++) {
        final double lineHeight = lineHeights[i];
        final bool endsParagraph =
            i + 1 < lineStarts.length && _endsParagraph(text, lineStarts[i], lineStarts[i + 1]);
        final double needed = lineHeight + (endsParagraph ? paragraphGap : 0);
        if (pageStart != i && used + needed > request.pageHeight) {
          pages.add(PageSpan(startOffset: lineStarts[pageStart], endOffset: lineStarts[i]));
          pageStart = i;
          used = 0;
        }
        used += needed;
      }
      pages.add(PageSpan(startOffset: lineStarts[pageStart], endOffset: text.length));
      return pages;
    } finally {
      painter.dispose();
    }
  }

  /// True when the line's last character is a newline, i.e. a paragraph ends.
  static bool _endsParagraph(String text, int start, int nextStart) {
    if (nextStart <= start) return false;
    final int last = nextStart - 1;
    return last < text.length && text.codeUnitAt(last) == 0x0A;
  }
}
