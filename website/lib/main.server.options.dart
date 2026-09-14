// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:website/components/code_section.dart' as _code_section;
import 'package:website/components/copy_button.dart' as _copy_button;
import 'package:website/components/optics_raytracer.dart' as _optics_raytracer;
import 'package:website/components/theme_toggle.dart' as _theme_toggle;
import 'package:website/styles/theme.dart' as _theme;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clientId: 'main.client.dart.js',
  clients: {
    _code_section.CodeSection: ClientTarget<_code_section.CodeSection>(
      'code_section',
    ),
    _copy_button.CopyButton: ClientTarget<_copy_button.CopyButton>(
      'copy_button',
      params: __copy_buttonCopyButton,
    ),
    _optics_raytracer.OpticsRaytracer:
        ClientTarget<_optics_raytracer.OpticsRaytracer>('optics_raytracer'),
    _theme_toggle.ThemeToggle: ClientTarget<_theme_toggle.ThemeToggle>(
      'theme_toggle',
    ),
  },
  styles: () => [..._theme.appStyles],
);

Map<String, Object?> __copy_buttonCopyButton(_copy_button.CopyButton c) => {
  'text': c.text,
  'label': c.label,
  'classes': c.classes,
};
