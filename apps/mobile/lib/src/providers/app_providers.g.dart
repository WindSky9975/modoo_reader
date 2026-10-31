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

/// Reading theme; persisted in M1.

@ProviderFor(ThemeController)
final themeControllerProvider = ThemeControllerProvider._();

/// Reading theme; persisted in M1.
final class ThemeControllerProvider extends $NotifierProvider<ThemeController, AppThemeVariant> {
  /// Reading theme; persisted in M1.
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

/// Reading theme; persisted in M1.

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
