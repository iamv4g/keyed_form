import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'theme_toggle.dart';

class Navbar extends StatelessComponent {
  const Navbar({super.key});

  @override
  Component build(BuildContext context) {
    return header([
      div(classes: 'wrap nav-inner', [
        a(classes: 'brand display', href: '#', [
          svg(
            viewBox: '0 0 24 24',
            attributes: {
              'width': '22',
              'height': '22',
              'fill': 'none',
              'stroke': 'var(--cyan)',
              'stroke-width': '2',
            },
            [
              circle(cx: '12', cy: '12', r: '8', []),
              circle(cx: '12', cy: '12', r: '3', attributes: {'fill': 'var(--cyan)'}, []),
              line(x1: '12', y1: '2', x2: '12', y2: '4', []),
              line(x1: '12', y1: '20', x2: '12', y2: '22', []),
              line(x1: '2', y1: '12', x2: '4', y2: '12', []),
              line(x1: '20', y1: '12', x2: '22', y2: '12', []),
            ],
          ),
          .text(' keyed_form'),
        ]),
        div(classes: 'nav-links mono', [
          a(classes: 'nav-docs-btn', href: '/docs', [.text('DOCS')]),
          a(href: '#problems', [.text('Invariants')]),
          a(href: '#benchmarks', [.text('Benchmarks')]),
          a(href: '#packages', [.text('Architecture')]),
          a(
            href: 'https://pub.dev/packages/keyed_form_flutter',
            target: Target.blank,
            [.text('pub.dev ↗')],
          ),
          a(
            href: 'https://github.com/iamv4g/keyed_form',
            target: Target.blank,
            [.text('GitHub ↗')],
          ),
          const ThemeToggle(),
        ]),
      ]),
    ]);
  }
}
