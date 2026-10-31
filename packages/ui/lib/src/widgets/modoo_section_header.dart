import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Section title with an optional trailing action, used by settings and the
/// book detail page.
class ModooSectionHeader extends StatelessWidget {
  const ModooSectionHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
          ?trailing,
        ],
      ),
    );
  }
}
