import 'package:modoo_data/modoo_data.dart';
import 'package:modoo_domain/modoo_domain.dart';
import 'package:modoo_plugin_host/modoo_plugin_host.dart';
import 'package:modoo_ui/modoo_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_providers.g.dart';

/// Opened once in `main` and overridden there.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) => throw UnimplementedError('override in main()');

/// Initialized once in `main` and overridden there.
@Riverpod(keepAlive: true)
PluginRegistry pluginRegistry(Ref ref) => throw UnimplementedError('override in main()');

/// Single entry point to the shelf.
@Riverpod(keepAlive: true)
BookRepository bookRepository(Ref ref) => DriftBookRepository(ref.watch(appDatabaseProvider));

/// Books on the shelf, live from the database.
@riverpod
Stream<List<Book>> books(Ref ref) => ref.watch(bookRepositoryProvider).watchAll();

/// Reading theme; persisted in M1.
@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  @override
  AppThemeVariant build() => AppThemeVariant.paper;

  void select(AppThemeVariant variant) => state = variant;
}
