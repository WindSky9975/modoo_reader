/// Book source engine: the rule DSL a user imports, selector evaluation and
/// the network sandbox around it.
///
/// The project ships **no** sources of its own; a rule is user data and is
/// never bundled (DEVELOPMENT_PLAN §1.3, AGENTS.md hard rule 9).
library;

export 'src/book_source.dart';
export 'src/selector_expression.dart';
export 'src/source_rule.dart';
