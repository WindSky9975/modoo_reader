import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_progress.freezed.dart';

/// Where the reader stopped, per book, per device.
///
/// [deviceId] and [revision] exist for WebDAV conflict resolution: the newer
/// revision wins, and a device id makes the decision explainable
/// (DEVELOPMENT_PLAN §3.8).
@freezed
abstract class ReadingProgress with _$ReadingProgress {
  const factory ReadingProgress({
    required int bookId,
    required int chapterIndex,
    required int charOffset,
    required DateTime updatedAt,
    required String deviceId,
    @Default(0) int revision,
    @Default(0) int pageIndex,
  }) = _ReadingProgress;

  const ReadingProgress._();
}
