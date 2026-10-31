import 'package:freezed_annotation/freezed_annotation.dart';

part 'book.freezed.dart';

/// A book on the shelf.
///
/// [filePath] is the only place the absolute path appears in the domain model;
/// it never reaches a plugin or the logs (CODE_STYLE §12.4).
@freezed
abstract class Book with _$Book {
  const factory Book({
    /// 0 before the row is inserted.
    required int id,
    required String title,
    required String formatId,
    required String filePath,
    required int fileSizeBytes,
    required DateTime addedAt,
    String? author,
    String? coverPath,
    String? encoding,
    @Default(0) int chapterCount,
    DateTime? lastOpenedAt,
    DateTime? deletedAt,
  }) = _Book;

  const Book._();

  bool get isDeleted => deletedAt != null;
}
