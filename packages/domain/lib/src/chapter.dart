import 'package:freezed_annotation/freezed_annotation.dart';

part 'chapter.freezed.dart';

/// One chapter of a book.
///
/// [startOffset] and [endOffset] are character offsets into the decoded book
/// text; they stay valid across layouts, which is why reading progress is
/// stored as an offset and not as a page number.
@freezed
abstract class Chapter with _$Chapter {
  const factory Chapter({
    required int id,
    required int bookId,
    required int index,
    required String title,
    required int startOffset,
    required int endOffset,
    required int wordCount,
  }) = _Chapter;

  const Chapter._();

  int get length => endOffset - startOffset;
}
