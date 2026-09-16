import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../base_path.dart';
import 'docs/docs_menu_toggle.dart';
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
        a(classes: 'brand display', href: '$siteBasePath/', [
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
          if (showDocsMenuToggle) const DocsMenuToggle(),
          a(href: '$siteBasePath/docs', [.text('Docs')]),
          a(href: '$siteBasePath/playground', [.text('Playground')]),
          a(href: '$siteBasePath/#problems', [.text('Invariants')]),
          a(href: '$siteBasePath/#benchmarks', [.text('Benchmarks')]),
          a(href: '$siteBasePath/#packages', [.text('Architecture')]),
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
