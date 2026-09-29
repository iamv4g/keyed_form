import 'dart:io';

import 'example_sources.dart';

// Server/test only (dart:io). Paths are relative to `website/`, where builds
// and tests run.

/// `name → version` from `../packages/*/pubspec.yaml`.
Map<String, String> readPackageVersions() {
  final packages = Directory('../packages');
  if (!packages.existsSync()) return const {};
  final name = RegExp(r'^name:\s*(\S+)', multiLine: true);
  final version = RegExp(r'^version:\s*(\S+)', multiLine: true);
  final versions = <String, String>{};
  for (final dir in packages.listSync().whereType<Directory>()) {
    final pubspec = File('${dir.path}/pubspec.yaml');
    if (!pubspec.existsSync()) continue;
    final text = pubspec.readAsStringSync();
    final n = name.firstMatch(text)?.group(1);
    final v = version.firstMatch(text)?.group(1);
    if (n != null && v != null) versions[n] = v;
  }
  return versions;
}

/// [ExampleFiles] read from the Flutter example; a missing file throws.
Map<String, String> readExampleSources() => {
  for (final path in ExampleFiles.all) path: File('$exampleLibDir/$path').readAsStringSync().trimRight(),
};

const exampleLibDir = '../packages/keyed_form_flutter/example/lib';
