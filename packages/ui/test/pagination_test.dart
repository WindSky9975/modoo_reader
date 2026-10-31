import 'package:flutter_test/flutter_test.dart';
import 'package:modoo_reader_engine/modoo_reader_engine.dart';
import 'package:modoo_ui/modoo_ui.dart';

String _sampleText() {
  final StringBuffer buffer = StringBuffer();
  for (int paragraph = 0; paragraph < 40; paragraph++) {
    buffer.write('第$paragraph段：');
    buffer.write('这是用来测试分页引擎的中文段落，长度足够折成好几行。' * 3);
    buffer.write('\n');
  }
  return buffer.toString();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const TextLayoutEngine engine = TextPainterLayoutEngine();

  const LayoutSpec spec = LayoutSpec(horizontalPadding: 24, verticalPadding: 20);

  test('returns no pages for empty text', () async {
    final List<PageSpan> pages = await engine.paginate(
      PaginationRequest(chapterIndex: 0, text: '', spec: spec, pageWidth: 320, pageHeight: 480),
    );
    expect(pages, isEmpty);
  });

  test('pages are contiguous and cover the whole chapter', () async {
    final String text = _sampleText();
    final List<PageSpan> pages = await engine.paginate(
      PaginationRequest(chapterIndex: 0, text: text, spec: spec, pageWidth: 320, pageHeight: 480),
    );

    expect(pages.length, greaterThan(1));
    expect(pages.first.startOffset, 0);
    expect(pages.last.endOffset, text.length);
    for (int index = 0; index < pages.length; index++) {
      final PageSpan page = pages[index];
      expect(page.endOffset, greaterThan(page.startOffset), reason: 'page $index is empty');
      if (index > 0) {
        expect(page.startOffset, pages[index - 1].endOffset, reason: 'gap before page $index');
      }
    }
  });

  test('a larger font size produces more pages', () async {
    final String text = _sampleText();
    Future<int> pageCount(LayoutSpec spec) async {
      final List<PageSpan> pages = await engine.paginate(
        PaginationRequest(chapterIndex: 0, text: text, spec: spec, pageWidth: 320, pageHeight: 480),
      );
      return pages.length;
    }

    final int small = await pageCount(spec.copyWith(fontSize: 14, lineHeight: 1.4));
    final int large = await pageCount(spec.copyWith(fontSize: 26, lineHeight: 2.0));

    expect(large, greaterThan(small));
  });

  test('lays out a 20k character chapter well under the 300ms budget', () async {
    // Mirror of DEVELOPMENT_PLAN §5.3 M2: a chapter of a large book is around
    // 20k characters. This measures the engine only; the reader adds one
    // cache lookup on top.
    final StringBuffer buffer = StringBuffer();
    while (buffer.length < 20000) {
      buffer.write('这是一段用来做性能预算测试的文字，需要足够长才会折行。');
      buffer.write('\n');
    }
    final String text = buffer.toString();

    final Stopwatch watch = Stopwatch()..start();
    final List<PageSpan> pages = await engine.paginate(
      PaginationRequest(chapterIndex: 0, text: text, spec: spec, pageWidth: 340, pageHeight: 560),
    );
    watch.stop();

    expect(pages, isNotEmpty);
    expect(
      watch.elapsedMilliseconds,
      lessThan(300),
      reason: 'single chapter layout took ${watch.elapsedMilliseconds}ms',
    );
  });

  group('pageIndexForOffset', () {
    const List<PageSpan> pages = <PageSpan>[
      PageSpan(startOffset: 0, endOffset: 100),
      PageSpan(startOffset: 100, endOffset: 200),
      PageSpan(startOffset: 200, endOffset: 300),
    ];

    test('returns 0 for an empty chapter', () {
      expect(pageIndexForOffset(const <PageSpan>[], 0), 0);
    });

    test('maps offsets onto the page that contains them', () {
      expect(pageIndexForOffset(pages, 0), 0);
      expect(pageIndexForOffset(pages, 99), 0);
      expect(pageIndexForOffset(pages, 100), 1);
      expect(pageIndexForOffset(pages, 250), 2);
    });

    test('clamps offsets past the end onto the last page', () {
      expect(pageIndexForOffset(pages, 9999), 2);
    });

    test('pageForOffset returns the page itself', () {
      expect(pageForOffset(pages, 150)?.startOffset, 100);
      expect(pageForOffset(const <PageSpan>[], 5), isNull);
    });
  });
}
