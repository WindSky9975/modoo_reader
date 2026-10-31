import 'chapter_splitter.dart';

/// One hit of an in-book search.
///
/// Positions are `(chapterIndex, charOffset)` inside the chapter text, the same
/// coordinate the reader stores as reading progress, so tapping a result is a
/// plain jump (DEVELOPMENT_PLAN §3.5.4).
final class SearchHit {
  const SearchHit({
    required this.chapterIndex,
    required this.chapterTitle,
    required this.charOffset,
    required this.length,
    required this.snippet,
  });

  /// Index of the chapter that contains the hit.
  final int chapterIndex;

  /// Chapter title, for the result list.
  final String chapterTitle;

  /// Offset of the first matched character inside the chapter text.
  final int charOffset;

  /// Length of the match, in UTF-16 code units.
  final int length;

  /// A short window around the match, with the match left in place.
  final String snippet;

  @override
  String toString() => 'SearchHit($chapterIndex@$charOffset "$snippet")';
}

/// Searches [text] (a whole book, decoded as UTF-8) for [query].
///
/// Matching is case-insensitive and literal: no regex, so a query with `.*`
/// finds that text instead of matching everything. Results are returned in
/// reading order and capped by [maxHits]; a blank query returns an empty list.
///
/// Kept in this package (pure Dart, no Flutter) so the app can run it off the
/// UI isolate for large books without a rewrite.
List<SearchHit> searchBook({
  required String text,
  required List<ChapterSpan> chapters,
  required String query,
  int maxHits = 200,
  int snippetRadius = 18,
}) {
  final String needle = query.trim();
  if (needle.isEmpty || chapters.isEmpty || maxHits <= 0) {
    return const <SearchHit>[];
  }
  final String haystack = text.toLowerCase();
  final String loweredNeedle = needle.toLowerCase();
  final List<SearchHit> hits = <SearchHit>[];

  int chapterIndex = 0;
  for (
    int at = haystack.indexOf(loweredNeedle);
    at >= 0;
    at = haystack.indexOf(loweredNeedle, at + loweredNeedle.length)
  ) {
    while (chapterIndex + 1 < chapters.length && at >= chapters[chapterIndex + 1].startOffset) {
      chapterIndex++;
    }
    final ChapterSpan chapter = chapters[chapterIndex];
    if (at < chapter.startOffset || at >= chapter.endOffset) {
      // Matches that straddle a chapter break belong to the chapter they start
      // in; a match starting before the first chapter is impossible but guard
      // anyway so the offsets stay inside the chapter.
      continue;
    }
    final int from = (at - snippetRadius).clamp(chapter.startOffset, chapter.endOffset);
    final int to = (at + needle.length + snippetRadius).clamp(from, chapter.endOffset);
    hits.add(
      SearchHit(
        chapterIndex: chapterIndex,
        chapterTitle: chapter.title,
        charOffset: at - chapter.startOffset,
        length: needle.length,
        snippet: text.substring(from, to).replaceAll('\n', ' ').trim(),
      ),
    );
    if (hits.length >= maxHits) break;
  }
  return hits;
}
