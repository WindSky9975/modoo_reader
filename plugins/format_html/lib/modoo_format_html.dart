/// HTML format plugin.
///
/// Depends on `modoo_plugin_api` and `html` only: no Flutter, no `dart:io`, no
/// database (CODE_STYLE §9.1). The host transcodes the file to UTF-8 first, so
/// a GBK-encoded page still reaches this parser as clean text.
library;

import 'package:modoo_plugin_api/modoo_plugin_api.dart';

import 'src/html_parser.dart';

export 'src/html_parser.dart';

const PluginManifest _manifest = PluginManifest(
  id: 'modoo.format.html',
  name: 'HTML',
  version: '0.1.0',
  sdkConstraint: ModooPluginApi.versionRange,
  capabilities: <Type>{BookFormatParser},
);

/// Registers the HTML parser with the host.
final class HtmlPlugin implements ModooPlugin {
  const HtmlPlugin();

  @override
  PluginManifest get manifest => _manifest;

  @override
  Future<void> register(PluginContext context) async {
    context.bind<BookFormatParser>(const HtmlFormatParser(), types: const <Type>{BookFormatParser});
  }
}

/// Entry point discovered by `tool/gen_registry.dart`.
ModooPlugin createPlugin() => const HtmlPlugin();
