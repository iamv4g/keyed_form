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
      NavLinkItem(title: 'The Three Shapes of FieldRef', href: '#fieldref-shapes'),
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
