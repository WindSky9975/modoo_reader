import 'package:freezed_annotation/freezed_annotation.dart';

part 'reader_settings.freezed.dart';

/// Typography the reader remembers between launches.
///
/// Ids are strings on purpose: a new theme or page-turn mode ships without a
/// database migration. Unknown ids fall back to the defaults at render time.
@freezed
abstract class ReaderSettings with _$ReaderSettings {
  const factory ReaderSettings({
    @Default(18) double fontSize,
    @Default(1.6) double lineHeight,
    @Default('paper') String themeId,
    @Default('slide') String pageTurnId,
    @Default('system') String fontFamilyId,
    @Default(0.6) double paragraphSpacing,
    @Default(2) double firstLineIndent,
    @Default(20) double horizontalPadding,
    @Default('start') String textAlignId,
  }) = _ReaderSettings;

  const ReaderSettings._();

  /// The same values `buildAppTheme` and the reader sliders start from.
  static const ReaderSettings defaults = ReaderSettings();

  /// Keeps sliders and stored values inside the range the UI exposes.
  ReaderSettings normalized() => copyWith(
    fontSize: fontSize.clamp(14, 30),
    lineHeight: lineHeight.clamp(1.2, 2.4),
    paragraphSpacing: paragraphSpacing.clamp(0, 1.5),
    firstLineIndent: firstLineIndent.clamp(0, 4),
    horizontalPadding: horizontalPadding.clamp(8, 40),
  );
}
