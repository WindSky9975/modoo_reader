/// EPUB format plugin.
///
/// Depends on `modoo_plugin_api` plus two pure-Dart packages: `archive` to open
/// the OCF container and `html` to turn XHTML into text. No Flutter, no
/// `dart:io`, no database (CODE_STYLE §9.1) — the host hands in bytes through
/// [FileHandle].
library;

import 'package:modoo_plugin_api/modoo_plugin_api.dart';

import 'src/epub_parser.dart';

export 'src/epub_parser.dart';

const PluginManifest _manifest = PluginManifest(
  id: 'modoo.format.epub',
  name: 'EPUB',
  version: '0.1.0',
  sdkConstraint: ModooPluginApi.versionRange,
  capabilities: <Type>{BookFormatParser},
);

/// Registers the EPUB parser with the host.
final class EpubPlugin implements ModooPlugin {
  const EpubPlugin();

  @override
  PluginManifest get manifest => _manifest;

  @override
  Future<void> register(PluginContext context) async {
    context.bind<BookFormatParser>(const EpubFormatParser(), types: const <Type>{BookFormatParser});
  }
}

/// Entry point discovered by `tool/gen_registry.dart`.
ModooPlugin createPlugin() => const EpubPlugin();
