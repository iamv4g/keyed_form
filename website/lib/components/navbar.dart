import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../base_path.dart';
import 'brand_mark.dart';
import 'icons.dart';
import 'theme_toggle.dart';

class Navbar extends StatelessComponent {
  const Navbar({super.key});

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
          a(href: '$siteBasePath/docs/guides', [.text('Docs')]),
          a(classes: 'nav-playground', href: '$siteBasePath/playground', [.text('Playground')]),
          span(classes: 'nav-divider', attributes: {'aria-hidden': 'true'}, []),
          const SiteIconLinks(),
        ]),
      ]),
    ]);
  }
}

/// pub.dev, GitHub and the theme toggle.
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
