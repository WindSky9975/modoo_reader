import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modoo_l10n/modoo_l10n.dart';
import 'package:modoo_ui/modoo_ui.dart';

import '../home/home_shell.dart';
import '../providers/app_providers.dart';

/// Root widget: theme, localization and the navigation shell.
class ModooApp extends ConsumerWidget {
  const ModooApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppThemeVariant variant = ref.watch(appThemeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (BuildContext context) => context.l10n.appName,
      theme: buildAppTheme(variant),
      localizationsDelegates: ModooLocalizations.localizationsDelegates,
      supportedLocales: ModooLocalizations.supportedLocales,
      home: const HomeShell(),
    );
  }
}
