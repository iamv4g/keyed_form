import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../base_path.dart';
import '../docs_content/docs_nav.dart';
import '../docs_content/search_index.dart';
import 'brand_mark.dart';
import 'docs/docs_menu_toggle.dart';
import 'docs/docs_search.dart';
import 'icons.dart';
import 'theme_toggle.dart';

/// The header for docs and the playground: brand and actions on top, the
/// section links below. [hasSidebar] adds the chapters toggle on narrow screens.
class DocsHeader extends StatelessComponent {
  const DocsHeader({this.section, this.hasSidebar = false, super.key});

  final DocsSection? section;
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
              for (final item in docsSections)
                a(
                  classes: item == section ? 'docs-tab active' : 'docs-tab',
                  href: '$siteBasePath${item.path}',
                  attributes: {if (item == section) 'aria-current': 'location'},
                  [.text(item.label)],
                ),
            ],
          ),
          script(content: '''
            (function () {
              var tabs = document.currentScript.parentElement.querySelector('.docs-tabs');
              var active = tabs && tabs.querySelector('.docs-tab.active');
              if (!active) return;
              var target = tabs.scrollLeft + active.getBoundingClientRect().left -
                tabs.getBoundingClientRect().left -
                (tabs.clientWidth - active.offsetWidth) / 2;
              tabs.scrollLeft = Math.max(0, Math.min(tabs.scrollWidth - tabs.clientWidth, target));
            })();
          '''),
        ]),
        div(classes: 'docs-header-rule', []),
      ]),
    ]);
  }
}

