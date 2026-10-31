// Scaffolds a new plugin package: plugins/<name>.
//
// Usage: dart run tool/new_plugin.dart --name format_fb2
import 'dart:io';

import 'package:path/path.dart' as p;

Future<void> main(List<String> argv) async {
  final name = _argument(argv, '--name');
  if (name == null || name.isEmpty) {
    stderr.writeln('usage: dart run tool/new_plugin.dart --name <snake_case_name>');
    exit(64);
  }
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
    stderr.writeln('plugin name must be lower snake_case, got "$name"');
    exit(64);
  }

  final packageName = name.startsWith('modoo_') ? name : 'modoo_$name';
  final dir = Directory(p.join(Directory.current.path, 'plugins', name));
  if (dir.existsSync()) {
    stderr.writeln('plugins/$name already exists');
    exit(73);
  }
  Directory(p.join(dir.path, 'lib', 'src')).createSync(recursive: true);
  Directory(p.join(dir.path, 'test')).createSync(recursive: true);

  final className = '${_pascalCase(name)}Plugin';
  final pluginId = 'modoo.plugin.${name.replaceAll('_', '.')}';

  File(p.join(dir.path, 'pubspec.yaml')).writeAsStringSync('''
name: $packageName
description: "modoo_reader plugin: $name."
version: 0.1.0
publish_to: none

environment:
  sdk: ^3.9.0

dependencies:
  modoo_plugin_api:
    path: ../../packages/plugin_api

dev_dependencies:
  flutter_lints: ^6.0.0
  test: ^1.25.0
''');

  File(p.join(dir.path, 'lib', '$packageName.dart')).writeAsStringSync('''
/// modoo_reader plugin: $name.
library;

import 'package:modoo_plugin_api/modoo_plugin_api.dart';

import 'src/$name.dart';

export 'src/$name.dart';

/// Entry point consumed by tool/gen_registry.dart. Keep the signature stable.
ModooPlugin createPlugin() => $className();
''');

  File(p.join(dir.path, 'lib', 'src', '$name.dart')).writeAsStringSync('''
import 'package:modoo_plugin_api/modoo_plugin_api.dart';

/// TODO: declare the capabilities this plugin implements in [manifest].
final class $className implements ModooPlugin {
  @override
  PluginManifest get manifest => const PluginManifest(
        id: '$pluginId',
        name: '$name',
        version: '0.1.0',
        sdkConstraint: ModooPluginApi.versionRange,
        capabilities: <Type>{},
        settings: <PluginSetting>[],
      );

  @override
  Future<void> register(PluginContext context) async {
    // Bind services here, e.g. context.bind<BookFormatParser>(...).
  }
}
''');

  File(p.join(dir.path, 'test', '${name}_test.dart')).writeAsStringSync('''
import 'package:$packageName/$packageName.dart';
import 'package:modoo_plugin_api/modoo_plugin_api.dart';
import 'package:test/test.dart';

void main() {
  test('manifest is stable', () {
    final plugin = createPlugin();
    expect(plugin, isA<ModooPlugin>());
    expect(plugin.manifest.id, '$pluginId');
    expect(plugin.manifest.version, '0.1.0');
  });
}
''');

  stdout
    ..writeln('created plugins/$name ($packageName)')
    ..writeln()
    ..writeln('Next steps:')
    ..writeln('  1. implement the capability in plugins/$name/lib/src/$name.dart')
    ..writeln('  2. add plugins/$name to the `workspace:` list in the root pubspec.yaml')
    ..writeln('  3. flutter pub get && melos run gen:registry')
    ..writeln('  4. add zh/en names to packages/l10n/lib/l10n/*.arb (plugin_${name}_name)');
}

String? _argument(List<String> argv, String flag) {
  for (var i = 0; i < argv.length; i++) {
    if (argv[i] == flag && i + 1 < argv.length) {
      return argv[i + 1];
    }
    if (argv[i].startsWith('$flag=')) {
      return argv[i].substring(flag.length + 1);
    }
  }
  return null;
}

String _pascalCase(String name) => name
    .split('_')
    .where((part) => part.isNotEmpty)
    .map((part) => part[0].toUpperCase() + part.substring(1))
    .join();
