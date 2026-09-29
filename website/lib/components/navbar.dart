import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../base_path.dart';
import 'brand_mark.dart';
import 'docs/docs_menu_toggle.dart';
import 'icons.dart';
import 'theme_toggle.dart';

class Navbar extends StatelessComponent {
  const Navbar({this.showDocsMenuToggle = false, super.key});

  /// Only DocsPage passes true — the "☰" button that opens the chapter
  /// drawer. Lives in the sticky Navbar (not the sidebar itself) so it
  /// stays reachable while scrolled deep into a chapter.
  final bool showDocsMenuToggle;

  @override
  Component build(BuildContext context) {
    return header([
      div(classes: 'wrap nav-inner', [
        div(classes: 'nav-start', [
          if (showDocsMenuToggle) const DocsMenuToggle(),
          a(classes: 'brand display', href: '$siteBasePath/', [
            const BrandMark(),
            .text(' keyed_form'),
          ]),
        ]),
        nav(classes: 'nav-links mono', [
          a(href: '$siteBasePath/docs', [.text('Docs')]),
          a(classes: 'nav-playground', href: '$siteBasePath/playground', [.text('Playground')]),
          span(classes: 'nav-divider', attributes: {'aria-hidden': 'true'}, []),
          a(
            classes: 'nav-icon',
            href: 'https://pub.dev/packages/keyed_form_flutter',
            target: Target.blank,
            attributes: {'aria-label': 'keyed_form on pub.dev', 'title': 'pub.dev'},
            [SiteIcons.dart()],
          ),
          a(
            classes: 'nav-icon',
            href: 'https://github.com/iamv4g/keyed_form',
            target: Target.blank,
            attributes: {'aria-label': 'keyed_form on GitHub', 'title': 'GitHub'},
            [SiteIcons.github()],
          ),
          const ThemeToggle(),
        ]),
      ]),
    ]);
  }
}
