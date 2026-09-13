// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:website/components/code_section.dart' deferred as _code_section;
import 'package:website/components/copy_button.dart' deferred as _copy_button;
import 'package:website/components/optics_raytracer.dart'
    deferred as _optics_raytracer;
import 'package:website/components/theme_toggle.dart' deferred as _theme_toggle;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultClientOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ClientOptions get defaultClientOptions => ClientOptions(
  clients: {
    'code_section': ClientLoader(
      (p) => _code_section.CodeSection(),
      loader: _code_section.loadLibrary,
    ),
    'copy_button': ClientLoader(
      (p) => _copy_button.CopyButton(
        text: p['text'] as String,
        label: p['label'] as String,
        classes: p['classes'] as String,
      ),
      loader: _copy_button.loadLibrary,
    ),
    'optics_raytracer': ClientLoader(
      (p) => _optics_raytracer.OpticsRaytracer(),
      loader: _optics_raytracer.loadLibrary,
    ),
    'theme_toggle': ClientLoader(
      (p) => _theme_toggle.ThemeToggle(),
      loader: _theme_toggle.loadLibrary,
    ),
  },
);
