import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../base_path.dart';
import 'brand_mark.dart';
import 'docs/docs_menu_toggle.dart';
import 'icons.dart';
import 'theme_toggle.dart';

class Navbar extends StatelessComponent {
  const Navbar({this.docs = false, super.key});

  /// On docs pages: no "Docs" link, and a "☰" at the end that opens the
  /// chapters drawer. It lives in the sticky navbar so it stays reachable
  /// while scrolled deep into a page.
  final bool docs;

  @override
  Component build(BuildContext context) {
    return header([
      div(classes: 'wrap nav-inner', [
        div(classes: 'nav-start', [
          a(classes: 'brand display', href: '$siteBasePath/', [
            const BrandMark(),
            .text(' keyed_form'),
          ]),
        ]),
        nav(classes: 'nav-links mono', [
          if (!docs) a(href: '$siteBasePath/docs', [.text('Docs')]),
          a(classes: 'nav-playground', href: '$siteBasePath/playground', [.text('Playground')]),
          span(classes: 'nav-divider', attributes: {'aria-hidden': 'true'}, []),
          const SiteIconLinks(),
          if (docs) const DocsMenuToggle(),
        ]),
      ]),
    ]);
  }
}

/// pub.dev, GitHub and the theme toggle — in the navbar, and in the docs
/// drawer's footer on phones.
class SiteIconLinks extends StatelessComponent {
  const SiteIconLinks({super.key});

  @override
  Component build(BuildContext context) {
    return Component.fragment([
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
    ]);
  }
}
