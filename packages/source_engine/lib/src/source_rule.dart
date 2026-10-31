import 'package:modoo_core/modoo_core.dart';

/// A parsed source rule (JSON on disk, [SourceRule] in memory).
///
/// `fromJson` validates every field the engine dereferences, so a malformed
/// rule fails at import time instead of during a page turn.
final class SourceRule {
  const SourceRule({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.searchUrl,
    required this.outlineSelector,
    required this.chapterTextSelector,
    this.enabled = true,
    this.requiresJs = false,
  });

  factory SourceRule.fromJson(Map<String, Object?> json) {
    String need(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw ParseException('source rule is missing the "$key" field');
      }
      return value.trim();
    }

    return SourceRule(
      id: need('id'),
      name: need('name'),
      baseUrl: need('baseUrl'),
      searchUrl: need('searchUrl'),
      outlineSelector: need('outlineSelector'),
      chapterTextSelector: need('chapterTextSelector'),
      enabled: json['enabled'] as bool? ?? true,
      requiresJs: json['requiresJs'] as bool? ?? false,
    );
  }

  final String id;
  final String name;
  final String baseUrl;

  /// Search URL template; `{keyword}` and `{page}` are substituted.
  final String searchUrl;
  final String outlineSelector;
  final String chapterTextSelector;
  final bool enabled;

  /// True when any selector is `@js:`; the UI warns before enabling such rules.
  final bool requiresJs;

  SourceRule copyWith({bool? enabled}) => SourceRule(
    id: id,
    name: name,
    baseUrl: baseUrl,
    searchUrl: searchUrl,
    outlineSelector: outlineSelector,
    chapterTextSelector: chapterTextSelector,
    enabled: enabled ?? this.enabled,
    requiresJs: requiresJs,
  );
}
