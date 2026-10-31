import 'dart:typed_data';

import 'package:modoo_core/modoo_core.dart';
import 'package:test/test.dart';

void main() {
  group('AppException', () {
    test('exposes a stable code per subclass', () {
      expect(const StorageException('disk full').code, 'storage');
      expect(const ParseException('truncated').code, 'parse');
      expect(const NetworkException('timeout').code, 'network');
      expect(const SyncException('auth').code, 'sync');
      expect(const PluginException('boom', pluginId: 'modoo.format.txt').code, 'plugin');
      expect(
        const UnsupportedFormatException('no parser', formatId: 'cbz').code,
        'unsupported_format',
      );
    });

    test('carries plugin and format identifiers for diagnostics', () {
      const exception = UnsupportedFormatException('no parser', formatId: 'cbz');
      expect(exception.formatId, 'cbz');
      expect(exception.toString(), 'UnsupportedFormatException(unsupported_format): no parser');
    });

    test('can be caught through the sealed supertype', () {
      Object? caught;
      try {
        throw const StorageException('nope', cause: 'ENOENT');
      } on AppException catch (error) {
        caught = error;
      }
      expect(caught, isA<StorageException>());
      expect((caught as AppException).cause, 'ENOENT');
    });
  });

  group('InlineTaskRunner', () {
    test('returns the task result', () async {
      const runner = InlineTaskRunner();
      expect(await runner.run(() => 42), 42);
    });

    test('propagates failures unchanged', () async {
      const runner = InlineTaskRunner();
      await expectLater(
        runner.run<void>(() => throw const ParseException('bad')),
        throwsA(isA<ParseException>()),
      );
    });
  });

  group('FileSystemPort contract', () {
    test('is implementable with in-memory data', () async {
      final port = _MemoryFileSystem(<String, List<int>>{
        'a.txt': <int>[1, 2, 3],
      });
      expect(await port.exists('a.txt'), isTrue);
      expect(await port.length('a.txt'), 3);
      expect(await port.readBytes('a.txt'), Uint8List.fromList(<int>[1, 2, 3]));
      expect(await port.openRead('a.txt').expand((chunk) => chunk).toList(), <int>[1, 2, 3]);
    });
  });
}

final class _MemoryFileSystem implements FileSystemPort {
  _MemoryFileSystem(this._files);

  final Map<String, List<int>> _files;

  @override
  Future<bool> exists(String path) async => _files.containsKey(path);

  @override
  Future<int> length(String path) async => _files[path]?.length ?? 0;

  @override
  Future<Uint8List> readBytes(String path) async =>
      Uint8List.fromList(_files[path] ?? const <int>[]);

  @override
  Stream<List<int>> openRead(String path) => Stream<List<int>>.value(_files[path] ?? const <int>[]);
}
