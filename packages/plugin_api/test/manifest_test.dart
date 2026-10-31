import 'package:modoo_plugin_api/modoo_plugin_api.dart';
import 'package:test/test.dart';

void main() {
  group('PluginManifest', () {
    test('is a const value usable before registration', () {
      const manifest = PluginManifest(
        id: 'modoo.format.txt',
        name: 'TXT',
        version: '0.1.0',
        sdkConstraint: ModooPluginApi.versionRange,
        capabilities: <Type>{BookFormatParser},
      );

      expect(manifest.id, 'modoo.format.txt');
      expect(manifest.capabilities, contains(BookFormatParser));
      expect(manifest.settings, isEmpty);
    });

    test('describes settings as data, not UI', () {
      const manifest = PluginManifest(
        id: 'modoo.format.txt',
        name: 'TXT',
        version: '0.1.0',
        sdkConstraint: ModooPluginApi.versionRange,
        settings: <PluginSetting>[
          SelectSetting(
            id: 'defaultEncoding',
            label: 'Default encoding',
            options: <SelectOption>[
              SelectOption(value: 'auto', label: 'Auto'),
              SelectOption(value: 'gbk', label: 'GBK'),
            ],
            defaultValue: 'auto',
          ),
        ],
      );

      final setting = manifest.settings.single;
      expect(setting, isA<SelectSetting>());
      expect((setting as SelectSetting).options, hasLength(2));
      expect(setting.id, 'defaultEncoding');
    });
  });

  test('sdk range format is declared in one place', () {
    expect(ModooPluginApi.versionRange, '>=0.1.0 <1.0.0');
    expect(ModooPluginApi.version, '0.1.0');
  });
}
