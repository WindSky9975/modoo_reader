/// A semantic version, comparable and parseable from manifest strings.
final class Version implements Comparable<Version> {
  const Version(this.major, this.minor, this.patch);

  factory Version.parse(String input) {
    final match = RegExp(r'^(\d+)\.(\d+)\.(\d+)(?:[-+][0-9A-Za-z.-]+)?$').firstMatch(input.trim());
    if (match == null) {
      throw FormatException('not a semver: $input');
    }
    return Version(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  final int major;
  final int minor;
  final int patch;

  @override
  int compareTo(Version other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  bool operator <(Version other) => compareTo(other) < 0;
  bool operator <=(Version other) => compareTo(other) <= 0;
  bool operator >(Version other) => compareTo(other) > 0;
  bool operator >=(Version other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is Version && major == other.major && minor == other.minor && patch == other.patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}

/// Range syntax used by [PluginManifest.sdkConstraint].
///
/// Supported: `any`, `^1.2.3`, and space-separated comparators
/// (`>=1.0.0 <2.0.0`). Anything else throws [FormatException] so a broken
/// manifest fails loudly in CI rather than silently disabling a plugin.
final class VersionConstraint {
  const VersionConstraint._(this._predicates, this.raw);

  factory VersionConstraint.parse(String input) {
    final text = input.trim();
    if (text.isEmpty || text == 'any' || text == '*') {
      return VersionConstraint._(const <bool Function(Version)>[], text);
    }
    final predicates = <bool Function(Version)>[];
    for (final token in text.split(RegExp(r'\s+'))) {
      if (token.isEmpty) continue;
      final match = RegExp(r'^(>=|<=|>|<|==|\^)?(.+)$').firstMatch(token);
      if (match == null) throw FormatException('bad constraint: $token');
      final operator = match.group(1) ?? '==';
      final version = Version.parse(match.group(2)!);
      predicates.add(switch (operator) {
        '>=' => (v) => v >= version,
        '<=' => (v) => v <= version,
        '>' => (v) => v > version,
        '<' => (v) => v < version,
        '==' => (v) => v == version,
        '^' => (v) => v >= version && v.major == version.major,
        _ => throw FormatException('unsupported operator: $operator'),
      });
    }
    return VersionConstraint._(List<bool Function(Version)>.unmodifiable(predicates), text);
  }

  final List<bool Function(Version)> _predicates;

  /// The original string, kept for error messages and diagnostics.
  final String raw;

  bool allows(Version version) => _predicates.every((predicate) => predicate(version));

  @override
  String toString() => raw;
}
