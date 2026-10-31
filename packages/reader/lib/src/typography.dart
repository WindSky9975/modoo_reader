/// Typography maths that does not need a widget tree.
///
/// The reader keeps these rules here so they can be unit tested without
/// pumping a page: pinching and the font size slider have to agree on the
/// clamp range, otherwise the two entry points drift apart.
library;

/// Smallest font size the reader offers.
const double minReaderFontSize = 14;

/// Largest font size the reader offers.
const double maxReaderFontSize = 30;

/// Maps a two-finger pinch onto the next font size.
///
/// [startSpan] is the distance between the fingers when the pinch began and
/// [span] the current one, so spreading the fingers grows the text. The result
/// is a whole point size inside [minReaderFontSize]..[maxReaderFontSize]:
/// fractional sizes would re-paginate on every frame for no visible gain.
double pinchFontSize({required double startSize, required double startSpan, required double span}) {
  if (startSpan <= 0 || span <= 0) return startSize.clamp(minReaderFontSize, maxReaderFontSize);
  final double scaled = startSize * (span / startSpan);
  if (!scaled.isFinite) return startSize.clamp(minReaderFontSize, maxReaderFontSize);
  return scaled
      .clamp(minReaderFontSize, maxReaderFontSize)
      .roundToDouble()
      .clamp(minReaderFontSize, maxReaderFontSize);
}
