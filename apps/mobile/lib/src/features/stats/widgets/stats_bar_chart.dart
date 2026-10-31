import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:modoo_domain/modoo_domain.dart';
import 'package:modoo_l10n/modoo_l10n.dart';
import 'package:modoo_ui/modoo_ui.dart';

/// Seven bars, one per day, newest on the right.
///
/// The tallest day defines the scale, so a light week still shows a shape
/// instead of seven identical stubs.
class StatsBarChart extends StatelessWidget {
  const StatsBarChart({required this.stats, required this.now, super.key});

  final ReadingStats stats;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ModooLocalizations strings = context.l10n;

    final List<({DateTime day, Duration duration})> week = <({DateTime day, Duration duration})>[
      for (int back = 6; back >= 0; back--)
        (
          day: DateTime(now.year, now.month, now.day).subtract(Duration(days: back)),
          duration: Duration.zero,
        ),
    ];

    Duration longest = Duration.zero;
    for (int index = 0; index < week.length; index++) {
      final DateTime day = week[index].day;
      Duration total = Duration.zero;
      for (final ReadingDay entry in stats.days) {
        if (entry.day == day) total = entry.duration;
      }
      week[index] = (day: day, duration: total);
      if (total > longest) longest = total;
    }

    if (longest == Duration.zero) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Text(strings.statsEmpty, style: theme.textTheme.bodySmall),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: SizedBox(
        height: 96,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            for (final ({DateTime day, Duration duration}) slot in week)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        height: math.max(
                          4,
                          64 * (slot.duration.inMinutes / math.max(1, longest.inMinutes)),
                        ),
                        decoration: BoxDecoration(
                          color: slot.duration == Duration.zero
                              ? theme.colorScheme.outlineVariant
                              : theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text('${slot.day.day}', style: theme.textTheme.labelSmall),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
