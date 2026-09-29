// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:website/components/demo/hero_login_demo.dart'
    as _hero_login_demo;
import 'package:website/components/demo/model_login_demo.dart'
    as _model_login_demo;
import 'package:website/components/demo/packing_demo.dart' as _packing_demo;
import 'package:website/components/docs/docs_menu_backdrop.dart'
    as _docs_menu_backdrop;
import 'package:website/components/docs/docs_menu_toggle.dart'
    as _docs_menu_toggle;
import 'package:website/components/docs/docs_search.dart' as _docs_search;
import 'package:website/components/playground/playground_demo.dart'
    as _playground_demo;
import 'package:website/components/copy_button.dart' as _copy_button;
import 'package:website/components/theme_toggle.dart' as _theme_toggle;
import 'package:website/styles/a_shared_styles.dart' as _a_shared_styles;
import 'package:website/styles/b_home_styles.dart' as _b_home_styles;
import 'package:website/styles/d_responsive_styles.dart'
    as _d_responsive_styles;
import 'package:website/styles/e_playground_styles.dart'
    as _e_playground_styles;
import 'package:website/styles/f_code_styles.dart' as _f_code_styles;
import 'package:website/styles/g_markdown_styles.dart' as _g_markdown_styles;
import 'package:website/styles/h_docs_header_styles.dart'
    as _h_docs_header_styles;

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
    _copy_button.CopyButton: ClientTarget<_copy_button.CopyButton>(
      'copy_button',
      params: __copy_buttonCopyButton,
    ),
    _hero_login_demo.HeroLoginDemo:
        ClientTarget<_hero_login_demo.HeroLoginDemo>('hero_login_demo'),
    _model_login_demo.ModelLoginDemo:
        ClientTarget<_model_login_demo.ModelLoginDemo>('model_login_demo'),
    _packing_demo.PackingDemo: ClientTarget<_packing_demo.PackingDemo>(
      'packing_demo',
    ),
    _docs_menu_backdrop.DocsMenuBackdrop:
        ClientTarget<_docs_menu_backdrop.DocsMenuBackdrop>(
          'docs_menu_backdrop',
        ),
    _docs_menu_toggle.DocsMenuToggle:
        ClientTarget<_docs_menu_toggle.DocsMenuToggle>('docs_menu_toggle'),
    _docs_search.DocsSearch: ClientTarget<_docs_search.DocsSearch>(
      'docs_search',
      params: __docs_searchDocsSearch,
    ),
    _playground_demo.PlaygroundDemo:
        ClientTarget<_playground_demo.PlaygroundDemo>('playground_demo'),
    _theme_toggle.ThemeToggle: ClientTarget<_theme_toggle.ThemeToggle>(
      'theme_toggle',
    ),
  },
  styles: () => [
    ..._a_shared_styles.sharedStyles,
    ..._b_home_styles.homeStyles,
    ..._d_responsive_styles.responsiveStyles,
    ..._e_playground_styles.playgroundStyles,
    ..._f_code_styles.codeStyles,
    ..._g_markdown_styles.markdownStyles,
    ..._h_docs_header_styles.docsHeaderStyles,
  ],
);

Map<String, Object?> __copy_buttonCopyButton(_copy_button.CopyButton c) => {
  'text': c.text,
  'label': c.label,
  'classes': c.classes,
};
Map<String, Object?> __docs_searchDocsSearch(_docs_search.DocsSearch c) => {
  'entries': c.entries,
};
