import 'package:jaspr/jaspr.dart';

/// Each workspace package's published version, keyed by package name.
///
/// Read from `packages/*/pubspec.yaml` at build time in `main.server.dart`
/// (which may use `dart:io`; this file must not, so components importing it
/// still compile for the client). The packages version independently, so
/// the site shows a version per package, never one for "keyed_form" as a
/// whole.
class PackageVersions extends InheritedComponent {
  const PackageVersions({required this.versions, required super.child, super.key});

  final Map<String, String> versions;

  /// The versions provided above [context], or an empty map when none are
  /// (e.g. a component test that doesn't set any up).
  static Map<String, String> of(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<PackageVersions>()?.versions ?? const {};

  @override
  bool updateShouldNotify(PackageVersions oldComponent) => oldComponent.versions != versions;
}
