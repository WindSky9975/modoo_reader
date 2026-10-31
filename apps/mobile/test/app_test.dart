import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modoo_core/modoo_core.dart';
import 'package:modoo_plugin_api/modoo_plugin_api.dart';
import 'package:modoo_data/modoo_data.dart';
import 'package:modoo_plugin_host/modoo_plugin_host.dart';
import 'package:modoo_reader/src/app/app.dart';
import 'package:modoo_reader/src/providers/app_providers.dart';

void main() {
  testWidgets('app boots on an empty shelf and shows the empty state', (WidgetTester tester) async {
    final database = AppDatabase.memory();
    final registry = PluginRegistry(plugins: const <ModooPlugin>[], logger: const SilentLogger());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          pluginRegistryProvider.overrideWithValue(registry),
        ],
        child: const ModooApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Widget tests run with the default en_US locale, so assert the English
    // strings; packages/l10n covers the zh translation separately.
    expect(find.text('No books yet'), findsOneWidget);
    expect(find.text('Import book'), findsOneWidget);

    // Unmount inside the test so drift cancels its stream queries while the
    // fake-async zone is still active; otherwise it leaves a pending timer.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await database.close();
  });
}
