import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class NavLinkItem {
  const NavLinkItem({
    required this.title,
    required this.href,
    this.badge,
  });

  final String title;
  final String href;
  final String? badge;
}

class NavGroup {
  const NavGroup({
    required this.kicker,
    required this.items,
  });

  final String kicker;
  final List<NavLinkItem> items;
}

const docsNavGroups = <NavGroup>[
  NavGroup(
    kicker: '01 · GETTING STARTED',
    items: [
      NavLinkItem(title: 'Overview & Problem', href: '#overview'),
      NavLinkItem(title: 'Thinking in Keyed Optics', href: '#mental-model', badge: 'REASSURANCE'),
      NavLinkItem(title: 'Quickstart in 5 Min', href: '#quickstart'),
    ],
  ),
  NavGroup(
    kicker: '02 · CORE CONCEPTS',
    items: [
      NavLinkItem(title: 'Package Architecture', href: '#package-architecture'),
      NavLinkItem(title: 'Controller Lifecycle', href: '#controller-lifecycle'),
      NavLinkItem(title: 'Field Handles & Mutations', href: '#field-handles'),
      NavLinkItem(title: 'Cross-Field Relations', href: '#relations'),
      NavLinkItem(title: 'Declarative & Async Validation', href: '#validation'),
    ],
  ),
  NavGroup(
    kicker: '03 · VIRTUALIZATION & LAZY SCROLL',
    items: [
      NavLinkItem(title: 'Virtualization Dilemma', href: '#virtualization', badge: 'KILLER FEATURE'),
      NavLinkItem(title: 'Stable RowId vs Fragile Index', href: '#rowid-vs-index'),
      NavLinkItem(title: 'Virtualized List Example', href: '#lazy-scroll-example'),
      NavLinkItem(title: 'Scroll-to-First-Error (Two-Phase)', href: '#scroll-to-first-error'),
    ],
  ),
  NavGroup(
    kicker: '04 · PRODUCTION RECIPES',
    items: [
      NavLinkItem(title: 'Multi-Step Wizard Form', href: '#recipe-wizard'),
      NavLinkItem(title: 'Backend API Error Mapping', href: '#recipe-backend-errors'),
      NavLinkItem(title: 'Cascading Dropdowns', href: '#recipe-cascading'),
      NavLinkItem(title: 'Custom UI Controls', href: '#recipe-custom-controls'),
    ],
  ),
  NavGroup(
    kicker: '05 · TESTING GUIDE',
    items: [
      NavLinkItem(title: 'Testing Without Widgets (<2ms)', href: '#testing-without-widgets', badge: 'PURE DART'),
    ],
  ),
  NavGroup(
    kicker: '06 · REFERENCE & FAQ',
    items: [
      NavLinkItem(title: 'Complete API Reference', href: '#api-reference'),
      NavLinkItem(title: 'Migration Guide', href: '#migration-guide'),
      NavLinkItem(title: 'Troubleshooting & FAQ', href: '#faq'),
    ],
  ),
  NavGroup(
    kicker: '07 · BENCHMARKS',
    items: [
      NavLinkItem(title: 'Methodology & Full Results', href: '#benchmarks-methodology'),
    ],
  ),
];

@client
class DocsSidebar extends StatefulComponent {
  const DocsSidebar({super.key});

  @override
  State<DocsSidebar> createState() => _DocsSidebarState();
}

class _DocsSidebarState extends State<DocsSidebar> {
  String _query = '';

  @override
  Component build(BuildContext context) {
    final lowerQuery = _query.trim().toLowerCase();

    return aside(classes: 'docs-sidebar', [
      div(classes: 'docs-search-box', [
        input(
          classes: 'docs-search-input mono',
          type: InputType.text,
          value: _query,
          attributes: {
            'placeholder': 'Quick filter docs...',
            'aria-label': 'Filter documentation topics',
          },
          onInput: (val) {
            setState(() {
              _query = val.toString();
            });
          },
        ),
      ]),
      nav(classes: 'docs-sidebar-nav', [
        for (final group in docsNavGroups) ...[
          () {
            final matchingItems = group.items.where((item) {
              if (lowerQuery.isEmpty) return true;
              return item.title.toLowerCase().contains(lowerQuery) ||
                  (item.badge?.toLowerCase().contains(lowerQuery) ?? false) ||
                  group.kicker.toLowerCase().contains(lowerQuery);
            }).toList();

            if (matchingItems.isEmpty) return const Component.empty();

            return div(classes: 'docs-nav-group', [
              div(classes: 'docs-nav-group-title mono', [.text(group.kicker)]),
              ul(classes: 'docs-nav-list', [
                for (final item in matchingItems)
                  li(classes: 'docs-nav-item', [
                    a(classes: 'docs-nav-link', href: '/docs${item.href}', [
                      span(classes: 'nav-title', [.text(item.title)]),
                      if (item.badge case final badge?) span(classes: 'nav-badge mono', [.text(badge)]),
                    ]),
                  ]),
              ]),
            ]);
          }(),
        ],
      ]),
    ]);
  }
}
