import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shared empty state: icon, headline, one sentence, optional action.
///
/// Every list in the app shows this instead of a blank screen, and the text
/// comes from ARB, never from a literal (AGENTS.md hard rule 6).
class ModooEmptyState extends StatelessWidget {
  const ModooEmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.auto_stories_outlined,
    this.action,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 56, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...<Widget>[const SizedBox(height: AppSpacing.xl), action!],
          ],
        ),
      ),
    );
  }
}
