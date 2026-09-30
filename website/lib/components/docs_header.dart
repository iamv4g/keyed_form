import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../base_path.dart';
import '../docs_content/search_index.dart';
import 'brand_mark.dart';
import 'docs/docs_menu_toggle.dart';
import 'docs/docs_search.dart';
import 'icons.dart';
import 'theme_toggle.dart';

/// A section in the docs header's tab bar. Package docs (schema, flutter, …)
/// join this list when they exist.
const docsSections = [
  (id: 'docs', label: 'Docs', path: '/docs'),
  (id: 'playground', label: 'Playground', path: '/playground'),
];

/// The header for docs and the playground: brand and actions on top, the
/// section tabs below. [hasSidebar] adds the chapters toggle, shown on
/// narrow screens.
class DocsHeader extends StatelessComponent {
  const DocsHeader({required this.section, this.hasSidebar = false, super.key});

  final String section;
  final bool hasSidebar;

  @override
  Component build(BuildContext context) {
    return header(classes: 'docs-header', [
      div(classes: 'docs-shell', [
        div(classes: 'docs-header-top', [
          a(classes: 'brand display', href: '$siteBasePath/', [const BrandMark(), .text(' keyed_form')]),
          div(classes: 'docs-header-actions', [
            DocsSearch(entries: DocsSearchIndex.of(context)),
            a(
              classes: 'header-icon-button',
              href: 'https://github.com/iamv4g/keyed_form',
              target: Target.blank,
              attributes: {'aria-label': 'GitHub', 'title': 'GitHub'},
              [SiteIcons.github()],
            ),
            const ThemeToggle(),
          ]),
        ]),
        div(classes: 'docs-header-tabs', [
          if (hasSidebar) const DocsMenuToggle(),
          nav(
            classes: 'docs-tabs',
            attributes: {'aria-label': 'Documentation sections'},
            [
              for (final s in docsSections)
                a(
                  classes: s.id == section ? 'docs-tab active' : 'docs-tab',
                  href: '$siteBasePath${s.path}',
                  attributes: {if (s.id == section) 'aria-current': 'page'},
                  [.text(s.label)],
                ),
            ],
          ),
        ]),
        div(classes: 'docs-header-rule', []),
      ]),
    ]);
  }
}
