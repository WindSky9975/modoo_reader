/// Encoding detection and pure-Dart decoding for imported book files.
///
/// Two rules shape this file:
///
/// 1. Detection never throws. A wrong guess must degrade into "read as UTF-8
///    with replacement characters", never into a crash on the import screen.
/// 2. Decoding is pure Dart: UTF-8 and UTF-16 are hand written here, GBK comes
///    from `enough_convert` (ADR-0011). Nothing here needs a platform channel,
///    so the whole pipeline also runs in an isolate. The importer re-encodes a
///    legacy file as UTF-8 once; after that every reader path only ever sees
///    UTF-8 and character offsets stay consistent with the stored file.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:enough_convert/gbk.dart';

/// Encodings the importer can recognise.
enum TextEncoding {
  utf8('utf-8'),
  utf16Le('utf-16le'),
  utf16Be('utf-16be'),
  gb18030('gb18030');

  const TextEncoding(this.label);

  /// Name stored on the book row and shown in diagnostics.
  final String label;
}

/// A guess plus how much we trust it (0..1).
final class EncodingGuess {
  const EncodingGuess(this.encoding, this.confidence);

  final TextEncoding encoding;
  final double confidence;

  @override
  String toString() => 'EncodingGuess(${encoding.label}, ${confidence.toStringAsFixed(2)})';
}

/// How many leading bytes detection looks at. Enough to catch a BOM, a UTF-16
/// pattern or a run of GBK pairs without scanning a 3 MB novel.
const int _sampleSize = 64 * 1024;

/// Detects the encoding of [bytes] without throwing.
EncodingGuess detectEncoding(Uint8List bytes) {
  if (bytes.isEmpty) {
    return const EncodingGuess(TextEncoding.utf8, 0.5);
  }
  if (_startsWith(bytes, <int>[0xEF, 0xBB, 0xBF])) {
    return const EncodingGuess(TextEncoding.utf8, 1);
  }
  if (_startsWith(bytes, <int>[0xFF, 0xFE])) {
    return const EncodingGuess(TextEncoding.utf16Le, 1);
  }
  if (_startsWith(bytes, <int>[0xFE, 0xFF])) {
    return const EncodingGuess(TextEncoding.utf16Be, 1);
  }

  final Uint8List sample = bytes.length > _sampleSize
      ? Uint8List.sublistView(bytes, 0, _sampleSize)
      : bytes;

  final TextEncoding? utf16 = _guessUtf16ByNulls(sample);
  if (utf16 != null) {
    return EncodingGuess(utf16, 0.8);
  }
  if (_isUtf8(sample)) {
    return const EncodingGuess(TextEncoding.utf8, 0.9);
  }
  if (_looksLikeGbk(sample)) {
    return const EncodingGuess(TextEncoding.gb18030, 0.7);
  }
  // Malformed UTF-8 that is not GBK: keep going, replacement characters beat a
  // hard failure on the import screen.
  return const EncodingGuess(TextEncoding.utf8, 0.3);
}

/// Decodes [bytes] using the encoding [detectEncoding] reported.
///
/// Never throws on malformed input: every branch replaces what it cannot read.
String decodeText(Uint8List bytes, TextEncoding encoding) {
  switch (encoding) {
    case TextEncoding.utf8:
      return utf8.decode(_withoutBom(bytes), allowMalformed: true);
    case TextEncoding.utf16Le:
      return _decodeUtf16(bytes, littleEndian: true);
    case TextEncoding.utf16Be:
      return _decodeUtf16(bytes, littleEndian: false);
    case TextEncoding.gb18030:
      // GBK is a subset of GB18030; four-byte GB18030 sequences are not
      // covered yet (ADR-0011) and degrade to replacement characters.
      return const GbkCodec(allowInvalid: true).decode(bytes);
  }
}

/// Strips the UTF-8 byte order mark, if present.
Uint8List _withoutBom(Uint8List bytes) {
  if (_startsWith(bytes, <int>[0xEF, 0xBB, 0xBF])) {
    return Uint8List.sublistView(bytes, 3);
  }
  return bytes;
}

bool _startsWith(Uint8List bytes, List<int> prefix) {
  if (bytes.length < prefix.length) {
    return false;
  }
  for (var i = 0; i < prefix.length; i++) {
    if (bytes[i] != prefix[i]) {
      return false;
    }
  }
  return true;
}

/// UTF-16 without a BOM shows up as a run of zero bytes on one side of every
/// ASCII character. That pattern is cheap to spot and almost never accidental.
TextEncoding? _guessUtf16ByNulls(Uint8List sample) {
  final int length = sample.length;
  if (length < 4) {
    return null;
  }
  var evenNuls = 0;
  var oddNuls = 0;
  final int checked = length < 2048 ? length : 2048;
  for (var i = 0; i < checked; i++) {
    if (sample[i] == 0) {
      if (i.isEven) {
        evenNuls++;
      } else {
        oddNuls++;
      }
    }
  }
  final int pairs = checked ~/ 2;
  if (oddNuls > pairs * 0.3 && evenNuls < pairs * 0.05) {
    return TextEncoding.utf16Le;
  }
  if (evenNuls > pairs * 0.3 && oddNuls < pairs * 0.05) {
    return TextEncoding.utf16Be;
  }
  return null;
}

/// Strict UTF-8 check: any malformed sequence means "not UTF-8".
bool _isUtf8(Uint8List bytes) {
  var i = 0;
  while (i < bytes.length) {
    final int byte = bytes[i];
    if (byte < 0x80) {
      i++;
      continue;
    }
    final int extra = byte >= 0xF0 && byte <= 0xF4
        ? 3
        : byte >= 0xE0 && byte <= 0xEF
        ? 2
        : byte >= 0xC2 && byte <= 0xDF
        ? 1
        : -1;
    if (extra < 0 || i + extra >= bytes.length) {
      return false;
    }
    for (var k = 1; k <= extra; k++) {
      if (bytes[i + k] < 0x80 || bytes[i + k] > 0xBF) {
        return false;
      }
    }
    i += extra + 1;
  }
  return true;
}

/// Cheap GBK shape check: lead byte 0x81..0xFE, trail byte 0x40..0xFE minus 0x7F.
bool _looksLikeGbk(Uint8List sample) {
  var i = 0;
  var pairs = 0;
  final int limit = sample.length < 4096 ? sample.length : 4096;
  while (i < limit) {
    final int lead = sample[i];
    if (lead < 0x80) {
      i++;
      continue;
    }
    if (lead < 0x81 || lead > 0xFE || i + 1 >= limit) {
      return false;
    }
    final int trail = sample[i + 1];
    if (trail < 0x40 || trail > 0xFE || trail == 0x7F) {
      return false;
    }
    pairs++;
    i += 2;
  }
  return pairs > 0;
}

String _decodeUtf16(Uint8List bytes, {required bool littleEndian}) {
  var start = 0;
  if (bytes.length >= 2) {
    final bool hasBom = littleEndian
        ? bytes[0] == 0xFF && bytes[1] == 0xFE
        : bytes[0] == 0xFE && bytes[1] == 0xFF;
    if (hasBom) {
      start = 2;
    }
  }
  final int units = (bytes.length - start) ~/ 2;
  final List<int> codeUnits = List<int>.filled(units, 0);
  for (var i = 0; i < units; i++) {
    final int low = bytes[start + i * 2];
    final int high = bytes[start + i * 2 + 1];
    codeUnits[i] = littleEndian ? (high << 8) | low : (low << 8) | high;
  }
  return String.fromCharCodes(codeUnits);
}
