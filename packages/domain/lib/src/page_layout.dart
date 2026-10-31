import 'package:freezed_annotation/freezed_annotation.dart';

part 'page_layout.freezed.dart';

/// One page, expressed in character offsets of its chapter text.
///
/// This is the storage twin of `PageSpan` in `modoo_reader_engine`: the engine
/// produces spans, the domain persists them. Keeping the two apart means
/// modoo_data never has to depend on the layout engine, which is the layering
/// rule in CODE_STYLE §3.2.
@freezed
abstract class PageExtent with _$PageExtent {
  const factory PageExtent({required int startOffset, required int endOffset}) = _PageExtent;

  const PageExtent._();

  /// Characters on this page; [endOffset] is exclusive.
  int get length => endOffset - startOffset;
}

/// A pagination result for one chapter under one `layoutHash`.
///
/// Pure cache: dropping every row here only costs one re-layout, never data.
@freezed
abstract class CachedPageLayout with _$CachedPageLayout {
  const factory CachedPageLayout({
    required int bookId,
    required int chapterIndex,
    required int layoutHash,
    required List<PageExtent> pages,
    required DateTime computedAt,
  }) = _CachedPageLayout;

  const CachedPageLayout._();

  int get pageCount => pages.length;
}
