import 'dart:convert';
import 'dart:typed_data';

import 'package:modoo_core/modoo_core.dart';
import 'package:test/test.dart';

Uint8List _bytes(List<int> values) => Uint8List.fromList(values);

Uint8List _utf16Le(String text, {bool bom = true}) {
  final raw = <int>[];
  if (bom) {
    raw.addAll(<int>[0xFF, 0xFE]);
  }
  for (final int unit in text.codeUnits) {
    raw.add(unit & 0xFF);
    raw.add((unit >> 8) & 0xFF);
  }
  return _bytes(raw);
}

Uint8List _utf16Be(String text, {bool bom = true}) {
  final raw = <int>[];
  if (bom) {
    raw.addAll(<int>[0xFE, 0xFF]);
  }
  for (final int unit in text.codeUnits) {
    raw.add((unit >> 8) & 0xFF);
    raw.add(unit & 0xFF);
  }
  return _bytes(raw);
}

void main() {
  group('detectEncoding', () {
    test('empty input still yields a usable guess', () {
      final guess = detectEncoding(Uint8List(0));
      expect(guess.encoding, TextEncoding.utf8);
    });

    test('UTF-8 with BOM wins over everything', () {
      final bytes = _bytes(<int>[0xEF, 0xBB, 0xBF, 0xE4, 0xB8, 0xAD]);
      final guess = detectEncoding(bytes);
      expect(guess.encoding, TextEncoding.utf8);
      expect(guess.confidence, 1);
    });

    test('UTF-16LE and UTF-16BE are recognised by BOM', () {
      expect(detectEncoding(_utf16Le('第一章')).encoding, TextEncoding.utf16Le);
      expect(detectEncoding(_utf16Be('第一章')).encoding, TextEncoding.utf16Be);
    });

    test('UTF-16LE without BOM is caught by the zero-byte pattern', () {
      final bytes = _utf16Le('Chapter 1\nHello world', bom: false);
      expect(detectEncoding(bytes).encoding, TextEncoding.utf16Le);
    });

    test('plain ASCII is UTF-8', () {
      expect(detectEncoding(_bytes(utf8.encode('Chapter 1'))).encoding, TextEncoding.utf8);
    });

    test('Chinese UTF-8 text is UTF-8', () {
      final bytes = _bytes(utf8.encode('第一章 开始'));
      final guess = detectEncoding(bytes);
      expect(guess.encoding, TextEncoding.utf8);
      expect(guess.confidence, greaterThan(0.5));
    });

    test('GBK bytes are reported as gb18030', () {
      // 中文 encoded as GBK.
      final bytes = _bytes(<int>[0xD6, 0xD0, 0xCE, 0xC4]);
      expect(detectEncoding(bytes).encoding, TextEncoding.gb18030);
    });

    test('broken bytes fall back to lenient UTF-8 instead of throwing', () {
      // 0xC3 starts a 2-byte sequence and is cut off by the end of the buffer.
      final bytes = _bytes(<int>[0x41, 0xC3]);
      final guess = detectEncoding(bytes);
      expect(guess.encoding, TextEncoding.utf8);
      expect(decodeText(bytes, guess.encoding), contains('A'));
    });
  });

  group('decodeText', () {
    test('strips the UTF-8 BOM', () {
      final bytes = _bytes(<int>[0xEF, 0xBB, 0xBF, ...utf8.encode('第一章')]);
      expect(decodeText(bytes, TextEncoding.utf8), '第一章');
    });

    test('decodes UTF-16LE with and without BOM', () {
      expect(decodeText(_utf16Le('第一章 开始'), TextEncoding.utf16Le), '第一章 开始');
      expect(decodeText(_utf16Le('第一章 开始', bom: false), TextEncoding.utf16Le), '第一章 开始');
    });

    test('decodes UTF-16BE', () {
      expect(decodeText(_utf16Be('Hello 世界'), TextEncoding.utf16Be), 'Hello 世界');
    });

    test('decodes GBK through enough_convert', () {
      expect(decodeText(_bytes(<int>[0xD6, 0xD0, 0xCE, 0xC4]), TextEncoding.gb18030), '中文');
    });

    test('decodes mixed GBK text with ASCII punctuation', () {
      final bytes = _bytes(<int>[0xD6, 0xD0, 0xCE, 0xC4, 0x21, 0x0A]);
      expect(decodeText(bytes, TextEncoding.gb18030), '中文!\n');
    });
  });
}
