/// Localized strings.
///
/// The generated `ModooLocalizations` class lives in `src/generated/` and is
/// committed (CI regenerates it and fails on diff). Widgets use
/// `context.l10n.someKey` and never hard-code user-visible text
/// (AGENTS.md hard rule 6).
library;

import 'package:flutter/widgets.dart';

import 'src/generated/modoo_localizations.dart';

export 'src/generated/modoo_localizations.dart';

extension ModooL10nContext on BuildContext {
  /// Shorthand for `ModooLocalizations.of(context)`.
  ModooLocalizations get l10n => ModooLocalizations.of(this);
}
