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

/// Reading theme; persisted in M1 follow-up.

@ProviderFor(ThemeController)
final themeControllerProvider = ThemeControllerProvider._();

/// Reading theme; persisted in M1 follow-up.
final class ThemeControllerProvider extends $NotifierProvider<ThemeController, AppThemeVariant> {
  /// Reading theme; persisted in M1 follow-up.
  ThemeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeControllerHash();

  @$internal
  @override
  ThemeController create() => ThemeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppThemeVariant value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppThemeVariant>(value),
    );
  }
}

String _$themeControllerHash() => r'c928efeca15066f32e692830ceb1da0e06898716';

/// Reading theme; persisted in M1 follow-up.

abstract class _$ThemeController extends $Notifier<AppThemeVariant> {
  AppThemeVariant build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppThemeVariant, AppThemeVariant>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppThemeVariant, AppThemeVariant>,
              AppThemeVariant,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
