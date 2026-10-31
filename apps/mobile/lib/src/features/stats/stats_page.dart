import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modoo_domain/modoo_domain.dart';
import 'package:modoo_l10n/modoo_l10n.dart';
import 'package:modoo_ui/modoo_ui.dart';

import '../../providers/app_providers.dart';
import 'duration_format.dart';
import 'widgets/stats_bar_chart.dart';

/// Reading time, characters and streak.
///
/// Nothing here is stored: the screen folds the raw sessions with
/// [summarizeSessions], so a definition change is a code change, not a
/// migration.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ModooLocalizations strings = context.l10n;
    final ReadingStats stats = ref.watch(readingStatsProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.statsTitle)),
      body: stats.sessionCount == 0
          ? ModooEmptyState(
              title: strings.statsTitle,
              message: strings.statsEmpty,
              icon: Icons.insights_outlined,
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Row(
                    children: <Widget>[
                      _StatTile(
                        label: strings.statsToday,
                        value: formatDuration(context, stats.durationOn(DateTime.now())),
                        icon: Icons.today_outlined,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _StatTile(
                        label: strings.statsWeek,
                        value: formatDuration(context, stats.lastSevenDays),
                        icon: Icons.date_range_outlined,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _StatTile(
                        label: strings.statsStreak,
                        value: strings.statsStreakDays(stats.streakDays),
                        icon: Icons.local_fire_department_outlined,
                      ),
                    ],
                  ),
                ),
                ModooSectionHeader(title: strings.statsLastDays),
                StatsBarChart(stats: stats, now: DateTime.now()),
                ModooSectionHeader(title: strings.statsTotal),
                ListTile(
                  leading: Icon(Icons.timelapse_outlined, color: theme.colorScheme.primary),
                  title: Text(strings.statsTotal),
                  trailing: Text(
                    formatDuration(context, stats.total),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.text_fields_outlined, color: theme.colorScheme.primary),
                  title: Text(strings.statsCharacters),
                  trailing: Text(
                    strings.statsCharactersCount(stats.characters),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: theme.textTheme.labelSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
