import 'package:modoo_core/modoo_core.dart';
import 'package:modoo_plugin_api/modoo_plugin_api.dart';

import 'version_constraint.dart';

/// Lifecycle state of a plugin inside this build.
enum PluginState {
  /// Manifest accepted and `register()` completed.
  active,

  /// Turned off by the user; services are not bound.
  disabled,

  /// Declared SDK range does not include the host version.
  incompatible,

  /// `register()` threw. The plugin stays listed but unusable.
  failed,
}

/// Owns the plugin set and the services they bind.
///
/// Design rule: a broken plugin never takes the app down. Every failure is
/// recorded in [stateOf] and logged, and everything else keeps working
/// (DEVELOPMENT_PLAN §3.4.4).
final class PluginRegistry {
  PluginRegistry({
    required List<ModooPlugin> plugins,
    required ModooLogger logger,
    String sdkVersion = ModooPluginApi.version,
    Map<String, Object?> settings = const <String, Object?>{},
  }) : _plugins = List<ModooPlugin>.unmodifiable(plugins),
       _logger = logger,
       _sdkVersion = Version.parse(sdkVersion),
       _context = _RegistryContext(logger, settings);

  final List<ModooPlugin> _plugins;
  final ModooLogger _logger;
  final Version _sdkVersion;
  final _RegistryContext _context;
  final Map<String, PluginState> _states = <String, PluginState>{};

  /// All plugins in registry order, regardless of state.
  List<ModooPlugin> get plugins => _plugins;

  PluginState stateOf(String pluginId) => _states[pluginId] ?? PluginState.disabled;

  /// Runs every plugin that is compatible with this host.
  ///
  /// Safe to call once per app start; calling twice re-registers nothing
  /// because bindings are keyed by type and replaced.
  Future<void> initialize() async {
    for (final plugin in _plugins) {
      final manifest = plugin.manifest;
      if (!_isCompatible(manifest)) {
        _states[manifest.id] = PluginState.incompatible;
        _logger.warn(
          'plugin ${manifest.id} requires ${manifest.sdkConstraint}, host is $_sdkVersion',
        );
        continue;
      }
      try {
        await plugin.register(_context);
        _states[manifest.id] = PluginState.active;
      } on Object catch (error, stackTrace) {
        _states[manifest.id] = PluginState.failed;
        _logger.error(
          'plugin ${manifest.id} failed to register',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  bool _isCompatible(PluginManifest manifest) {
    try {
      return VersionConstraint.parse(manifest.sdkConstraint).allows(_sdkVersion);
    } on FormatException catch (error) {
      _logger.error('plugin ${manifest.id} has an invalid sdkConstraint', error: error);
      return false;
    }
  }

  /// All services bound for [T], in registration order.
  List<T> resolveAll<T>() => _context.resolveAll<T>();

  /// The first service bound for [T], or null.
  T? resolve<T>() => _context.resolve<T>();

  /// Parsers of active plugins.
  List<BookFormatParser> get formatParsers => resolveAll<BookFormatParser>();

  /// Picks the parser that claims [extension] (case-insensitive, with dot).
  BookFormatParser? parserForExtension(String extension) {
    final needle = extension.toLowerCase();
    for (final parser in formatParsers) {
      if (parser.extensions.contains(needle)) return parser;
    }
    return null;
  }

  /// TTS engine of the active plugin that bound one, if any.
  TtsEngine? get ttsEngine => resolve<TtsEngine>();
}

final class _RegistryContext implements PluginContext {
  _RegistryContext(this._logger, this._settings);

  final ModooLogger _logger;
  final Map<String, Object?> _settings;
  final Map<Type, List<Object>> _services = <Type, List<Object>>{};

  @override
  void bind<T>(T service, {Set<Type> types = const <Type>{}}) {
    final keys = types.isEmpty ? <Type>{T} : types;
    _services.putIfAbsent(T, () => <Object>[]);
    for (final key in keys) {
      _services.putIfAbsent(key, () => <Object>[]).add(service as Object);
    }
  }

  @override
  T? resolve<T>() {
    final services = _services[T];
    if (services == null || services.isEmpty) return null;
    return services.first as T;
  }

  List<T> resolveAll<T>() {
    final services = _services[T];
    if (services == null) return const <Never>[];
    return services.cast<T>();
  }

  @override
  void log(String message) => _logger.info(message);

  @override
  Object? readSetting(String key) => _settings[key];
}
