import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modoo_reader_engine/modoo_reader_engine.dart';
import 'package:modoo_ui/modoo_ui.dart';

void main() {
  test('readerTextStyle carries every metric the paginator measured', () {
    const LayoutSpec spec = LayoutSpec(
      fontFamily: 'serif',
      fontSize: 21,
      lineHeight: 1.8,
      letterSpacing: 0.4,
    );
    final TextStyle style = readerTextStyle(spec);

    expect(style.fontFamily, 'serif');
    expect(style.fontSize, 21);
    expect(style.height, 1.8);
    expect(style.letterSpacing, 0.4);
  });

  test('readerTextAlign follows the layout spec', () {
    expect(readerTextAlign(const LayoutSpec()), TextAlign.start);
    expect(
      readerTextAlign(const LayoutSpec(textAlign: LayoutTextAlign.justify)),
      TextAlign.justify,
    );
  });
}
