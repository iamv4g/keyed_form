import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../theme_toggle.dart';

class DocsNavbar extends StatelessComponent {
  const DocsNavbar({super.key});

  @override
  Component build(BuildContext context) {
    return header(classes: 'docs-header', [
      div(classes: 'docs-nav-inner', [
        div(classes: 'docs-nav-left', [
          a(
            classes: 'brand display',
            href: '/',
            attributes: {'aria-label': 'Return to keyed_form home'},
            [
              svg(
                viewBox: '0 0 24 24',
                width: 24.px,
                height: 24.px,
                attributes: {'fill': 'none', 'stroke': 'currentColor', 'stroke-width': '2'},
                [
                  circle(cx: '12', cy: '12', r: '8', []),
                  circle(
                    cx: '12',
                    cy: '12',
                    r: '3',
                    attributes: {'fill': 'currentColor'},
                    [],
                  ),
                  line(x1: '12', y1: '2', x2: '12', y2: '4', []),
                  line(x1: '12', y1: '20', x2: '12', y2: '22', []),
                  line(x1: '2', y1: '12', x2: '4', y2: '12', []),
                  line(x1: '20', y1: '12', x2: '22', y2: '12', []),
                ],
              ),
              span([.text('keyed_form')]),
            ],
          ),
          div(classes: 'docs-nav-links', [
            a(href: '/', [.text('← Home')]),
          ]),
        ]),
        div(classes: 'docs-nav-right', [
          div(classes: 'docs-nav-links', [
            a(
              href: 'https://pub.dev/packages/keyed_form',
              target: Target.blank,
              attributes: {'rel': 'noopener noreferrer'},
              [.text('pub.dev ↗')],
            ),
            a(
              href: 'https://github.com/iamv4g/keyed_form',
              target: Target.blank,
              attributes: {'rel': 'noopener noreferrer'},
              [.text('GitHub ↗')],
            ),
          ]),
          const ThemeToggle(),
        ]),
      ]),
    ]);
  }
}
