import 'package:jaspr/jaspr.dart';

/// Files under `packages/keyed_form_flutter/example/lib/` that the landing
/// page shows verbatim.
abstract final class ExampleFiles {
  static const loginSchema = 'login/login_schema.dart';
  static const loginForm = 'login/login_form.dart';
  static const loginTextField = 'login/login_text_field.dart';

  static const packingSchema = 'packing_list/packing_schema.dart';
  static const packingList = 'packing_list/packing_list.dart';
  static const packingRow = 'packing_list/packing_row.dart';

  static const packing = [packingSchema, packingList, packingRow];

  static const login = [loginSchema, loginForm, loginTextField];

  static const all = [...login, ...packing];
}

/// Contents of [ExampleFiles], read by `main.server.dart` at build time.
/// No `dart:io` here, so client code can import it.
class ExampleSources extends InheritedComponent {
  const ExampleSources({required this.files, required super.child, super.key});

  final Map<String, String> files;

  static String of(BuildContext context, String path) {
    final files = context.dependOnInheritedComponentOfExactType<ExampleSources>()?.files ?? const {};
    final source = files[path];
    if (source == null) throw StateError('Example source not loaded: $path');
    return source;
  }

  @override
  bool updateShouldNotify(ExampleSources oldComponent) => oldComponent.files != files;
}
