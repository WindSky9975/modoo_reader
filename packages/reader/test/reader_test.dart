import 'package:modoo_reader_engine/modoo_reader_engine.dart';
import 'package:test/test.dart';

const String _book = '''
楔子

天还没亮。

第一章 山雨欲来

风从北面来，带着湿冷的气息。

第二章 入城

城门口排着长队。
''';

void main() {
  group('ChapterSplitter', () {
    const splitter = ChapterSplitter();

    test('keeps the prologue before the first heading', () {
      final chapters = splitter.split(_book);
      expect(chapters.first.title, 'Prologue');
      expect(chapters.first.startOffset, 0);
    });

    test('finds Chinese chapter headings in order', () {
      final chapters = splitter.split(_book);
      final titles = chapters.map((chapter) => chapter.title).toList();
      expect(titles, containsAllInOrder(<String>['第一章 山雨欲来', '第二章 入城']));
      expect(
        chapters.map((chapter) => chapter.index),
        List<int>.generate(chapters.length, (i) => i),
      );
    });

    test('chapters tile the text without gaps or overlap', () {
      final chapters = splitter.split(_book);
      for (var i = 0; i < chapters.length - 1; i++) {
        expect(chapters[i].endOffset, chapters[i + 1].startOffset);
      }
      expect(chapters.last.endOffset, _book.length);
      expect(chapters.first.startOffset, 0);
    });

    test('falls back to a single chapter when there is no heading', () {
      final chapters = splitter.split('only prose, no headings at all');
      expect(chapters, hasLength(1));
      expect(chapters.single.title, 'Chapter 1');
      expect(chapters.single.endOffset, 'only prose, no headings at all'.length);
    });

    test('returns nothing for empty input', () {
      expect(splitter.split(''), isEmpty);
    });

    test('ignores prose that merely mentions a chapter number', () {
      final chapters = splitter.split('他说第三章很好看，但没有换行。');
      expect(chapters, hasLength(1));
    });
  });

  group('LayoutSpec', () {
    test('hash is stable for equal specs', () {
      const a = LayoutSpec(fontSize: 20);
      const b = LayoutSpec(fontSize: 20);
      expect(a.layoutHash, b.layoutHash);
    });

    test('every layout-affecting field changes the hash', () {
      const base = LayoutSpec();
      final variants = <LayoutSpec>[
        base.copyWith(fontSize: 20),
        base.copyWith(lineHeight: 1.8),
        base.copyWith(paragraphSpacing: 0.2),
        base.copyWith(horizontalPadding: 24),
        base.copyWith(letterSpacing: 0.5),
        base.copyWith(fontFamily: 'Noto Serif CJK'),
        base.copyWith(fontVersion: 2),
        base.copyWith(flags: Flags.hangingPunctuation),
        base.copyWith(textAlign: LayoutTextAlign.justify),
      ];
      final hashes = <int>{base.layoutHash, ...variants.map((variant) => variant.layoutHash)};
      expect(hashes, hasLength(variants.length + 1));
    });

    test('hash fits in 32 bits so it survives a Web build', () {
      expect(const LayoutSpec().layoutHash, lessThan(1 << 32));
    });
  });

  group('searchBook', () {
    const splitter = ChapterSplitter();

    test('returns hits in reading order with chapter-relative offsets', () {
      final chapters = splitter.split(_book);
      final hits = searchBook(text: _book, chapters: chapters, query: '城');
      expect(hits, isNotEmpty);
      int previous = -1;
      for (final hit in hits) {
        final chapter = chapters[hit.chapterIndex];
        final absolute = chapter.startOffset + hit.charOffset;
        expect(_book.substring(absolute, absolute + hit.length), '城');
        expect(absolute, greaterThan(previous));
        previous = absolute;
      }
    });

    test('is case-insensitive and literal', () {
      const book = 'Chapter One\nhello world\nhello.*\n';
      final chapters = splitter.split(book);
      expect(searchBook(text: book, chapters: chapters, query: 'HELLO'), hasLength(2));
      expect(searchBook(text: book, chapters: chapters, query: 'hello.*'), hasLength(1));
    });

    test('returns nothing for a blank query', () {
      final chapters = splitter.split(_book);
      expect(searchBook(text: _book, chapters: chapters, query: '   '), isEmpty);
    });

    test('respects maxHits', () {
      final chapters = splitter.split(_book);
      final hits = searchBook(text: _book, chapters: chapters, query: '，', maxHits: 1);
      expect(hits, hasLength(1));
    });

    test('snippets replace newlines so each hit stays on one line', () {
      final chapters = splitter.split(_book);
      final hits = searchBook(text: _book, chapters: chapters, query: '风从北面来');
      expect(hits, hasLength(1));
      expect(hits.single.snippet, isNot(contains('\n')));
    });
  });

  group('pinchFontSize', () {
    test('spreading the fingers grows the text', () {
      expect(pinchFontSize(startSize: 18, startSpan: 100, span: 200), 30);
    });

    test('pinching in shrinks the text and stops at the floor', () {
      expect(pinchFontSize(startSize: 18, startSpan: 100, span: 50), 14);
    });

    test('rounds to whole points to avoid re-paginating every frame', () {
      expect(pinchFontSize(startSize: 18, startSpan: 100, span: 110), 20);
      expect(pinchFontSize(startSize: 18, startSpan: 100, span: 101), 18);
    });

    test('stays at the start size for a degenerate span', () {
      expect(pinchFontSize(startSize: 18, startSpan: 0, span: 120), 18);
      expect(pinchFontSize(startSize: 18, startSpan: 100, span: 0), 18);
    });
  });
}
