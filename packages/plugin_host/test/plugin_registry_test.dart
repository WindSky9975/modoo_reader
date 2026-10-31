import 'package:modoo_core/modoo_core.dart';
import 'package:modoo_plugin_api/modoo_plugin_api.dart';
import 'package:modoo_plugin_host/modoo_plugin_host.dart';
import 'package:test/test.dart';

void main() {
  group('VersionConstraint', () {
    test('accepts a version inside the range', () {
      final constraint = VersionConstraint.parse(ModooPluginApi.versionRange);
      expect(constraint.allows(Version.parse('0.1.0')), isTrue);
      expect(constraint.allows(Version.parse('0.9.9')), isTrue);
      expect(constraint.allows(Version.parse('1.0.0')), isFalse);
      expect(constraint.allows(Version.parse('0.0.9')), isFalse);
    });

    test('supports caret ranges', () {
      final constraint = VersionConstraint.parse('^1.2.3');
      expect(constraint.allows(Version.parse('1.9.0')), isTrue);
      expect(constraint.allows(Version.parse('2.0.0')), isFalse);
    });

    test('rejects malformed constraints instead of silently allowing', () {
      expect(() => VersionConstraint.parse('>==1.0'), throwsFormatException);
    });
  });

  group('PluginRegistry', () {
    test('registers a compatible plugin and exposes its capability', () async {
      final registry = PluginRegistry(
        plugins: <ModooPlugin>[_FakePlugin(id: 'modoo.format.txt', parser: _FakeParser('.txt'))],
        logger: const SilentLogger(),
      );

      await registry.initialize();

      expect(registry.stateOf('modoo.format.txt'), PluginState.active);
      expect(registry.parserForExtension('.txt'), isNotNull);
      expect(registry.parserForExtension('.txt')!.formatId, 'txt');
      expect(registry.parserForExtension('.epub'), isNull);
    });

    test('marks incompatible SDK plugins instead of loading them', () async {
      final registry = PluginRegistry(
        plugins: <ModooPlugin>[
          _FakePlugin(id: 'modoo.old', parser: _FakeParser('.old'), constraint: '>=2.0.0 <3.0.0'),
        ],
        logger: const SilentLogger(),
      );

      await registry.initialize();

      expect(registry.stateOf('modoo.old'), PluginState.incompatible);
      expect(registry.formatParsers, isEmpty);
    });

    test('isolates a plugin that throws during registration', () async {
      final registry = PluginRegistry(
        plugins: <ModooPlugin>[
          _ThrowingPlugin(),
          _FakePlugin(id: 'modoo.format.txt', parser: _FakeParser('.txt')),
        ],
        logger: const SilentLogger(),
      );

      await registry.initialize();

      expect(registry.stateOf('modoo.broken'), PluginState.failed);
      expect(registry.stateOf('modoo.format.txt'), PluginState.active);
      expect(registry.formatParsers, hasLength(1));
    });
  });
}

final class _FakePlugin implements ModooPlugin {
  _FakePlugin({
    required this.id,
    required BookFormatParser parser,
    this.constraint = ModooPluginApi.versionRange,
  }) : _parser = parser;

  final String id;
  final String constraint;
  final BookFormatParser _parser;

  @override
  PluginManifest get manifest => PluginManifest(
    id: id,
    name: 'Fake',
    version: '0.1.0',
    sdkConstraint: constraint,
    capabilities: <Type>{BookFormatParser},
  );

  @override
  Future<void> register(PluginContext context) async => context.bind<BookFormatParser>(_parser);
}

final class _ThrowingPlugin implements ModooPlugin {
  @override
  PluginManifest get manifest => const PluginManifest(
    id: 'modoo.broken',
    name: 'Broken',
    version: '0.1.0',
    sdkConstraint: ModooPluginApi.versionRange,
  );

  @override
  Future<void> register(PluginContext context) async =>
      throw const PluginException('registration failed');
}

final class _FakeParser implements BookFormatParser {
  _FakeParser(this.extension);

  final String extension;

  @override
  String get formatId => extension.substring(1);

  @override
  Set<String> get extensions => <String>{extension};

  @override
  bool get handlesBinaryContainers => false;

  @override
  bool get rewritesContent => false;

  @override
  Future<ProbeResult> probe(FileHandle file) async => const ProbeResult(supported: true);

  @override
  Future<ImportResult> import(FileHandle file, ImportSink sink) async =>
      const ImportResult(chapterCount: 1, wordCount: 1);

  @override
  Future<ChapterDoc> loadChapter(FileHandle file, ChapterRef chapter) async =>
      const ChapterDoc(text: '');
}
