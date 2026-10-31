import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modoo_l10n/modoo_l10n.dart';
import 'package:modoo_ui/modoo_ui.dart';

import '../../providers/app_providers.dart';

/// App-wide settings: reading theme today, typography and sync later.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppThemeVariant current = ref.watch(appThemeProvider);
    final ReaderSettingsController controller = ref.read(readerSettingsControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: ListView(
        children: <Widget>[
          ModooSectionHeader(title: context.l10n.settingsTheme),
          RadioGroup<AppThemeVariant>(
            groupValue: current,
            onChanged: (AppThemeVariant? value) {
              if (value != null) {
                controller.setThemeId(value.name);
              }
            },
            child: Column(
              children: <Widget>[
                for (final AppThemeVariant variant in AppThemeVariant.values)
                  RadioListTile<AppThemeVariant>(
                    value: variant,
                    title: Text(_label(context, variant)),
                    secondary: Icon(_icon(variant)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _label(BuildContext context, AppThemeVariant variant) => switch (variant) {
    AppThemeVariant.paper => context.l10n.themePaper,
    AppThemeVariant.sepia => context.l10n.themeSepia,
    AppThemeVariant.night => context.l10n.themeNight,
    AppThemeVariant.amoled => context.l10n.themeAmoled,
  };

  IconData _icon(AppThemeVariant variant) => switch (variant) {
    AppThemeVariant.paper => Icons.light_mode_outlined,
    AppThemeVariant.sepia => Icons.wb_sunny_outlined,
    AppThemeVariant.night => Icons.dark_mode_outlined,
    AppThemeVariant.amoled => Icons.brightness_2_outlined,
  };
}
