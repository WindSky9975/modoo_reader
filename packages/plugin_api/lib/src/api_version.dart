/// Version of the plugin contract.
///
/// Plugins declare [versionRange] in their manifest; the host refuses to load
/// a plugin whose declared range does not satisfy [version], marking it
/// `incompatible` instead of crashing (DEVELOPMENT_PLAN §3.4.4).
abstract final class ModooPluginApi {
  /// Current contract version, SemVer.
  static const String version = '0.1.0';

  /// The range a plugin built against this API should declare.
  static const String versionRange = '>=0.1.0 <1.0.0';
}
