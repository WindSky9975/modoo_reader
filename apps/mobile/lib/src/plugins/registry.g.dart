// GENERATED CODE - DO NOT MODIFY BY HAND.
//
// Regenerate with: dart run tool/gen_registry.dart
// Discovery rule: every plugins/* package whose pubspec.yaml depends
// on modoo_plugin_api must expose `ModooPlugin createPlugin()`
// from lib/<package_name>.dart.
library;

import 'package:modoo_plugin_api/modoo_plugin_api.dart';
import 'package:modoo_format_txt/modoo_format_txt.dart' as modoo_format_txt;

/// Plugins compiled into this build, in registration order.
List<ModooPlugin> buildPluginList() => <ModooPlugin>[modoo_format_txt.createPlugin()];
