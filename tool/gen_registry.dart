// Regenerates apps/mobile/lib/src/plugins/registry.g.dart.
//
// The registry is the only file allowed to import plugins/* (CODE_STYLE §3.3),
// which is why it is generated instead of written by hand.
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

Future<void> main() async {
  final root = Directory.current;
  final plugins = _discoverPlugins(root);
  final buffer = StringBuffer();

  buffer
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('//')
    ..writeln('// Regenerate with: dart run tool/gen_registry.dart')
    ..writeln('// Discovery rule: every plugins/* package whose pubspec.yaml depends')
    ..writeln('// on modoo_plugin_api must expose `ModooPlugin createPlugin()`')
    ..writeln('// from lib/<package_name>.dart.')
    ..writeln('library;')
    ..writeln()
    ..writeln("import 'package:modoo_plugin_api/modoo_plugin_api.dart';");

  for (final plugin in plugins) {
    buffer.writeln("import 'package:${plugin.name}/${plugin.name}.dart' as ${plugin.alias};");
  }

  buffer
    ..writeln()
    ..writeln('/// Plugins compiled into this build, in registration order.')
    ..writeln('List<ModooPlugin> buildPluginList() => <ModooPlugin>[');
  for (final plugin in plugins) {
    buffer.writeln('  ${plugin.alias}.createPlugin(),');
  }
  buffer.writeln('];');

  final output = File(
    p.join(root.path, 'apps', 'mobile', 'lib', 'src', 'plugins', 'registry.g.dart'),
  );
  output.parent.createSync(recursive: true);
  final previous = output.existsSync() ? output.readAsStringSync() : '';
  if (previous == buffer.toString()) {
    stdout.writeln('gen:registry - unchanged (${plugins.length} plugin(s))');
    return;
  }
  output.writeAsStringSync(buffer.toString());
  stdout.writeln(
    'gen:registry - wrote ${p.relative(output.path, from: root.path)} (${plugins.length} plugin(s))',
  );
}

List<_DiscoveredPlugin> _discoverPlugins(Directory root) {
  final pluginsDir = Directory(p.join(root.path, 'plugins'));
  if (!pluginsDir.existsSync()) {
    return const <_DiscoveredPlugin>[];
  }
  final found = <_DiscoveredPlugin>[];
  final dirs = pluginsDir.listSync().whereType<Directory>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final dir in dirs) {
    final pubspecFile = File(p.join(dir.path, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      continue;
    }
    final text = pubspecFile.readAsStringSync();
    if (!text.contains('modoo_plugin_api')) {
      continue;
    }
    final pubspec = loadYaml(text) as YamlMap;
    final name = pubspec['name'].toString();
    final entrypoint = File(p.join(dir.path, 'lib', '$name.dart'));
    if (!entrypoint.existsSync()) {
      stderr.writeln('plugin $name must expose lib/$name.dart');
      exit(1);
    }
    if (!entrypoint.readAsStringSync().contains('createPlugin')) {
      stderr.writeln('plugin $name must export ModooPlugin createPlugin()');
      exit(1);
    }
    found.add(_DiscoveredPlugin(name));
  }
  return found;
}

final class _DiscoveredPlugin {
  const _DiscoveredPlugin(this.name);

  final String name;

  String get alias => name;
}
