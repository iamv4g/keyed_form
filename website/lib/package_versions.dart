import 'package:jaspr/jaspr.dart';

/// Package versions, keyed by name — filled in by `main.server.dart`.
/// No `dart:io` here, so client code can import it.
class PackageVersions extends InheritedComponent {
  const PackageVersions({required this.versions, required super.child, super.key});

  final Map<String, String> versions;

  static Map<String, String> of(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<PackageVersions>()?.versions ?? const {};

  @override
  bool updateShouldNotify(PackageVersions oldComponent) => oldComponent.versions != versions;
}
