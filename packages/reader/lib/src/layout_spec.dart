import 'dart:convert';

/// How lines that do not end a paragraph are aligned.
///
/// Kept Flutter-free here (the reader contract has no widget dependency) and
/// translated to `TextAlign` in `packages/ui`, which owns the `TextPainter`.
enum LayoutTextAlign {
  /// Ragged right; the usual choice for CJK novels.
  start,

  /// Both edges flush; the last line of a paragraph stays ragged.
  justify,
}

/// Everything that changes line boxes, in one immutable value.
///
/// The layout hash is derived from this object and nothing else. Any field
/// that affects line breaking must be part of it, otherwise cached page
/// tables silently misplace text after an upgrade (DEVELOPMENT_PLAN §3.5.3).
final class LayoutSpec {
  const LayoutSpec({
    this.fontFamily = 'System',
    this.fontSize = 18,
    this.lineHeight = 1.6,
    this.paragraphSpacing = 0.6,
    this.horizontalPadding = 20,
    this.verticalPadding = 12,
    this.letterSpacing = 0,
    this.textAlign = LayoutTextAlign.start,
    this.fontVersion = 1,
    this.flags = Flags.none,
  });

  /// Family token resolved by the app; part of the hash because font metrics
  /// decide line breaks.
  final String fontFamily;

  /// Logical pixels.
  final double fontSize;

  /// Multiplier of [fontSize].
  final double lineHeight;

  /// Multiplier of [fontSize] applied between paragraphs.
  final double paragraphSpacing;

  final double horizontalPadding;
  final double verticalPadding;
  final double letterSpacing;

  /// Line alignment; part of the hash because justify changes line boxes.
  final LayoutTextAlign textAlign;

  /// Bumped whenever the shipped font files change: same name, new metrics.
  final int fontVersion;

  /// Typography toggles, see [Flags].
  final int flags;

  /// Characters the layout uses: derived, not stored, so it cannot drift.
  int get layoutHash {
    var hash = 0x811c9dc5;
    for (final unit in _canonical().codeUnits) {
      hash ^= unit & 0xff;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }

  /// Canonical, key-sorted representation used for hashing and for debugging.
  String _canonical() => jsonEncode(<String, Object?>{
    'flags': flags,
    'fontFamily': fontFamily,
    'fontSize': fontSize,
    'fontVersion': fontVersion,
    'horizontalPadding': horizontalPadding,
    'letterSpacing': letterSpacing,
    'lineHeight': lineHeight,
    'paragraphSpacing': paragraphSpacing,
    'textAlign': textAlign.name,
    'verticalPadding': verticalPadding,
  });

  LayoutSpec copyWith({
    String? fontFamily,
    double? fontSize,
    double? lineHeight,
    double? paragraphSpacing,
    double? horizontalPadding,
    double? verticalPadding,
    double? letterSpacing,
    LayoutTextAlign? textAlign,
    int? fontVersion,
    int? flags,
  }) => LayoutSpec(
    fontFamily: fontFamily ?? this.fontFamily,
    fontSize: fontSize ?? this.fontSize,
    lineHeight: lineHeight ?? this.lineHeight,
    paragraphSpacing: paragraphSpacing ?? this.paragraphSpacing,
    horizontalPadding: horizontalPadding ?? this.horizontalPadding,
    verticalPadding: verticalPadding ?? this.verticalPadding,
    letterSpacing: letterSpacing ?? this.letterSpacing,
    textAlign: textAlign ?? this.textAlign,
    fontVersion: fontVersion ?? this.fontVersion,
    flags: flags ?? this.flags,
  );

  @override
  String toString() => 'LayoutSpec(${_canonical()})';
}

/// Bit flags for typography switches that change line breaking.
abstract final class Flags {
  static const int none = 0;
  static const int punctuationSqueeze = 1 << 0;
  static const int hangingPunctuation = 1 << 1;
  static const int cjkLatinSpacing = 1 << 2;
  static const int traditionalConversion = 1 << 3;
}
