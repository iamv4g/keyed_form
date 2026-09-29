import 'package:jaspr/dom.dart';

import 'theme_tokens.dart';

/// Mobile/tablet media-query overrides for both the landing page and the
/// docs page. Kept as its own file, bundled after the others, so these
/// overrides still win the cascade.
@css
List<StyleRule> get responsiveStyles => [
  css.media(MediaQuery.screen(maxWidth: 992.px), [
    // The sidebar becomes a drawer at this same breakpoint (below), so it
    // no longer needs a reserved column — one column for the content.
    css('.docs-layout').styles(
      raw: {
        'grid-template-columns': '1fr',
      },
    ),
    css('.docs-toc').styles(
      display: Display.none,
    ),

    // Docs Sidebar Drawer — collapses to a "☰" toggle in the Navbar
    // (DocsMenuToggle); the nav list becomes a fixed drawer that only
    // shows once html.docs-menu-open is set, purely via CSS (the toggle
    // and DocsSidebar are separate hydration islands with no shared
    // Dart state — see docs_menu_toggle.dart).
    css('.docs-sidebar').styles(
      position: Position.static,
      height: Unit.auto,
      overflow: Overflow.visible,
      padding: .only(right: 0.px),
      margin: .only(bottom: 0.px),
    ),
    css('.navbar-docs-toggle').styles(
      display: Display.inlineFlex,
      alignItems: AlignItems.center,
      justifyContent: JustifyContent.center,
      // The ☰ glyph's own ink sits low in its line box in most fonts —
      // asymmetric padding (less above, more below) recenters it visually
      // without changing the button's overall height (top+bottom still 8px).
      padding: .only(top: 2.px, bottom: 6.px, left: 8.px, right: 8.px),
      backgroundColor: AppColors.surface,
      border: Border.all(color: AppColors.border, width: 1.px),
      color: AppColors.ink,
      fontSize: 1.1.rem,
      lineHeight: 1.em,
      radius: BorderRadius.circular(4.px),
    ),
    css('.docs-sidebar-backdrop').styles(
      display: Display.block,
      position: Position.fixed(top: 0.px, left: 0.px, right: 0.px, bottom: 0.px),
      backgroundColor: Color('rgba(0, 0, 0, 0.55)'),
      zIndex: ZIndex(1150),
      raw: {
        'visibility': 'hidden',
        'opacity': '0',
        'transition': 'opacity 0.2s, visibility 0.2s',
      },
    ),
    css('.docs-sidebar-panel').styles(
      position: Position.fixed(top: 0.px, left: 0.px, bottom: 0.px),
      width: 82.percent,
      maxWidth: 320.px,
      height: Unit.expression('100vh'),
      overflow: Overflow.only(y: Overflow.auto),
      backgroundColor: AppColors.bg,
      zIndex: ZIndex(1200),
      padding: .all(20.px),
      border: Border.only(
        right: BorderSide.solid(color: AppColors.border, width: 1.px),
      ),
      transform: Transform.translate(x: (-105).percent),
      transition: const Transition('transform', duration: Duration(milliseconds: 200)),
    ),
    css('html.docs-menu-open .docs-sidebar-backdrop').styles(
      raw: {'visibility': 'visible', 'opacity': '1'},
    ),
    css('html.docs-menu-open .docs-sidebar-panel').styles(
      transform: Transform.translate(x: 0.percent),
    ),
    css('.feature-grid').styles(
      raw: {'grid-template-columns': 'repeat(2, minmax(0, 1fr))'},
    ),

    // Navbar — Docs + three icons fit a 320px phone on one row, so the
    // row never wraps or scrolls. Playground drops out here; the hero links
    // to it instead.
    css('.brand').styles(
      fontSize: 1.05.rem,
    ),
    css('.nav-links').styles(
      gap: Gap(column: 14.px),
    ),
    css('.nav-playground, .nav-divider').styles(
      display: Display.none,
    ),

    // Hero stacks: copy first, demo underneath.
    css('.hero').styles(
      raw: {'grid-template-columns': 'minmax(0, 1fr)'},
    ),

    // Splits stack with the running demo first — it's the hook; the code
    // explaining it follows.
    css('.split').styles(
      raw: {'grid-template-columns': 'minmax(0, 1fr)'},
    ),
    css('.split-demo').styles(position: Position.static, raw: {'order': '-1'}),
    css('.points').styles(
      gridTemplate: GridTemplate(columns: GridTracks([GridTrack(TrackSize.fr(1))])),
    ),
    css('.skill-box').styles(
      padding: .all(22.px),
      raw: {'grid-template-columns': 'minmax(0, 1fr)'},
    ),
  ]),

  css.media(MediaQuery.screen(maxWidth: 768.px), [
    css('html, body').styles(
      overflow: Overflow.only(x: Overflow.clip),
      width: 100.percent,
      maxWidth: 100.percent,
      raw: {
        'overflow-x': 'clip',
      },
    ),
    css('section, [id]').styles(
      raw: {
        'scroll-margin-top': '74px',
      },
    ),
    css('.wrap').styles(
      width: 100.percent,
      maxWidth: 100.percent,
      boxSizing: BoxSizing.borderBox,
      padding: .symmetric(horizontal: 16.px),
    ),
    css('.rule').styles(
      margin: .symmetric(vertical: 44.px, horizontal: .auto),
      maxWidth: 100.percent,
      raw: {
        'width': 'calc(100% - 32px)',
      },
    ),
    css('section').styles(
      padding: .only(top: 32.px, bottom: 38.px),
    ),

    // Hero Mobile
    css('.hero').styles(
      padding: .only(top: 38.px, bottom: 32.px),
    ),
    css('.hero-chips').styles(
      margin: .only(bottom: 16.px),
    ),
    css('.hero h1').styles(
      lineHeight: 1.15.em,
      maxWidth: 100.percent,
      raw: {
        'font-size': 'clamp(1.85rem, 7.5vw, 2.75rem)',
      },
    ),
    css('.hero-tagline').styles(
      fontSize: 0.98.rem,
      lineHeight: 1.55.em,
      margin: .only(top: 14.px),
    ),
    css('.cmd-bar').styles(
      display: Display.flex,
      alignItems: AlignItems.center,
      justifyContent: JustifyContent.spaceBetween,
      width: 100.percent,
      maxWidth: 100.percent,
      boxSizing: BoxSizing.borderBox,
      gap: Gap(column: 8.px),
      padding: .symmetric(vertical: 8.px, horizontal: 10.px),
      margin: .only(top: 20.px),
      overflow: Overflow.only(x: Overflow.hidden),
    ),
    css('.cmd-bar code').styles(
      fontSize: 0.74.rem,
      overflow: Overflow.only(x: Overflow.auto),
      whiteSpace: WhiteSpace.noWrap,
      minWidth: 0.px,
      raw: {
        'flex': '1',
        'min-width': '0',
        '-webkit-overflow-scrolling': 'touch',
        'scrollbar-width': 'none',
      },
    ),
    css('.cmd-bar code::-webkit-scrollbar').styles(
      raw: {'display': 'none'},
    ),
    css('.cmd-bar .copy-btn').styles(
      flex: Flex(shrink: 0),
      padding: .symmetric(vertical: 4.px, horizontal: 8.px),
      fontSize: 0.72.rem,
    ),
    css('.cta-group').styles(
      flexDirection: FlexDirection.column,
      width: 100.percent,
      gap: Gap(row: 10.px),
      margin: .only(top: 20.px),
    ),
    css('.cta-group .btn').styles(
      width: 100.percent,
      justifyContent: JustifyContent.center,
      textAlign: TextAlign.center,
      boxSizing: BoxSizing.borderBox,
      padding: .symmetric(vertical: 12.px, horizontal: 18.px),
      fontSize: 0.88.rem,
    ),

    css('.hero-demo').styles(
      padding: .symmetric(vertical: 18.px, horizontal: 16.px),
    ),

    // Section Mobile
    css('.section-kicker').styles(
      fontSize: 0.7.rem,
    ),
    css('.section-title').styles(
      fontSize: 1.55.rem,
      lineHeight: 1.22.em,
      margin: .only(top: 6.px),
    ),
    css('.section-lede').styles(
      fontSize: 0.92.rem,
      lineHeight: 1.5.em,
      margin: .only(top: 10.px),
    ),

    // Feature grid Mobile — one column of compact cards.
    css('.feature-grid').styles(
      gap: Gap(row: 10.px),
      margin: .only(top: 22.px),
      raw: {'grid-template-columns': 'minmax(0, 1fr)'},
    ),
    css('.feature-card').styles(
      padding: .symmetric(vertical: 16.px, horizontal: 16.px),
      gap: Gap(row: 8.px),
    ),
    css('.feature-body').styles(
      fontSize: 0.85.rem,
    ),

    // Performance Mobile
    css('.perf-grid').styles(
      margin: .only(top: 20.px),
      raw: {'grid-template-columns': 'minmax(0, 1fr)'},
    ),
    css('.stat-tile').styles(
      padding: .symmetric(vertical: 18.px, horizontal: 16.px),
    ),
    css('.stat-big').styles(
      fontSize: 2.2.rem,
    ),

    // Tables Mobile
    css('.table-scroll').styles(
      margin: .only(top: 18.px),
      width: 100.percent,
      maxWidth: 100.percent,
      boxSizing: BoxSizing.borderBox,
      radius: BorderRadius.circular(4.px),
      border: Border.all(color: AppColors.border, width: 1.px),
      raw: {
        '-webkit-overflow-scrolling': 'touch',
      },
    ),
    css('table.spec, table.matrix').styles(
      border: Border.unset,
      margin: .only(top: 0.px),
      fontSize: 0.78.rem,
      raw: {
        'border-collapse': 'collapse',
        'border-spacing': '0',
      },
    ),
    css('table.spec th, table.spec td, table.matrix th, table.matrix td').styles(
      padding: .symmetric(vertical: 8.px, horizontal: 10.px),
      fontSize: 0.78.rem,
    ),
    css('table.spec th, table.spec td').styles(
      whiteSpace: WhiteSpace.noWrap,
    ),
    css('td.feat').styles(
      fontSize: 0.78.rem,
      raw: {
        'max-width': '20ch',
      },
    ),
    css('.matrix-legend').styles(
      flexWrap: FlexWrap.wrap,
      gap: Gap(row: 12.px, column: 12.px),
      fontSize: 0.75.rem,
      margin: .only(top: 10.px),
    ),

    // Topology Grid Mobile
    css('.topology-grid').styles(
      gap: Gap(row: 10.px),
      margin: .only(top: 18.px),
      gridTemplate: GridTemplate(
        columns: GridTracks([GridTrack(TrackSize.fr(1))]),
      ),
    ),
    css('.topology-card').styles(
      padding: .symmetric(vertical: 14.px, horizontal: 16.px),
    ),
    css('.topology-title').styles(
      fontSize: 0.88.rem,
    ),
    css('.topology-desc').styles(
      fontSize: 0.8.rem,
    ),

    // Footer Mobile
    css('footer').styles(
      margin: .only(top: 50.px),
      padding: .only(top: 40.px, bottom: 48.px),
    ),
    // Brand across the top, then the three link columns two-up.
    css('.footer-grid').styles(
      raw: {'grid-template-columns': 'repeat(2, minmax(0, 1fr))'},
    ),
    css('.footer-brand').styles(raw: {'grid-column': '1 / -1'}),
    css('.footer-bottom').styles(
      margin: .only(top: 28.px),
      flexDirection: FlexDirection.column,
      alignItems: AlignItems.start,
      gap: Gap(row: 14.px),
    ),
  ]),
];
