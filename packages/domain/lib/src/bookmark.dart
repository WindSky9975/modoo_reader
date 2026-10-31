import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmark.freezed.dart';

/// A saved spot inside a book.
///
/// Like progress, the position is a `(chapterIndex, charOffset)` pair, so a
/// bookmark survives font size and screen size changes (ADR-0002). [excerpt]
/// is a short piece of the text at that offset so the list is recognisable
/// without opening the chapter; it is never used to relocate the bookmark.
@freezed
abstract class Bookmark with _$Bookmark {
  const factory Bookmark({
    /// 0 before the row is inserted.
    required int id,
    required int bookId,
    required int chapterIndex,

    /// Character offset relative to the start of the chapter body.
    required int charOffset,
    required String excerpt,
    required DateTime createdAt,
    String? note,
  }) = _Bookmark;

  const Bookmark._();
}
