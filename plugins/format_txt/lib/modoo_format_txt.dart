/// TXT format plugin.
///
/// Depends on `modoo_plugin_api` only: no Flutter, no `dart:io`, no database
/// (CODE_STYLE §9.1). The host streams the file in through [FileHandle].
library;

import 'package:modoo_plugin_api/modoo_plugin_api.dart';

import 'src/txt_parser.dart';

export 'src/txt_parser.dart';

const PluginManifest _manifest = PluginManifest(
  id: 'modoo.format.txt',
  name: 'TXT',
  version: '0.1.0',
  sdkConstraint: ModooPluginApi.versionRange,
  capabilities: <Type>{BookFormatParser},
);

/// Registers the plain-text parser with the host.
final class TxtPlugin implements ModooPlugin {
  const TxtPlugin();

  @override
  PluginManifest get manifest => _manifest;

  @override
  Future<void> register(PluginContext context) async {
    context.bind<BookFormatParser>(const TxtFormatParser(), types: const <Type>{BookFormatParser});
  }
}

/// Entry point discovered by `tool/gen_registry.dart`.
ModooPlugin createPlugin() => const TxtPlugin();
