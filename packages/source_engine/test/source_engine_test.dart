import 'package:modoo_core/modoo_core.dart';
import 'package:modoo_source_engine/modoo_source_engine.dart';
import 'package:test/test.dart';

const Map<String, Object?> _rule = <String, Object?>{
  'id': 'example.read',
  'name': 'Example',
  'baseUrl': 'https://example.com',
  'searchUrl': 'https://example.com/search?q={keyword}&page={page}',
  'outlineSelector': '@css:#list a',
  'chapterTextSelector': '@css:#content',
};

void main() {
  group('SelectorExpression', () {
    test('parses each kind', () {
      expect(SelectorExpression.parse('@css:.book a').kind, SelectorKind.css);
      expect(SelectorExpression.parse('@json:data.list').kind, SelectorKind.json);
      expect(SelectorExpression.parse('@regex:<p>(.*?)</p>').kind, SelectorKind.regex);
      expect(SelectorExpression.parse('@js:document.title').kind, SelectorKind.js);
    });

    test('js selectors require the sandbox', () {
      expect(SelectorExpression.parse('@js:document.title').requiresSandbox, isTrue);
      expect(SelectorExpression.parse('@css:.a').requiresSandbox, isFalse);
    });

    test('rejects unknown prefixes and empty expressions', () {
      expect(() => SelectorExpression.parse('.book a'), throwsA(isA<ParseException>()));
      expect(() => SelectorExpression.parse('@xpath://a'), throwsA(isA<ParseException>()));
      expect(() => SelectorExpression.parse('@css:   '), throwsA(isA<ParseException>()));
    });
  });

  group('SourceRule', () {
    test('parses a complete rule', () {
      final rule = SourceRule.fromJson(_rule);
      expect(rule.id, 'example.read');
      expect(rule.enabled, isTrue);
      expect(rule.requiresJs, isFalse);
    });

    test('rejects a rule with a missing field', () {
      final broken = Map<String, Object?>.from(_rule)..remove('searchUrl');
      expect(() => SourceRule.fromJson(broken), throwsA(isA<ParseException>()));
    });

    test('copyWith toggles enabled only', () {
      final rule = SourceRule.fromJson(_rule);
      expect(rule.copyWith(enabled: false).enabled, isFalse);
      expect(rule.copyWith(enabled: false).id, rule.id);
    });
  });
}
