// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Opened once in `main` and overridden there.

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// Opened once in `main` and overridden there.

final class AppDatabaseProvider extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// Opened once in `main` and overridden there.
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'09cb7d3cedce21c6c1a1275e6455f86ca6b021b0';

/// Initialized once in `main` and overridden there.

@ProviderFor(pluginRegistry)
final pluginRegistryProvider = PluginRegistryProvider._();

/// Initialized once in `main` and overridden there.

final class PluginRegistryProvider
    extends $FunctionalProvider<PluginRegistry, PluginRegistry, PluginRegistry>
    with $Provider<PluginRegistry> {
  /// Initialized once in `main` and overridden there.
  PluginRegistryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pluginRegistryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pluginRegistryHash();

  @$internal
  @override
  $ProviderElement<PluginRegistry> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PluginRegistry create(Ref ref) {
    return pluginRegistry(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PluginRegistry value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PluginRegistry>(value),
    );
  }
}

String _$pluginRegistryHash() => r'68b11ed63b2a6b50cbab5ff6dd5e6a19c7d9de0f';

/// Where imported book copies live; created in `main` and overridden there.

@ProviderFor(libraryDirectory)
final libraryDirectoryProvider = LibraryDirectoryProvider._();

/// Where imported book copies live; created in `main` and overridden there.

final class LibraryDirectoryProvider extends $FunctionalProvider<Directory, Directory, Directory>
    with $Provider<Directory> {
  /// Where imported book copies live; created in `main` and overridden there.
  LibraryDirectoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryDirectoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryDirectoryHash();

  @$internal
  @override
  $ProviderElement<Directory> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  Directory create(Ref ref) {
    return libraryDirectory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Directory value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Directory>(value));
  }
}

String _$libraryDirectoryHash() => r'e09098e875d787b49d80b83e4ad8b22ec6ece61f';

/// Reader preferences as they were when the app started.
///
/// Loaded in `main` so the first frame already uses the saved theme instead of
/// flashing the default one, then overridden there.

@ProviderFor(initialReaderSettings)
final initialReaderSettingsProvider = InitialReaderSettingsProvider._();

/// Reader preferences as they were when the app started.
///
/// Loaded in `main` so the first frame already uses the saved theme instead of
/// flashing the default one, then overridden there.

final class InitialReaderSettingsProvider
    extends $FunctionalProvider<ReaderSettings, ReaderSettings, ReaderSettings>
    with $Provider<ReaderSettings> {
  /// Reader preferences as they were when the app started.
  ///
  /// Loaded in `main` so the first frame already uses the saved theme instead of
  /// flashing the default one, then overridden there.
  InitialReaderSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initialReaderSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialReaderSettingsHash();

  @$internal
  @override
  $ProviderElement<ReaderSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReaderSettings create(Ref ref) {
    return initialReaderSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReaderSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReaderSettings>(value),
    );
  }
}

String _$initialReaderSettingsHash() => r'85734c023fb6b4835d57b868b4ff5aea58b407db';

/// Single entry point to the shelf.

@ProviderFor(bookRepository)
final bookRepositoryProvider = BookRepositoryProvider._();

/// Single entry point to the shelf.

final class BookRepositoryProvider
    extends $FunctionalProvider<BookRepository, BookRepository, BookRepository>
    with $Provider<BookRepository> {
  /// Single entry point to the shelf.
  BookRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookRepositoryHash();

  @$internal
  @override
  $ProviderElement<BookRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BookRepository create(Ref ref) {
    return bookRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookRepository>(value),
    );
  }
}

String _$bookRepositoryHash() => r'eee7bc429ef790736095c9656e47692c16e73a40';

/// Chapters of one book.

@ProviderFor(chapterRepository)
final chapterRepositoryProvider = ChapterRepositoryProvider._();

/// Chapters of one book.

final class ChapterRepositoryProvider
    extends $FunctionalProvider<ChapterRepository, ChapterRepository, ChapterRepository>
    with $Provider<ChapterRepository> {
  /// Chapters of one book.
  ChapterRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chapterRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chapterRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChapterRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChapterRepository create(Ref ref) {
    return chapterRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChapterRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChapterRepository>(value),
    );
  }
}

String _$chapterRepositoryHash() => r'6d36976e20ddc459b75ed10783657d40c482b600';

/// Reading positions, one per book.

@ProviderFor(progressRepository)
final progressRepositoryProvider = ProgressRepositoryProvider._();

/// Reading positions, one per book.

final class ProgressRepositoryProvider
    extends $FunctionalProvider<ProgressRepository, ProgressRepository, ProgressRepository>
    with $Provider<ProgressRepository> {
  /// Reading positions, one per book.
  ProgressRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'progressRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$progressRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProgressRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProgressRepository create(Ref ref) {
    return progressRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgressRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgressRepository>(value),
    );
  }
}

String _$progressRepositoryHash() => r'eb9fc8dcc51f379088e3b31d9fe0422cac1043bc';

/// Persisted reader preferences.

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

/// Persisted reader preferences.

final class SettingsRepositoryProvider
    extends $FunctionalProvider<SettingsRepository, SettingsRepository, SettingsRepository>
    with $Provider<SettingsRepository> {
  /// Persisted reader preferences.
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() => r'0eda22c9c7a5e68c8661bf58b528d73264ef9a19';

/// Pagination cache; a miss only costs one re-layout.

@ProviderFor(pageLayoutRepository)
final pageLayoutRepositoryProvider = PageLayoutRepositoryProvider._();

/// Pagination cache; a miss only costs one re-layout.

final class PageLayoutRepositoryProvider
    extends $FunctionalProvider<PageLayoutRepository, PageLayoutRepository, PageLayoutRepository>
    with $Provider<PageLayoutRepository> {
  /// Pagination cache; a miss only costs one re-layout.
  PageLayoutRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pageLayoutRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pageLayoutRepositoryHash();

  @$internal
  @override
  $ProviderElement<PageLayoutRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PageLayoutRepository create(Ref ref) {
    return pageLayoutRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PageLayoutRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PageLayoutRepository>(value),
    );
  }
}

String _$pageLayoutRepositoryHash() => r'ddffd087735b2c4522acb82c541d445bd524ab32';

/// Saved spots inside books.

@ProviderFor(bookmarkRepository)
final bookmarkRepositoryProvider = BookmarkRepositoryProvider._();

/// Saved spots inside books.

final class BookmarkRepositoryProvider
    extends $FunctionalProvider<BookmarkRepository, BookmarkRepository, BookmarkRepository>
    with $Provider<BookmarkRepository> {
  /// Saved spots inside books.
  BookmarkRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookmarkRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookmarkRepositoryHash();

  @$internal
  @override
  $ProviderElement<BookmarkRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BookmarkRepository create(Ref ref) {
    return bookmarkRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookmarkRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookmarkRepository>(value),
    );
  }
}

String _$bookmarkRepositoryHash() => r'133988f76c368d2dc1e8d491def9acd30636e258';

/// The reader's own paragraph notes.

@ProviderFor(annotationRepository)
final annotationRepositoryProvider = AnnotationRepositoryProvider._();

/// The reader's own paragraph notes.

final class AnnotationRepositoryProvider
    extends $FunctionalProvider<AnnotationRepository, AnnotationRepository, AnnotationRepository>
    with $Provider<AnnotationRepository> {
  /// The reader's own paragraph notes.
  AnnotationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'annotationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$annotationRepositoryHash();

  @$internal
  @override
  $ProviderElement<AnnotationRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnnotationRepository create(Ref ref) {
    return annotationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnnotationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnnotationRepository>(value),
    );
  }
}

String _$annotationRepositoryHash() => r'fa35a76735be719e0f80e3d2507e7c019f5fce0c';

/// Reading sessions, the raw material for the statistics screen.

@ProviderFor(statsRepository)
final statsRepositoryProvider = StatsRepositoryProvider._();

/// Reading sessions, the raw material for the statistics screen.

final class StatsRepositoryProvider
    extends $FunctionalProvider<StatsRepository, StatsRepository, StatsRepository>
    with $Provider<StatsRepository> {
  /// Reading sessions, the raw material for the statistics screen.
  StatsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsRepositoryHash();

  @$internal
  @override
  $ProviderElement<StatsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StatsRepository create(Ref ref) {
    return statsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsRepository>(value),
    );
  }
}

String _$statsRepositoryHash() => r'caf69defc71873be38131ced6d15a9c2d63ba769';

/// Measured with `TextPainter`, so it has to run on the UI isolate.

@ProviderFor(textLayoutEngine)
final textLayoutEngineProvider = TextLayoutEngineProvider._();

/// Measured with `TextPainter`, so it has to run on the UI isolate.

final class TextLayoutEngineProvider
    extends $FunctionalProvider<TextLayoutEngine, TextLayoutEngine, TextLayoutEngine>
    with $Provider<TextLayoutEngine> {
  /// Measured with `TextPainter`, so it has to run on the UI isolate.
  TextLayoutEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'textLayoutEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$textLayoutEngineHash();

  @$internal
  @override
  $ProviderElement<TextLayoutEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TextLayoutEngine create(Ref ref) {
    return textLayoutEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TextLayoutEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TextLayoutEngine>(value),
    );
  }
}

String _$textLayoutEngineHash() => r'0fd4327a9f3b44077086f26892e62ebd30f9b2d2';

/// Diagnostics channel; overridden in tests that want silence.

@ProviderFor(logger)
final loggerProvider = LoggerProvider._();

/// Diagnostics channel; overridden in tests that want silence.

final class LoggerProvider extends $FunctionalProvider<ModooLogger, ModooLogger, ModooLogger>
    with $Provider<ModooLogger> {
  /// Diagnostics channel; overridden in tests that want silence.
  LoggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loggerHash();

  @$internal
  @override
  $ProviderElement<ModooLogger> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ModooLogger create(Ref ref) {
    return logger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ModooLogger value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ModooLogger>(value),
    );
  }
}

String _$loggerHash() => r'7609d6fe4c101ba6d63e0ff47418212b234a7dfe';

/// Books on the shelf, live from the database.

@ProviderFor(books)
final booksProvider = BooksProvider._();

/// Books on the shelf, live from the database.

final class BooksProvider
    extends $FunctionalProvider<AsyncValue<List<Book>>, List<Book>, Stream<List<Book>>>
    with $FutureModifier<List<Book>>, $StreamProvider<List<Book>> {
  /// Books on the shelf, live from the database.
  BooksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'booksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$booksHash();

  @$internal
  @override
  $StreamProviderElement<List<Book>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Book>> create(Ref ref) {
    return books(ref);
  }
}

String _$booksHash() => r'610f8eb72b8210c58a6a98aa4d89c5e9ad6ce879';

/// Chapters of one book, in order.

@ProviderFor(chapters)
final chaptersProvider = ChaptersFamily._();

/// Chapters of one book, in order.

final class ChaptersProvider
    extends $FunctionalProvider<AsyncValue<List<Chapter>>, List<Chapter>, FutureOr<List<Chapter>>>
    with $FutureModifier<List<Chapter>>, $FutureProvider<List<Chapter>> {
  /// Chapters of one book, in order.
  ChaptersProvider._({required ChaptersFamily super.from, required int super.argument})
    : super(
        retry: null,
        name: r'chaptersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chaptersHash();

  @override
  String toString() {
    return r'chaptersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Chapter>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Chapter>> create(Ref ref) {
    final argument = this.argument as int;
    return chapters(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChaptersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chaptersHash() => r'1c90aab442aafb1b73d224aa072f55e481d72ef3';

/// Chapters of one book, in order.

final class ChaptersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Chapter>>, int> {
  ChaptersFamily._()
    : super(
        retry: null,
        name: r'chaptersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Chapters of one book, in order.

  ChaptersProvider call(int bookId) => ChaptersProvider._(argument: bookId, from: this);

  @override
  String toString() => r'chaptersProvider';
}

/// One book's metadata (title, encoding, chapter count).

@ProviderFor(bookById)
final bookByIdProvider = BookByIdFamily._();

/// One book's metadata (title, encoding, chapter count).

final class BookByIdProvider extends $FunctionalProvider<AsyncValue<Book?>, Book?, FutureOr<Book?>>
    with $FutureModifier<Book?>, $FutureProvider<Book?> {
  /// One book's metadata (title, encoding, chapter count).
  BookByIdProvider._({required BookByIdFamily super.from, required int super.argument})
    : super(
        retry: null,
        name: r'bookByIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookByIdHash();

  @override
  String toString() {
    return r'bookByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Book?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Book?> create(Ref ref) {
    final argument = this.argument as int;
    return bookById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookByIdHash() => r'12d63fb61b7341db8da867c53866a3505a138120';

/// One book's metadata (title, encoding, chapter count).

final class BookByIdFamily extends $Family with $FunctionalFamilyOverride<FutureOr<Book?>, int> {
  BookByIdFamily._()
    : super(
        retry: null,
        name: r'bookByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One book's metadata (title, encoding, chapter count).

  BookByIdProvider call(int bookId) => BookByIdProvider._(argument: bookId, from: this);

  @override
  String toString() => r'bookByIdProvider';
}

/// Saved position of one book, if any.

@ProviderFor(readingProgress)
final readingProgressProvider = ReadingProgressFamily._();

/// Saved position of one book, if any.

final class ReadingProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReadingProgress?>,
          ReadingProgress?,
          FutureOr<ReadingProgress?>
        >
    with $FutureModifier<ReadingProgress?>, $FutureProvider<ReadingProgress?> {
  /// Saved position of one book, if any.
  ReadingProgressProvider._({
    required ReadingProgressFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'readingProgressProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$readingProgressHash();

  @override
  String toString() {
    return r'readingProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ReadingProgress?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ReadingProgress?> create(Ref ref) {
    final argument = this.argument as int;
    return readingProgress(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReadingProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$readingProgressHash() => r'60ff1a4e0f1f709a9d6cdf8ea8fcbe4a6280131b';

/// Saved position of one book, if any.

final class ReadingProgressFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ReadingProgress?>, int> {
  ReadingProgressFamily._()
    : super(
        retry: null,
        name: r'readingProgressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Saved position of one book, if any.

  ReadingProgressProvider call(int bookId) =>
      ReadingProgressProvider._(argument: bookId, from: this);

  @override
  String toString() => r'readingProgressProvider';
}

/// Bookmarks of one book, ordered by position.

@ProviderFor(bookmarks)
final bookmarksProvider = BookmarksFamily._();

/// Bookmarks of one book, ordered by position.

final class BookmarksProvider
    extends $FunctionalProvider<AsyncValue<List<Bookmark>>, List<Bookmark>, Stream<List<Bookmark>>>
    with $FutureModifier<List<Bookmark>>, $StreamProvider<List<Bookmark>> {
  /// Bookmarks of one book, ordered by position.
  BookmarksProvider._({required BookmarksFamily super.from, required int super.argument})
    : super(
        retry: null,
        name: r'bookmarksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookmarksHash();

  @override
  String toString() {
    return r'bookmarksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Bookmark>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Bookmark>> create(Ref ref) {
    final argument = this.argument as int;
    return bookmarks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookmarksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookmarksHash() => r'ef5353a9c450058b195eb3c14a4fab349553a2f2';

/// Bookmarks of one book, ordered by position.

final class BookmarksFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Bookmark>>, int> {
  BookmarksFamily._()
    : super(
        retry: null,
        name: r'bookmarksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Bookmarks of one book, ordered by position.

  BookmarksProvider call(int bookId) => BookmarksProvider._(argument: bookId, from: this);

  @override
  String toString() => r'bookmarksProvider';
}

/// Paragraph notes of one book, ordered by position.

@ProviderFor(annotations)
final annotationsProvider = AnnotationsFamily._();

/// Paragraph notes of one book, ordered by position.

final class AnnotationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Annotation>>,
          List<Annotation>,
          Stream<List<Annotation>>
        >
    with $FutureModifier<List<Annotation>>, $StreamProvider<List<Annotation>> {
  /// Paragraph notes of one book, ordered by position.
  AnnotationsProvider._({required AnnotationsFamily super.from, required int super.argument})
    : super(
        retry: null,
        name: r'annotationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$annotationsHash();

  @override
  String toString() {
    return r'annotationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Annotation>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Annotation>> create(Ref ref) {
    final argument = this.argument as int;
    return annotations(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AnnotationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$annotationsHash() => r'ef4454c944bda6328fb86f966ce2f92e6e27b21e';

/// Paragraph notes of one book, ordered by position.

final class AnnotationsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Annotation>>, int> {
  AnnotationsFamily._()
    : super(
        retry: null,
        name: r'annotationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Paragraph notes of one book, ordered by position.

  AnnotationsProvider call(int bookId) => AnnotationsProvider._(argument: bookId, from: this);

  @override
  String toString() => r'annotationsProvider';
}

/// Every reading session, oldest first.

@ProviderFor(readingSessions)
final readingSessionsProvider = ReadingSessionsProvider._();

/// Every reading session, oldest first.

final class ReadingSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ReadingSession>>,
          List<ReadingSession>,
          Stream<List<ReadingSession>>
        >
    with $FutureModifier<List<ReadingSession>>, $StreamProvider<List<ReadingSession>> {
  /// Every reading session, oldest first.
  ReadingSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingSessionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingSessionsHash();

  @$internal
  @override
  $StreamProviderElement<List<ReadingSession>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<ReadingSession>> create(Ref ref) {
    return readingSessions(ref);
  }
}

String _$readingSessionsHash() => r'aaa318a380c76791483d3eae77a316cf48778dac';

/// Sessions folded into the numbers the statistics screen shows.
///
/// The fold runs in Dart so that changing how days are bucketed never needs a
/// database migration; a few thousand rows sum up in well under a millisecond.

@ProviderFor(readingStats)
final readingStatsProvider = ReadingStatsProvider._();

/// Sessions folded into the numbers the statistics screen shows.
///
/// The fold runs in Dart so that changing how days are bucketed never needs a
/// database migration; a few thousand rows sum up in well under a millisecond.

final class ReadingStatsProvider
    extends $FunctionalProvider<ReadingStats, ReadingStats, ReadingStats>
    with $Provider<ReadingStats> {
  /// Sessions folded into the numbers the statistics screen shows.
  ///
  /// The fold runs in Dart so that changing how days are bucketed never needs a
  /// database migration; a few thousand rows sum up in well under a millisecond.
  ReadingStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingStatsHash();

  @$internal
  @override
  $ProviderElement<ReadingStats> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReadingStats create(Ref ref) {
    return readingStats(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadingStats value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadingStats>(value),
    );
  }
}

String _$readingStatsHash() => r'42655227a3884a4d5f44157abb415176c9b68bd0';

/// The whole book as text, decoded once and cached while reading.
///
/// Import always writes a UTF-8 copy (see `ImportService`), so this is a plain
/// decode; character offsets from the database index into this string.

@ProviderFor(bookText)
final bookTextProvider = BookTextFamily._();

/// The whole book as text, decoded once and cached while reading.
///
/// Import always writes a UTF-8 copy (see `ImportService`), so this is a plain
/// decode; character offsets from the database index into this string.

final class BookTextProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The whole book as text, decoded once and cached while reading.
  ///
  /// Import always writes a UTF-8 copy (see `ImportService`), so this is a plain
  /// decode; character offsets from the database index into this string.
  BookTextProvider._({required BookTextFamily super.from, required int super.argument})
    : super(
        retry: null,
        name: r'bookTextProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookTextHash();

  @override
  String toString() {
    return r'bookTextProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as int;
    return bookText(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookTextProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookTextHash() => r'5b57d4b4dafafd7ff64931e4fc98b0d48789a43b';

/// The whole book as text, decoded once and cached while reading.
///
/// Import always writes a UTF-8 copy (see `ImportService`), so this is a plain
/// decode; character offsets from the database index into this string.

final class BookTextFamily extends $Family with $FunctionalFamilyOverride<FutureOr<String>, int> {
  BookTextFamily._()
    : super(
        retry: null,
        name: r'bookTextProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The whole book as text, decoded once and cached while reading.
  ///
  /// Import always writes a UTF-8 copy (see `ImportService`), so this is a plain
  /// decode; character offsets from the database index into this string.

  BookTextProvider call(int bookId) => BookTextProvider._(argument: bookId, from: this);

  @override
  String toString() => r'bookTextProvider';
}

/// Stable id of this installation, used to key synced progress.
///
/// TODO(M5): persist a generated UUID in app support storage instead of the
/// host name, so two devices with the same host name do not collide.

@ProviderFor(deviceId)
final deviceIdProvider = DeviceIdProvider._();

/// Stable id of this installation, used to key synced progress.
///
/// TODO(M5): persist a generated UUID in app support storage instead of the
/// host name, so two devices with the same host name do not collide.

final class DeviceIdProvider extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Stable id of this installation, used to key synced progress.
  ///
  /// TODO(M5): persist a generated UUID in app support storage instead of the
  /// host name, so two devices with the same host name do not collide.
  DeviceIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceIdHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return deviceId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<String>(value));
  }
}

String _$deviceIdHash() => r'070daf923bc513c17d51f4eb7d5fffdedae4e8e8';

/// Reader typography, persisted on every change.
///
/// Writes are fire-and-forget: a lost preference is a nuisance, a slider that
/// waits for SQLite is worse.

@ProviderFor(ReaderSettingsController)
final readerSettingsControllerProvider = ReaderSettingsControllerProvider._();

/// Reader typography, persisted on every change.
///
/// Writes are fire-and-forget: a lost preference is a nuisance, a slider that
/// waits for SQLite is worse.
final class ReaderSettingsControllerProvider
    extends $NotifierProvider<ReaderSettingsController, ReaderSettings> {
  /// Reader typography, persisted on every change.
  ///
  /// Writes are fire-and-forget: a lost preference is a nuisance, a slider that
  /// waits for SQLite is worse.
  ReaderSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readerSettingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readerSettingsControllerHash();

  @$internal
  @override
  ReaderSettingsController create() => ReaderSettingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReaderSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReaderSettings>(value),
    );
  }
}

String _$readerSettingsControllerHash() => r'b2bf1ed787de1448553b5ce79d171e86315b8999';

/// Reader typography, persisted on every change.
///
/// Writes are fire-and-forget: a lost preference is a nuisance, a slider that
/// waits for SQLite is worse.

abstract class _$ReaderSettingsController extends $Notifier<ReaderSettings> {
  ReaderSettings build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ReaderSettings, ReaderSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReaderSettings, ReaderSettings>,
              ReaderSettings,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Reading theme derived from the persisted settings.

@ProviderFor(appTheme)
final appThemeProvider = AppThemeProvider._();

/// Reading theme derived from the persisted settings.

final class AppThemeProvider
    extends $FunctionalProvider<AppThemeVariant, AppThemeVariant, AppThemeVariant>
    with $Provider<AppThemeVariant> {
  /// Reading theme derived from the persisted settings.
  AppThemeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemeHash();

  @$internal
  @override
  $ProviderElement<AppThemeVariant> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppThemeVariant create(Ref ref) {
    return appTheme(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppThemeVariant value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppThemeVariant>(value),
    );
  }
}

String _$appThemeHash() => r'b7d05314b1f3f47893506290e2db8e33de5e1cc3';
