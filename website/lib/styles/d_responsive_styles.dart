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
    css('.blueprint-grid').styles(
      gridTemplate: GridTemplate(
        columns: GridTracks([
          GridTrack(TrackSize.fr(1)),
          GridTrack(TrackSize.fr(1)),
        ]),
      ),
    ),

    // Navbar — wraps starting here (not 768px): the full link set overlaps
    // the brand/theme-toggle well above phone widths, around 800-900px.
    css('.nav-inner').styles(
      height: Unit.auto,
      minHeight: 56.px,
      flexWrap: FlexWrap.wrap,
      gap: Gap(row: 10.px, column: 10.px),
      padding: .symmetric(vertical: 10.px),
    ),
    css('.brand').styles(
      fontSize: 1.05.rem,
    ),
    css('.nav-links').styles(
      width: 100.percent,
      maxWidth: 100.percent,
      overflow: Overflow.only(x: Overflow.auto),
      gap: Gap(column: 14.px),
      padding: .only(top: 2.px, bottom: 6.px),
      fontSize: 0.8.rem,
      raw: {
        'min-width': '0',
        '-webkit-overflow-scrolling': 'touch',
        'scrollbar-width': 'none',
      },
    ),
    css('.nav-links::-webkit-scrollbar').styles(
      raw: {'display': 'none'},
    ),
    css('.nav-links a, .nav-links .theme-toggle').styles(
      whiteSpace: WhiteSpace.noWrap,
      flex: Flex(shrink: 0),
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
    css('.telemetry-tag').styles(
      fontSize: 0.68.rem,
      padding: .symmetric(vertical: 4.px, horizontal: 10.px),
      letterSpacing: 0.05.em,
      whiteSpace: WhiteSpace.normal,
      lineHeight: 1.4.em,
      margin: .only(bottom: 18.px),
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

    // Optics Workbench Mobile
    css('.workbench').styles(
      margin: .only(top: 32.px),
      padding: .symmetric(vertical: 16.px, horizontal: 12.px),
    ),
    css('.workbench-header').styles(
      flexDirection: FlexDirection.column,
      alignItems: AlignItems.start,
      gap: Gap(row: 6.px),
      margin: .only(bottom: 14.px),
      padding: .only(bottom: 10.px),
    ),
    css('.optics-canvas').styles(
      width: 100.percent,
      maxWidth: 100.percent,
      boxSizing: BoxSizing.borderBox,
      overflow: Overflow.only(x: Overflow.auto),
      padding: .only(bottom: 6.px),
      raw: {
        '-webkit-overflow-scrolling': 'touch',
      },
    ),
    css('.optics-canvas svg').styles(
      minWidth: 640.px,
      width: 100.percent,
      height: Unit.auto,
      display: Display.block,
    ),
    css('.beam-status').styles(
      flexDirection: FlexDirection.column,
      alignItems: AlignItems.start,
      gap: Gap(row: 8.px),
      padding: .symmetric(vertical: 10.px, horizontal: 12.px),
      fontSize: 0.78.rem,
    ),
    css('.beam-status div').styles(
      width: 100.percent,
      raw: {
        'word-break': 'break-all',
      },
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

    // Blueprint Invariants Grid Mobile
    css('.blueprint-grid').styles(
      gap: Gap(row: 14.px),
      margin: .only(top: 22.px),
      gridTemplate: GridTemplate(
        columns: GridTracks([GridTrack(TrackSize.fr(1))]),
      ),
    ),
    css('.grid-card').styles(
      padding: .symmetric(vertical: 18.px, horizontal: 16.px),
    ),
    css('.card-h').styles(
      fontSize: 1.0.rem,
    ),
    css('.card-p').styles(
      fontSize: 0.85.rem,
      margin: .only(bottom: 12.px),
    ),
    css('.card-diff').styles(
      padding: .symmetric(vertical: 8.px, horizontal: 12.px),
      fontSize: 0.8.rem,
    ),

    // HUD Mobile
    css('.hud-stats').styles(
      gap: Gap(row: 12.px),
      margin: .only(top: 20.px),
      gridTemplate: GridTemplate(
        columns: GridTracks([GridTrack(TrackSize.fr(1))]),
      ),
    ),
    css('.stat-tile').styles(
      padding: .symmetric(vertical: 18.px, horizontal: 16.px),
    ),
    css('.stat-big').styles(
      fontSize: 2.2.rem,
    ),
    css('.stat-desc').styles(
      fontSize: 0.82.rem,
    ),

    // Chart Panel Mobile
    css('.chart-panel').styles(
      margin: .only(top: 20.px),
      padding: .symmetric(vertical: 16.px, horizontal: 12.px),
      width: 100.percent,
      maxWidth: 100.percent,
      boxSizing: BoxSizing.borderBox,
      overflow: Overflow.only(x: Overflow.auto),
      raw: {
        '-webkit-overflow-scrolling': 'touch',
      },
    ),
    css('.chart-panel svg').styles(
      minWidth: 480.px,
      width: 100.percent,
      maxWidth: 100.percent,
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

    // Code Container Mobile
    css('.code-container').styles(
      margin: .only(top: 22.px),
    ),
    css('.code-header-bar').styles(
      flexDirection: FlexDirection.column,
      alignItems: AlignItems.stretch,
      gap: Gap(row: 8.px),
      padding: .all(8.px),
    ),
    css('.code-tabs').styles(
      width: 100.percent,
      maxWidth: 100.percent,
      minWidth: 0.px,
      overflow: Overflow.only(x: Overflow.auto),
      whiteSpace: WhiteSpace.noWrap,
      padding: .only(bottom: 4.px),
      raw: {
        'min-width': '0',
        '-webkit-overflow-scrolling': 'touch',
        'scrollbar-width': 'none',
      },
    ),
    css('.code-tabs::-webkit-scrollbar').styles(
      raw: {'display': 'none'},
    ),
    css('.tab-btn').styles(
      padding: .symmetric(vertical: 8.px, horizontal: 12.px),
      fontSize: 0.74.rem,
      whiteSpace: WhiteSpace.noWrap,
      flex: Flex(shrink: 0),
    ),
    css('.code-header-bar .copy-btn').styles(
      alignSelf: AlignSelf.end,
      padding: .symmetric(vertical: 5.px, horizontal: 12.px),
    ),
    css('.code-content').styles(
      padding: .symmetric(vertical: 16.px, horizontal: 14.px),
      fontSize: 0.78.rem,
      lineHeight: 1.55.em,
      overflow: Overflow.only(x: Overflow.auto),
      raw: {
        '-webkit-overflow-scrolling': 'touch',
      },
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
    css('.footer-bottom').styles(
      margin: .only(top: 28.px),
      flexDirection: FlexDirection.column,
      alignItems: AlignItems.start,
      gap: Gap(row: 14.px),
      fontSize: 0.78.rem,
    ),
  ]),
];
