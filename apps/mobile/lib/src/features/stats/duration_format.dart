import 'package:flutter/widgets.dart';
import 'package:modoo_l10n/modoo_l10n.dart';

/// Formats a duration the way the statistics screen shows it.
///
/// Anything between one second and a minute rounds up to "1 min" rather than
/// showing "0 min", which reads like the session was not recorded.
String formatDuration(BuildContext context, Duration duration) {
  final ModooLocalizations strings = context.l10n;
  final int minutes = duration.inMinutes;
  if (minutes < 60) {
    return strings.statsMinutes(minutes < 1 && duration > Duration.zero ? 1 : minutes);
  }
  return strings.statsHours(minutes ~/ 60, minutes % 60);
}
