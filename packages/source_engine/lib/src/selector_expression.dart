import 'package:modoo_core/modoo_core.dart';

/// One selector expression from a source rule.
///
/// The text before the first colon picks the evaluator; everything after is
/// the expression. `@js:` is only accepted when the sandbox is enabled,
/// because it means running third-party script.
final class SelectorExpression {
  const SelectorExpression._(this.kind, this.expression);

  /// Parses `raw`; throws [ParseException] when the prefix is unknown or the
  /// expression is empty.
  factory SelectorExpression.parse(String raw) {
    final trimmed = raw.trim();
    final colon = trimmed.indexOf(':');
    if (colon <= 0) {
      throw ParseException('selector is missing a kind prefix: "$raw"');
    }
    final prefix = trimmed.substring(0, colon).trim();
    final body = trimmed.substring(colon + 1).trim();
    final kind = switch (prefix) {
      '@css' => SelectorKind.css,
      '@json' => SelectorKind.json,
      '@regex' => SelectorKind.regex,
      '@js' => SelectorKind.js,
      _ => throw ParseException('unknown selector prefix "$prefix"'),
    };
    if (body.isEmpty) {
      throw ParseException('selector "$raw" has an empty expression');
    }
    return SelectorExpression._(kind, body);
  }

  final SelectorKind kind;
  final String expression;

  /// Script selectors must run inside the JS sandbox, never inline.
  bool get requiresSandbox => kind == SelectorKind.js;

  @override
  String toString() => '@${kind.name}:$expression';
}

/// Evaluator family of a selector.
enum SelectorKind { css, json, regex, js }
