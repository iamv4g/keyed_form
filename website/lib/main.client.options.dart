// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:website/components/demo/hero_login_demo.dart'
    deferred as _hero_login_demo;
import 'package:website/components/demo/model_login_demo.dart'
    deferred as _model_login_demo;
import 'package:website/components/demo/packing_demo.dart'
    deferred as _packing_demo;
import 'package:website/components/docs/docs_menu_toggle.dart'
    deferred as _docs_menu_toggle;
import 'package:website/components/docs/docs_sidebar.dart'
    deferred as _docs_sidebar;
import 'package:website/components/docs/docs_toc.dart' deferred as _docs_toc;
import 'package:website/components/playground/playground_demo.dart'
    deferred as _playground_demo;
import 'package:website/components/copy_button.dart' deferred as _copy_button;
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
    'copy_button': ClientLoader(
      (p) => _copy_button.CopyButton(
        text: p['text'] as String,
        label: p['label'] as String,
        classes: p['classes'] as String,
      ),
      loader: _copy_button.loadLibrary,
    ),
    'hero_login_demo': ClientLoader(
      (p) => _hero_login_demo.HeroLoginDemo(),
      loader: _hero_login_demo.loadLibrary,
    ),
    'model_login_demo': ClientLoader(
      (p) => _model_login_demo.ModelLoginDemo(),
      loader: _model_login_demo.loadLibrary,
    ),
    'packing_demo': ClientLoader(
      (p) => _packing_demo.PackingDemo(),
      loader: _packing_demo.loadLibrary,
    ),
    'docs_menu_toggle': ClientLoader(
      (p) => _docs_menu_toggle.DocsMenuToggle(),
      loader: _docs_menu_toggle.loadLibrary,
    ),
    'docs_sidebar': ClientLoader(
      (p) => _docs_sidebar.DocsSidebar(),
      loader: _docs_sidebar.loadLibrary,
    ),
    'docs_toc': ClientLoader(
      (p) => _docs_toc.DocsToc(),
      loader: _docs_toc.loadLibrary,
    ),
    'playground_demo': ClientLoader(
      (p) => _playground_demo.PlaygroundDemo(),
      loader: _playground_demo.loadLibrary,
    ),
    'theme_toggle': ClientLoader(
      (p) => _theme_toggle.ThemeToggle(),
      loader: _theme_toggle.loadLibrary,
    ),
  },
);
