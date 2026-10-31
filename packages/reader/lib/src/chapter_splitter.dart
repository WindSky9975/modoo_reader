/// A chapter's position in the decoded book text.
///
/// Offsets are the single source of truth for reading progress
/// (DEVELOPMENT_PLAN §3.5.1): chapter index plus character offset survives
/// changes to font size, screen size and layout algorithm.
final class ChapterSpan {
  const ChapterSpan({
    required this.index,
    required this.title,
    required this.startOffset,
    required this.endOffset,
  });

  final int index;
  final String title;

  /// Inclusive character offset into the book text.
  final int startOffset;

  /// Exclusive character offset.
  final int endOffset;

  int get length => endOffset - startOffset;

  @override
  String toString() => 'ChapterSpan(#$index "$title" $startOffset..$endOffset)';
}

/// Splits a decoded TXT book into chapters by heading pattern.
///
/// Deliberately conservative: a false positive costs one odd chapter title, a
/// false negative costs a giant "chapter 1" that breaks progress and
/// pre-pagination, so the pattern anchors on a whole line.
final class ChapterSplitter {
  const ChapterSplitter({
    this.pattern = defaultPattern,
    this.maxTitleLength = 40,
    this.fallbackTitle = 'Chapter 1',
  });

  /// Common Chinese and English chapter headings on their own line.
  static const String defaultPattern =
      r'^[ \t\u3000]*(?:第[0-9零一二三四五六七八九十百千万两]+[章节回卷][^\n]{0,30}|(?:Chapter|CHAPTER)\s+[0-9]+[^\n]{0,30})[ \t\u3000]*$';

  final String pattern;

  /// Longer "headings" are almost always prose containing 第…章.
  final int maxTitleLength;

  /// Title used when the text contains no heading at all.
  final String fallbackTitle;

  List<ChapterSpan> split(String text) {
    if (text.isEmpty) {
      return const <ChapterSpan>[];
    }
    final headings = <_Heading>[];
    final matcher = RegExp(pattern, multiLine: true);
    for (final match in matcher.allMatches(text)) {
      final title = match.group(0)!.trim();
      if (title.isEmpty || title.length > maxTitleLength) continue;
      headings.add(_Heading(title, match.start));
    }

    if (headings.isEmpty) {
      return <ChapterSpan>[
        ChapterSpan(index: 0, title: fallbackTitle, startOffset: 0, endOffset: text.length),
      ];
    }

    final chapters = <ChapterSpan>[];
    // Text before the first heading is kept as a prologue chapter so that no
    // character of the book is unreachable.
    if (headings.first.start > 0) {
      chapters.add(
        ChapterSpan(index: 0, title: 'Prologue', startOffset: 0, endOffset: headings.first.start),
      );
    }
    for (var i = 0; i < headings.length; i++) {
      final heading = headings[i];
      final end = i + 1 < headings.length ? headings[i + 1].start : text.length;
      if (end <= heading.start) continue;
      chapters.add(
        ChapterSpan(
          index: chapters.length,
          title: heading.title,
          startOffset: heading.start,
          endOffset: end,
        ),
      );
    }
    return chapters;
  }
}

final class _Heading {
  const _Heading(this.title, this.start);

  final String title;
  final int start;
}
