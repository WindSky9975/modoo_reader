import 'package:freezed_annotation/freezed_annotation.dart';

part 'annotation.freezed.dart';

/// A reader's own remark on a paragraph.
///
/// The reference app calls these "段评" and hangs them off the end of a
/// paragraph, but comments there are social data that need a backend. This is
/// the local equivalent: the note belongs to the reader alone, is stored in the
/// same SQLite file as progress and bookmarks, and never leaves the device.
///
/// The anchor is the paragraph's character range inside the chapter body, so it
/// survives font size and screen size changes for the same reason progress does
/// (ADR-0002). [excerpt] is for list display only.
@freezed
abstract class Annotation with _$Annotation {
  const factory Annotation({
    /// 0 before the row is inserted.
    required int id,
    required int bookId,
    required int chapterIndex,

    /// Character offset of the paragraph start, relative to the chapter body.
    required int startOffset,

    /// Character offset one past the paragraph's last character.
    required int endOffset,
    required String excerpt,
    required String body,
    required DateTime createdAt,
  }) = _Annotation;

  const Annotation._();

  /// Length of the quoted paragraph, in UTF-16 code units.
  int get length => endOffset - startOffset;
}
