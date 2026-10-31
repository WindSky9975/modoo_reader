// Repository task runner. The single entry point behind every `melos run`
// script, CI and tool/check.ps1, so the same commands run locally and on the
// build machine.
//
// Usage: dart run tool/tasks.dart <task> [--scope core,reader]
//
// Always run from the repository root.
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

const int _lineLength = 100;

Future<void> main(List<String> argv) async {
  final task = argv.isEmpty ? 'help' : argv.first;
  final scopes = _scopes(argv.skip(1).toList());
  final root = Directory.current;
  final packages = _workspacePackages(root);

  switch (task) {
    case 'gen':
      await _genBuild(packages);
      await _genL10n(packages);
      await _genRegistry(root);
      // build_runner 与 l10n 的输出不遵守我们的 100 列规则，生成后统一格式化，
      // 否则 CI 里 gen 之后的 format:check 必然失败。
      await _run('dart', ['format', '--line-length', '$_lineLength', '.'], dir: root.path);
    case 'gen:build':
      await _genBuild(packages);
    case 'gen:l10n':
      await _genL10n(packages);
    case 'gen:registry':
      await _genRegistry(root);
    case 'format':
      await _run('dart', ['format', '--line-length', '$_lineLength', '.'], dir: root.path);
    case 'format:check':
      await _run('dart', [
        'format',
        '--line-length',
        '$_lineLength',
        '--output=none',
        '--set-exit-if-changed',
        '.',
      ], dir: root.path);
    case 'analyze':
      await _run('dart', ['analyze', '--fatal-infos', '.'], dir: root.path);
    case 'test':
      await _test(packages, scopes);
    case 'check':
      await _run('dart', [
        'format',
        '--line-length',
        '$_lineLength',
        '--output=none',
        '--set-exit-if-changed',
        '.',
      ], dir: root.path);
      await _run('dart', ['analyze', '--fatal-infos', '.'], dir: root.path);
      await _test(packages, scopes);
    case 'build:apk':
      await _run('flutter', [
        'build',
        'apk',
        '--release',
      ], dir: p.join(root.path, 'apps', 'mobile'));
    case 'help':
    default:
      _usage();
  }
}

void _usage() {
  stdout
    ..writeln('modoo_reader task runner')
    ..writeln()
    ..writeln('  gen            build_runner + gen-l10n + plugin registry')
    ..writeln('  gen:build      build_runner in every package that configures it')
    ..writeln('  gen:l10n       flutter gen-l10n in packages/l10n')
    ..writeln('  gen:registry   regenerate the plugin registry')
    ..writeln('  format         dart format (line length $_lineLength)')
    ..writeln('  format:check   fail if formatting differs')
    ..writeln('  analyze        dart analyze --fatal-infos')
    ..writeln('  test           dart test / flutter test per package')
    ..writeln('  check          format:check + analyze + test')
    ..writeln('  build:apk      debug-signed release APK')
    ..writeln()
    ..writeln('Options:');
  stdout.writeln('  --scope a,b    only test packages whose name contains a or b');
}

List<String> _scopes(List<String> rest) {
  for (var i = 0; i < rest.length; i++) {
    if (rest[i] == '--scope' && i + 1 < rest.length) {
      return rest[i + 1].split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    if (rest[i].startsWith('--scope=')) {
      return rest[i].substring('--scope='.length).split(',').where((s) => s.isNotEmpty).toList();
    }
  }
  return const <String>[];
}

Future<void> _genBuild(List<Package> packages) async {
  final targets = packages.where((pkg) => pkg.pubspecText.contains('build_runner:'));
  if (targets.isEmpty) {
    stdout.writeln('gen:build - no package configures build_runner');
    return;
  }
  for (final pkg in targets) {
    await _run('dart', ['run', 'build_runner', 'build'], dir: pkg.path);
  }
}

Future<void> _genL10n(List<Package> packages) async {
  final matches = packages.where((pkg) => pkg.name == 'modoo_l10n').toList();
  if (matches.isEmpty) {
    stdout.writeln('gen:l10n - no modoo_l10n package, skipped');
    return;
  }
  await _run('flutter', ['gen-l10n'], dir: matches.single.path);
}

Future<void> _genRegistry(Directory root) async {
  await _run('dart', ['run', 'tool/gen_registry.dart'], dir: root.path);
}

Future<void> _test(List<Package> packages, List<String> scopes) async {
  var tested = 0;
  for (final pkg in packages) {
    if (scopes.isNotEmpty && !scopes.any(pkg.name.contains)) {
      continue;
    }
    if (!Directory(p.join(pkg.path, 'test')).existsSync()) {
      continue;
    }
    tested++;
    await _run(pkg.isFlutter ? 'flutter' : 'dart', ['test'], dir: pkg.path);
  }
  if (tested == 0) {
    stderr.writeln('test - no package matched (scopes: ${scopes.join(', ')})');
    exit(1);
  }
  stdout.writeln('test - $tested package(s) passed');
}

Future<void> _run(String executable, List<String> args, {required String dir}) async {
  stdout.writeln(
    '> $executable ${args.join(' ')}   [${p.relative(dir, from: Directory.current.path)}]',
  );
  final process = await Process.start(
    executable,
    args,
    workingDirectory: dir,
    runInShell: Platform.isWindows,
    mode: ProcessStartMode.inheritStdio,
  );
  final code = await process.exitCode;
  if (code != 0) {
    stderr
      ..writeln('FAILED (exit $code): $executable ${args.join(' ')}')
      ..writeln('        in $dir');
    exit(code);
  }
}

/// Packages listed in the root pubspec `workspace:` section.
List<Package> _workspacePackages(Directory root) {
  final rootPubspec = File(p.join(root.path, 'pubspec.yaml'));
  if (!rootPubspec.existsSync()) {
    stderr.writeln('Run this from the repository root (pubspec.yaml not found).');
    exit(1);
  }
  final yaml = loadYaml(rootPubspec.readAsStringSync()) as YamlMap;
  final workspace = (yaml['workspace'] as YamlList?) ?? YamlList();
  final packages = <Package>[];
  for (final entry in workspace) {
    // The root pubspec uses globs (`packages/*`); expand them here so this
    // runner does not have to be edited every time a package is added.
    for (final path in _expand(p.join(root.path, entry.toString()))) {
      final pubspec = File(p.join(path, 'pubspec.yaml'));
      if (!pubspec.existsSync()) {
        stderr.writeln('workspace member without pubspec.yaml: $path');
        exit(1);
      }
      final text = pubspec.readAsStringSync();
      final map = loadYaml(text) as YamlMap;
      packages.add(
        Package(
          name: map['name'].toString(),
          path: path,
          pubspecText: text,
          isFlutter: text.contains('sdk: flutter'),
        ),
      );
    }
  }
  packages.sort((Package a, Package b) => a.name.compareTo(b.name));
  return packages;
}

/// Expands a `dir/*`-style workspace entry into the directories that contain a
/// pubspec. A plain path is returned unchanged.
List<String> _expand(String entry) {
  if (!entry.contains('*')) {
    return <String>[p.normalize(entry)];
  }
  final dir = Directory(p.dirname(entry));
  if (!dir.existsSync()) {
    return const <String>[];
  }
  return dir
      .listSync()
      .whereType<Directory>()
      .where((Directory d) => File(p.join(d.path, 'pubspec.yaml')).existsSync())
      .map((Directory d) => p.normalize(d.path))
      .toList()
    ..sort();
}

final class Package {
  const Package({
    required this.name,
    required this.path,
    required this.pubspecText,
    required this.isFlutter,
  });

  final String name;
  final String path;
  final String pubspecText;
  final bool isFlutter;

  @override
  String toString() => name;
}
