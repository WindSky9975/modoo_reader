import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:modoo_core/modoo_core.dart';
import 'package:modoo_data/modoo_data.dart';
import 'package:modoo_domain/modoo_domain.dart';
import 'package:modoo_plugin_host/modoo_plugin_host.dart';
import 'package:modoo_reader_engine/modoo_reader_engine.dart';
import 'package:modoo_ui/modoo_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_providers.g.dart';

/// Opened once in `main` and overridden there.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) => throw UnimplementedError('override in main()');

/// Initialized once in `main` and overridden there.
@Riverpod(keepAlive: true)
PluginRegistry pluginRegistry(Ref ref) => throw UnimplementedError('override in main()');

/// Where imported book copies live; created in `main` and overridden there.
@Riverpod(keepAlive: true)
Directory libraryDirectory(Ref ref) => throw UnimplementedError('override in main()');

/// Reader preferences as they were when the app started.
///
/// Loaded in `main` so the first frame already uses the saved theme instead of
/// flashing the default one, then overridden there.
@Riverpod(keepAlive: true)
ReaderSettings initialReaderSettings(Ref ref) => throw UnimplementedError('override in main()');

/// Single entry point to the shelf.
@Riverpod(keepAlive: true)
BookRepository bookRepository(Ref ref) => DriftBookRepository(ref.watch(appDatabaseProvider));

/// Chapters of one book.
@Riverpod(keepAlive: true)
ChapterRepository chapterRepository(Ref ref) =>
    DriftChapterRepository(ref.watch(appDatabaseProvider));

/// Reading positions, one per book.
@Riverpod(keepAlive: true)
ProgressRepository progressRepository(Ref ref) =>
    DriftProgressRepository(ref.watch(appDatabaseProvider));

/// Persisted reader preferences.
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    DriftSettingsRepository(ref.watch(appDatabaseProvider));

/// Pagination cache; a miss only costs one re-layout.
@Riverpod(keepAlive: true)
PageLayoutRepository pageLayoutRepository(Ref ref) =>
    DriftPageLayoutRepository(ref.watch(appDatabaseProvider));

/// Saved spots inside books.
@Riverpod(keepAlive: true)
BookmarkRepository bookmarkRepository(Ref ref) =>
    DriftBookmarkRepository(ref.watch(appDatabaseProvider));

/// Measured with `TextPainter`, so it has to run on the UI isolate.
@Riverpod(keepAlive: true)
TextLayoutEngine textLayoutEngine(Ref ref) => const TextPainterLayoutEngine();

/// Diagnostics channel; overridden in tests that want silence.
@Riverpod(keepAlive: true)
ModooLogger logger(Ref ref) => const DeveloperLogger();

/// Books on the shelf, live from the database.
@riverpod
Stream<List<Book>> books(Ref ref) => ref.watch(bookRepositoryProvider).watchAll();

/// Chapters of one book, in order.
@riverpod
Future<List<Chapter>> chapters(Ref ref, int bookId) =>
    ref.watch(chapterRepositoryProvider).listForBook(bookId);

/// Saved position of one book, if any.
@riverpod
Future<ReadingProgress?> readingProgress(Ref ref, int bookId) =>
    ref.watch(progressRepositoryProvider).read(bookId);

/// Bookmarks of one book, ordered by position.
@riverpod
Stream<List<Bookmark>> bookmarks(Ref ref, int bookId) =>
    ref.watch(bookmarkRepositoryProvider).watchForBook(bookId);

/// The whole book as text, decoded once and cached while reading.
///
/// Import always writes a UTF-8 copy (see `ImportService`), so this is a plain
/// decode; character offsets from the database index into this string.
@riverpod
Future<String> bookText(Ref ref, int bookId) async {
  final Book? book = await ref.watch(bookRepositoryProvider).findById(bookId);
  if (book == null) {
    throw StorageException('Book $bookId is not on the shelf');
  }
  final Uint8List bytes = await File(book.filePath).readAsBytes();
  return decodeText(bytes, TextEncoding.utf8);
}

/// Stable id of this installation, used to key synced progress.
///
/// TODO(M5): persist a generated UUID in app support storage instead of the
/// host name, so two devices with the same host name do not collide.
@Riverpod(keepAlive: true)
String deviceId(Ref ref) => 'device-${Platform.localHostname}';

/// Reader typography, persisted on every change.
///
/// Writes are fire-and-forget: a lost preference is a nuisance, a slider that
/// waits for SQLite is worse.
@Riverpod(keepAlive: true)
class ReaderSettingsController extends _$ReaderSettingsController {
  @override
  ReaderSettings build() => ref.watch(initialReaderSettingsProvider);

  void setFontSize(double value) => _update(state.copyWith(fontSize: value));

  void setLineHeight(double value) => _update(state.copyWith(lineHeight: value));

  void setThemeId(String themeId) => _update(state.copyWith(themeId: themeId));

  void setPageTurnId(String pageTurnId) => _update(state.copyWith(pageTurnId: pageTurnId));

  void _update(ReaderSettings next) {
    state = next.normalized();
    unawaited(ref.read(settingsRepositoryProvider).save(state).catchError((Object _) {}));
  }
}

/// Reading theme derived from the persisted settings.
@Riverpod(keepAlive: true)
AppThemeVariant appTheme(Ref ref) {
  final String id = ref.watch(readerSettingsControllerProvider).themeId;
  for (final AppThemeVariant variant in AppThemeVariant.values) {
    if (variant.name == id) return variant;
  }
  return AppThemeVariant.paper;
}
