import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modoo_core/modoo_core.dart';
import 'package:modoo_data/modoo_data.dart';
import 'package:modoo_plugin_host/modoo_plugin_host.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'src/app/app.dart';
import 'src/plugins/registry.g.dart';
import 'src/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const logger = DeveloperLogger();
  final supportDir = await getApplicationSupportDirectory();
  final database = AppDatabase.openAt(p.join(supportDir.path, 'modoo_reader.sqlite'));

  final registry = PluginRegistry(plugins: buildPluginList(), logger: logger);
  await registry.initialize();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        pluginRegistryProvider.overrideWithValue(registry),
      ],
      child: const ModooApp(),
    ),
  );
}
