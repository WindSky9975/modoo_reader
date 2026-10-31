/// Markdown format plugin.
///
/// Depends on `modoo_plugin_api` only: no Flutter, no `dart:io`, no database
/// (CODE_STYLE §9.1). The host transcodes the file to UTF-8 before probing, so
/// this parser never has to think about encodings.
library;

import 'package:modoo_plugin_api/modoo_plugin_api.dart';

import 'src/markdown_parser.dart';

export 'src/markdown_parser.dart';

const PluginManifest _manifest = PluginManifest(
  id: 'modoo.format.markdown',
  name: 'Markdown',
  version: '0.1.0',
  sdkConstraint: ModooPluginApi.versionRange,
  capabilities: <Type>{BookFormatParser},
);

/// Registers the Markdown parser with the host.
final class MarkdownPlugin implements ModooPlugin {
  const MarkdownPlugin();

  @override
  PluginManifest get manifest => _manifest;

  @override
  Future<void> register(PluginContext context) async {
    context.bind<BookFormatParser>(
      const MarkdownFormatParser(),
      types: const <Type>{BookFormatParser},
    );
  }
}

/// Entry point discovered by `tool/gen_registry.dart`.
ModooPlugin createPlugin() => const MarkdownPlugin();
