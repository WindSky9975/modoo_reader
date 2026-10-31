/// A unit of functionality compiled into the app and mounted through the
/// generated registry (`buildPluginRegistry()`).
///
/// Plugins are not loadable at runtime, so [register] runs once at startup
/// and must not perform I/O that can fail slowly (DEVELOPMENT_PLAN §3.4.1).
abstract interface class ModooPlugin {
  /// Describes the plugin. Must be a `const` value: it is read before
  /// [register] and shown in settings even when registration fails.
  PluginManifest get manifest;

  /// Binds this plugin's services into [context].
  ///
  /// Throw to signal a broken plugin: the host logs it, marks this plugin
  /// `failed` and keeps the app usable.
  Future<void> register(PluginContext context);
}

/// Immutable description of a plugin.
final class PluginManifest {
  const PluginManifest({
    required this.id,
    required this.name,
    required this.version,
    required this.sdkConstraint,
    this.capabilities = const <Type>{},
    this.settings = const <PluginSetting>[],
  });

  /// Reverse-DNS style, stable forever: `modoo.format.txt`.
  final String id;

  /// English fallback. The host localizes `plugin_<id>_name` from the ARB
  /// files first and only falls back to this string.
  final String name;

  /// Plugin version, SemVer. Independent of the app version.
  final String version;

  /// Range of [ModooPluginApi.version] this plugin supports, e.g. `>=0.1.0 <1.0.0`.
  final String sdkConstraint;

  /// Capability interfaces implemented by this plugin, e.g. `{BookFormatParser}`.
  final Set<Type> capabilities;

  /// Settings rendered by the host. Plugins never build UI.
  final List<PluginSetting> settings;
}

/// What the host exposes to a plugin during registration.
abstract interface class PluginContext {
  /// Registers [service] under each of the capability types in [types].
  void bind<T>(T service, {Set<Type> types});

  /// Returns the service bound for [T], or null when unavailable.
  T? resolve<T>();

  /// Writes to the app log. Never log user content.
  void log(String message);

  /// Raw settings value for [key] as stored by the host, or null.
  Object? readSetting(String key);
}

/// A user-adjustable option declared by a plugin.
///
/// The host renders these from data so that adding a setting never means
/// shipping plugin UI (CODE_STYLE §9.2).
sealed class PluginSetting {
  const PluginSetting({required this.id, required this.label});

  /// Stable within the plugin; used as the settings storage key.
  final String id;

  /// English fallback label; localized via `plugin_<pluginId>_<id>_label`.
  final String label;
}

/// One entry of a [SelectSetting].
final class SelectOption {
  const SelectOption({required this.value, required this.label});

  final String value;
  final String label;
}

/// Pick one value from a fixed list.
final class SelectSetting extends PluginSetting {
  const SelectSetting({
    required super.id,
    required super.label,
    required this.options,
    this.defaultValue,
  });

  final List<SelectOption> options;
  final String? defaultValue;
}

/// On/off switch.
final class BoolSetting extends PluginSetting {
  const BoolSetting({required super.id, required super.label, this.defaultValue = false});

  final bool defaultValue;
}

/// Integer input with bounds.
final class IntSetting extends PluginSetting {
  const IntSetting({
    required super.id,
    required super.label,
    required this.min,
    required this.max,
    this.defaultValue,
  });

  final int min;
  final int max;
  final int? defaultValue;
}

/// Free-form text input.
final class TextSetting extends PluginSetting {
  const TextSetting({
    required super.id,
    required super.label,
    this.defaultValue,
    this.multiline = false,
  });

  final String? defaultValue;
  final bool multiline;
}
