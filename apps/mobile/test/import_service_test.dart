import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modoo_core/modoo_core.dart';
import 'package:modoo_domain/modoo_domain.dart';
import 'package:modoo_plugin_api/modoo_plugin_api.dart';
import 'package:modoo_plugin_host/modoo_plugin_host.dart';
import 'package:modoo_reader/src/features/import/import_service.dart';

void main() {
  late Directory root;
  late Directory library;
  late _FakeBooks books;
  late _FakeChapters chapters;
  late _FakePlugin plugin;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('modoo_import_');
    library = Directory('${root.path}/library');
    books = _FakeBooks();
    chapters = _FakeChapters();
    plugin = _FakePlugin();
  });

  tearDown(() async {
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  });

  Future<ImportService> buildService() async {
    final PluginRegistry registry = PluginRegistry(
      plugins: <ModooPlugin>[plugin],
      logger: const SilentLogger(),
    );
    await registry.initialize();
    return ImportService(
      registry: registry,
      books: books,
      chapters: chapters,
      libraryDirectory: library,
    );
  }

  test('imports a UTF-8 file, writes a library copy and two chapters', () async {
    final File source = File('${root.path}/第一卷.txt');
    await source.writeAsString('第一章 开始\n他说：你好。\n第二章 结束\n再见。');

    final ImportService service = await buildService();
    final List<double> progress = <double>[];
    final ImportOutcome outcome = await service.importFile(
      sourcePath: source.path,
      onProgress: progress.add,
    );

    expect(outcome.chapterCount, 2);
    expect(outcome.book.title, '第一卷');
    expect(outcome.book.formatId, 'txt');
    expect(outcome.book.encoding, 'utf-8');
    expect(progress.last, 1);

    final List<File> copies = library.listSync().whereType<File>().toList(growable: false);
    expect(copies, hasLength(1));
    expect(await copies.single.readAsString(), '第一章 开始\n他说：你好。\n第二章 结束\n再见。');
    expect(outcome.book.filePath, copies.single.path);

    expect(chapters.stored[outcome.book.id], hasLength(2));
    expect(chapters.stored[outcome.book.id]!.first.title, '第一章 开始');
  });

  test('decodes a legacy GBK file into a UTF-8 copy', () async {
    final File source = File('${root.path}/gbk.txt');
    // 0xD6D0 0xCEC4 is "中文" in GBK.
    await source.writeAsBytes(<int>[0xD6, 0xD0, 0xCE, 0xC4, 0x0A]);

    final ImportService service = await buildService();
    final ImportOutcome outcome = await service.importFile(sourcePath: source.path);

    expect(outcome.book.encoding, 'utf-8');
    final List<File> copies = library.listSync().whereType<File>().toList(growable: false);
    expect(await copies.single.readAsString(), '中文\n');
  });

  test('rejects extensions no plugin claims and leaves no file behind', () async {
    final File source = File('${root.path}/book.pdf');
    await source.writeAsBytes(<int>[1, 2, 3]);

    final ImportService service = await buildService();
    await expectLater(
      service.importFile(sourcePath: source.path),
      throwsA(isA<UnsupportedFormatException>()),
    );
    expect(books.all, isEmpty);
    expect(await library.exists(), isFalse);
  });

  test('deletes the copy when the plugin refuses the file', () async {
    plugin.parser.supported = false;
    final File source = File('${root.path}/broken.txt');
    await source.writeAsString('anything');

    final ImportService service = await buildService();
    await expectLater(
      service.importFile(sourcePath: source.path),
      throwsA(isA<UnsupportedFormatException>()),
    );
    expect(books.all, isEmpty);
    expect(library.listSync(), isEmpty);
  });
}

final class _FakeBooks implements BookRepository {
  final Map<int, Book> all = <int, Book>{};
  int _next = 1;

  @override
  Future<int> insert(Book book) async {
    final int id = _next++;
    all[id] = book.copyWith(id: id);
    return id;
  }

  @override
  Future<Book?> findById(int id) async => all[id];

  @override
  Future<void> markOpened(int id, DateTime at) async {}

  @override
  Future<void> softDelete(int id) async {
    all.remove(id);
  }

  @override
  Stream<List<Book>> watchAll() => Stream<List<Book>>.value(all.values.toList());
}

final class _FakeChapters implements ChapterRepository {
  final Map<int, List<Chapter>> stored = <int, List<Chapter>>{};

  @override
  Future<List<Chapter>> listForBook(int bookId) async => stored[bookId] ?? const <Chapter>[];

  @override
  Future<Chapter?> findAt(int bookId, int index) async {
    for (final Chapter chapter in stored[bookId] ?? const <Chapter>[]) {
      if (chapter.index == index) {
        return chapter;
      }
    }
    return null;
  }

  @override
  Future<void> replaceAll(int bookId, List<Chapter> chapters) async {
    stored[bookId] = chapters;
  }
}

final class _FakePlugin implements ModooPlugin {
  final _FakeParser parser = _FakeParser();

  @override
  PluginManifest get manifest => const PluginManifest(
    id: 'modoo.format.fake',
    name: 'FAKE',
    version: '0.1.0',
    sdkConstraint: ModooPluginApi.versionRange,
    capabilities: <Type>{BookFormatParser},
  );

  @override
  Future<void> register(PluginContext context) async {
    context.bind<BookFormatParser>(parser);
  }
}

/// Parses two chapters by splitting on the first two newlines.
final class _FakeParser implements BookFormatParser {
  bool supported = true;

  @override
  String get formatId => 'txt';

  @override
  Set<String> get extensions => const <String>{'.txt'};

  @override
  Future<ProbeResult> probe(FileHandle file) async => supported
      ? const ProbeResult(supported: true, confidence: 0.9)
      : ProbeResult.unsupported('fake says no');

  @override
  Future<ImportResult> import(FileHandle file, ImportSink sink) async {
    final String text = await const Utf8Decoder().bind(file.openRead()).join();
    final List<String> lines = text.split('\n');
    final int firstEnd = lines.first.length;
    sink.addChapter(
      ChapterMeta(
        index: 0,
        title: lines.first,
        startOffset: 0,
        endOffset: firstEnd,
        wordCount: firstEnd,
      ),
    );
    sink.addChapter(
      ChapterMeta(
        index: 1,
        title: 'chapter two',
        startOffset: firstEnd,
        endOffset: text.length,
        wordCount: text.length - firstEnd,
      ),
    );
    sink.reportProgress(1);
    return ImportResult(chapterCount: 2, wordCount: text.length, encoding: 'utf-8');
  }

  @override
  Future<ChapterDoc> loadChapter(FileHandle file, ChapterRef chapter) async =>
      const ChapterDoc(text: '');
}
