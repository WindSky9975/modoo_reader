/// What a source returns to the search / reading UI.
///
/// These types are deliberately plain: no Flutter, no database, so the engine
/// can be exercised in unit tests without a widget tree.
library;

/// One hit from a source search.
final class SearchResult {
  const SearchResult({
    required this.title,
    required this.bookUrl,
    this.author,
    this.coverUrl,
    this.latestChapter,
  });

  final String title;
  final String bookUrl;
  final String? author;
  final String? coverUrl;
  final String? latestChapter;

  @override
  String toString() => 'SearchResult($title)';
}

/// One chapter link taken from a book outline page.
final class OutlineChapter {
  const OutlineChapter({required this.title, required this.url});

  final String title;
  final String url;
}

/// The chapter list of a book on a source.
final class BookOutline {
  const BookOutline({required this.title, required this.chapters});

  final String title;
  final List<OutlineChapter> chapters;
}

/// A source as the UI sees it. Implemented by `RuleBookSource` (M4).
abstract interface class BookSource {
  /// Stable id, usually `<rule id>@<host>`.
  String get id;

  /// Human name for the UI; the localized name wins when present.
  String get name;

  Future<List<SearchResult>> search(String keyword, {int page = 1});

  Future<BookOutline> outline(String bookUrl);

  Future<String> chapterText(String chapterUrl);
}
