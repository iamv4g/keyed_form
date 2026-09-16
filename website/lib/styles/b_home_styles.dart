import 'package:jaspr/dom.dart';

import 'theme_tokens.dart';

/// Styles specific to the landing page: navbar, hero, the optics raytracer,
/// the invariants/benchmarks/matrix/topology sections, and the code sample
/// tabs.
@css
List<StyleRule> get homeStyles => [
  // Navbar
  css('header').styles(
    position: Position.sticky(top: 0.px),
    zIndex: ZIndex(1000),
    width: 100.percent,
    backdropFilter: Filter.blur(16.px),
    border: Border.only(
      bottom: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
    shadow: BoxShadow(
      offsetX: 0.px,
      offsetY: 4.px,
      blur: 16.px,
      color: Color('rgba(0, 0, 0, 0.08)'),
    ),
    raw: {
      'background': 'color-mix(in srgb, var(--bg) 88%, transparent)',
      '-webkit-backdrop-filter': 'blur(16px)',
    },
  ),

  css('.nav-inner').styles(
    display: Display.flex,
    alignItems: AlignItems.center,
    justifyContent: JustifyContent.spaceBetween,
    height: 64.px,
  ),

  // Only rendered on /docs (Navbar.showDocsMenuToggle) — hidden until the
  // same breakpoint where the nav wraps (responsiveStyles), so it never
  // appears next to a full, unwrapped desktop nav.
  css('.navbar-docs-toggle').styles(display: Display.none),

  css('.brand').styles(
    display: Display.flex,
    alignItems: AlignItems.center,
    gap: Gap(column: 10.px),
    textDecoration: TextDecoration.none,
    color: AppColors.ink,
    fontWeight: FontWeight.w700,
    fontSize: 1.15.rem,
    letterSpacing: (-0.02).em,
  ),

  css('.brand-badge').styles(
    fontSize: 0.7.rem,
    padding: .symmetric(vertical: 2.px, horizontal: 7.px),
    border: Border.all(color: AppColors.borderBright, width: 1.px),
    backgroundColor: AppColors.surfaceElevated,
    color: AppColors.cyan,
    radius: BorderRadius.circular(2.px),
  ),

  css('.nav-links', [
    css('&').styles(
      display: Display.flex,
      alignItems: AlignItems.center,
      gap: Gap(column: 20.px),
      fontSize: 0.85.rem,
    ),
    css('a').styles(
      color: AppColors.inkMuted,
      textDecoration: TextDecoration.none,
      transition: const Transition('color', duration: Duration(milliseconds: 150)),
    ),
    css('a:hover').styles(
      color: AppColors.cyan,
    ),
  ]),

  // Hero Section
  css('.hero').styles(
    position: Position.relative(),
    padding: .only(top: 72.px, bottom: 56.px),
  ),

  css('.telemetry-tag').styles(
    display: Display.inlineFlex,
    alignItems: AlignItems.center,
    gap: Gap(column: 8.px),
    padding: .symmetric(vertical: 4.px, horizontal: 12.px),
    backgroundColor: AppColors.cyanGlow,
    fontSize: 0.75.rem,
    color: AppColors.cyan,
    letterSpacing: 0.08.em,
    textTransform: TextTransform.upperCase,
    margin: .only(bottom: 24.px),
    radius: BorderRadius.circular(2.px),
    raw: {
      'border': '1px solid color-mix(in srgb, var(--cyan) 35%, transparent)',
    },
  ),
  css('.telemetry-tag::before').styles(
    content: '',
    width: 6.px,
    height: 6.px,
    backgroundColor: AppColors.cyan,
    radius: BorderRadius.circular(50.percent),
    raw: {
      'box-shadow': '0 0 8px var(--cyan)',
    },
  ),

  css('.hero h1').styles(
    fontWeight: FontWeight.w700,
    lineHeight: 1.1.em,
    letterSpacing: (-0.03).em,
    fontSize: 3.4.rem,
    maxWidth: 820.px,
  ),
  css('.hero h1 .highlight').styles(
    color: AppColors.cyan,
    position: Position.relative(),
  ),

  css('.hero-tagline').styles(
    margin: .only(top: 20.px),
    fontSize: 1.15.rem,
    lineHeight: 1.6.em,
    maxWidth: 780.px,
    color: AppColors.inkMuted,
  ),

  // Command bar
  css('.cmd-bar').styles(
    display: Display.inlineFlex,
    alignItems: AlignItems.center,
    gap: Gap(column: 12.px),
    backgroundColor: AppColors.surface,
    border: Border.all(color: AppColors.border, width: 1.px),
    padding: .symmetric(vertical: 8.px, horizontal: 14.px),
    margin: .only(top: 28.px),
    radius: BorderRadius.circular(4.px),
  ),
  css('.cmd-bar code').styles(
    color: AppColors.cyan,
    fontSize: 0.88.rem,
  ),

  // Workbench & Raytracer
  css('.workbench').styles(
    margin: .only(top: 48.px),
    padding: .all(24.px),
    radius: BorderRadius.circular(4.px),
  ),
  css('.workbench-header').styles(
    display: Display.flex,
    justifyContent: JustifyContent.spaceBetween,
    alignItems: AlignItems.center,
    margin: .only(bottom: 20.px),
    padding: .only(bottom: 12.px),
    border: Border.only(
      bottom: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
  ),

  css('.workbench-title').styles(
    fontSize: 0.8.rem,
    textTransform: TextTransform.upperCase,
    letterSpacing: 0.1.em,
    color: AppColors.inkMuted,
  ),

  css('.optics-canvas').styles(
    width: 100.percent,
    overflow: Overflow.only(x: Overflow.auto),
  ),
  css('.optics-canvas svg').styles(
    display: Display.block,
    margin: .symmetric(horizontal: .auto),
    width: 100.percent,
    maxWidth: 820.px,
    height: Unit.auto,
  ),
  css('.node-btn').styles(
    cursor: Cursor.pointer,
    transition: const Transition('all', duration: Duration(milliseconds: 200)),
  ),
  css('.node-btn:hover circle, .node-btn.active circle, .node-btn:hover ellipse, .node-btn.active ellipse').styles(
    raw: {
      'stroke': 'var(--cyan)',
      'stroke-width': '3px',
      'filter': 'drop-shadow(0 0 8px var(--cyan))',
    },
  ),

  css('.beam-status').styles(
    margin: .only(top: 16.px),
    padding: .symmetric(vertical: 12.px, horizontal: 16.px),
    fontSize: 0.82.rem,
    display: Display.flex,
    alignItems: AlignItems.center,
    justifyContent: JustifyContent.spaceBetween,
    flexWrap: FlexWrap.wrap,
    gap: Gap(row: 10.px, column: 10.px),
    backgroundColor: AppColors.surfaceElevated,
    border: Border.all(color: AppColors.border, width: 1.px),
  ),

  css('.workbench-subtitle').styles(
    fontSize: 0.76.rem,
    color: AppColors.cyan,
  ),
  css('.beam-label').styles(
    fontSize: 0.82.rem,
    color: AppColors.inkMuted,
  ),
  css('.beam-path').styles(
    color: AppColors.cyan,
    fontWeight: FontWeight.w600,
    margin: .only(left: 8.px),
  ),
  css('.beam-type').styles(
    color: AppColors.amber,
    fontWeight: FontWeight.w600,
    margin: .only(left: 8.px),
  ),
  css('.beam-verified').styles(
    color: AppColors.green,
    fontWeight: FontWeight.w600,
  ),

  // Section (top/bottom padding for every home <section>)
  css('section').styles(
    padding: .only(top: 72.px, bottom: 56.px),
  ),

  // Blueprint Invariants Grid
  css('.blueprint-grid').styles(
    display: Display.grid,
    gap: Gap(row: 20.px, column: 20.px),
    margin: .only(top: 36.px),
    gridTemplate: GridTemplate(
      columns: GridTracks([
        GridTrack.repeat(
          TrackRepeat.autoFit,
          [GridTrack(TrackSize.minmax(TrackSize(330.px), TrackSize.fr(1)))],
        ),
      ]),
    ),
  ),
  css('.grid-card').styles(
    padding: .all(24.px),
    radius: BorderRadius.circular(4.px),
    display: Display.flex,
    flexDirection: FlexDirection.column,
    justifyContent: JustifyContent.spaceBetween,
    backgroundColor: AppColors.surface,
    border: Border.all(color: AppColors.border, width: 1.px),
    transition: const Transition('border-color', duration: Duration(milliseconds: 150)),
  ),
  css('.grid-card:hover').styles(
    border: Border.all(color: AppColors.borderBright, width: 1.px),
  ),

  css('.card-num').styles(
    fontSize: 0.7.rem,
    color: AppColors.cyan,
    fontWeight: FontWeight.w700,
    margin: .only(bottom: 8.px),
    letterSpacing: 0.06.em,
  ),
  css('.card-h').styles(
    fontSize: 1.05.rem,
    fontWeight: FontWeight.w600,
    margin: .only(bottom: 10.px),
    color: AppColors.ink,
  ),

  css('.card-p').styles(
    fontSize: 0.88.rem,
    margin: .only(bottom: 16.px),
    lineHeight: 1.5.em,
    color: AppColors.inkMuted,
  ),

  css('.card-diff').styles(
    padding: .symmetric(vertical: 10.px, horizontal: 14.px),
    fontSize: 0.82.rem,
    backgroundColor: AppColors.surfaceElevated,
    color: AppColors.ink,
    border: Border.only(
      left: BorderSide.solid(color: AppColors.cyan, width: 2.px),
    ),
  ),

  // Benchmark HUD & Charts
  css('.hud-stats').styles(
    display: Display.grid,
    gap: Gap(row: 16.px, column: 16.px),
    margin: .only(top: 32.px),
    gridTemplate: GridTemplate(
      columns: GridTracks([
        GridTrack.repeat(
          TrackRepeat.autoFit,
          [GridTrack(TrackSize.minmax(TrackSize(280.px), TrackSize.fr(1)))],
        ),
      ]),
    ),
  ),
  css('.stat-tile').styles(
    padding: .symmetric(vertical: 22.px, horizontal: 24.px),
    radius: BorderRadius.circular(4.px),
    backgroundColor: AppColors.surface,
    border: Border.all(color: AppColors.border, width: 1.px),
  ),

  css('.stat-big').styles(
    fontSize: 2.5.rem,
    fontWeight: FontWeight.w700,
    color: AppColors.cyan,
    lineHeight: 1.0.em,
  ),
  css('.stat-bad').styles(
    color: AppColors.red,
    fontSize: 1.5.rem,
    margin: .only(left: 6.px),
  ),
  css('.stat-desc').styles(
    margin: .only(top: 10.px),
    fontSize: 0.84.rem,
    lineHeight: 1.45.em,
    color: AppColors.inkMuted,
  ),

  css('.chart-panel').styles(
    margin: .only(top: 28.px),
    radius: BorderRadius.circular(4.px),
    padding: .all(24.px),
    overflow: Overflow.only(x: Overflow.auto),
    backgroundColor: AppColors.surface,
    border: Border.all(color: AppColors.border, width: 1.px),
  ),

  css('.chart-title').styles(
    fontSize: 0.88.rem,
    margin: .only(bottom: 16.px),
    color: AppColors.inkMuted,
  ),
  css('.chart-title b').styles(color: AppColors.ink),

  css('.chart-panel svg').styles(
    display: Display.block,
    maxWidth: 530.px,
    width: 100.percent,
    height: Unit.auto,
    margin: .only(right: .auto),
  ),
  css('.chart-panel text').styles(
    fontFamily: const .list([FontFamily('JetBrains Mono'), FontFamilies.monospace]),
  ),

  // Matrix
  css('table.matrix').styles(
    width: 100.percent,
    minWidth: 720.px,
    margin: .only(top: 24.px),
    border: Border.all(color: AppColors.border, width: 1.px),
    radius: BorderRadius.circular(4.px),
    fontSize: 0.88.rem,
    backgroundColor: AppColors.surface,
    raw: {
      'border-collapse': 'collapse',
      'border-spacing': '0',
    },
  ),
  css('table.matrix th, table.matrix td').styles(
    padding: .symmetric(vertical: 12.px, horizontal: 14.px),
    border: Border.only(
      bottom: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
  ),
  css('table.matrix thead th').styles(
    fontFamily: const .list([FontFamily('JetBrains Mono'), FontFamilies.monospace]),
    fontSize: 0.72.rem,
    letterSpacing: 0.06.em,
    textTransform: TextTransform.upperCase,
    textAlign: TextAlign.center,
    color: AppColors.inkMuted,
    backgroundColor: AppColors.surfaceElevated,
    border: Border.only(
      bottom: BorderSide.solid(color: AppColors.borderBright, width: 1.px),
    ),
  ),
  css('table.matrix thead th:first-child').styles(
    textAlign: TextAlign.left,
  ),
  css('table.matrix thead th.us').styles(
    color: AppColors.cyan,
    fontWeight: FontWeight.w700,
  ),
  css('td.feat').styles(
    fontWeight: FontWeight.w500,
    maxWidth: 320.px,
  ),
  css('table.matrix td:not(.feat)').styles(
    textAlign: TextAlign.center,
    fontSize: 1.05.rem,
  ),
  css('.matrix-legend').styles(
    margin: .only(top: 12.px),
    fontSize: 0.8.rem,
    display: Display.flex,
    gap: Gap(column: 20.px),
    color: AppColors.inkMuted,
  ),

  // Code Container (the landing page's CodeSection tabs)
  css('.code-container').styles(
    margin: .only(top: 36.px),
    radius: BorderRadius.circular(4.px),
    overflow: Overflow.hidden,
    backgroundColor: AppColors.surface,
    border: Border.all(color: AppColors.border, width: 1.px),
  ),

  css('.code-header-bar').styles(
    display: Display.flex,
    alignItems: AlignItems.center,
    justifyContent: JustifyContent.spaceBetween,
    padding: .symmetric(vertical: 4.px, horizontal: 8.px),
    backgroundColor: AppColors.surfaceElevated,
    border: Border.only(
      bottom: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
  ),

  css('.code-tabs').styles(
    display: Display.flex,
    gap: Gap(column: 4.px),
  ),
  css('.tab-btn').styles(
    padding: .symmetric(vertical: 9.px, horizontal: 18.px),
    backgroundColor: Colors.transparent,
    border: Border.unset,
    fontSize: 0.82.rem,
    cursor: Cursor.pointer,
    radius: BorderRadius.circular(3.px),
    transition: const Transition('all', duration: Duration(milliseconds: 150)),
    color: AppColors.inkMuted,
  ),

  css('.tab-btn.active').styles(
    backgroundColor: AppColors.surface,
    color: AppColors.cyan,
    fontWeight: FontWeight.w600,
    shadow: BoxShadow(
      offsetX: 0.px,
      offsetY: 1.px,
      blur: 3.px,
      color: Color('rgba(0, 0, 0, 0.2)'),
    ),
  ),

  css('.code-content').styles(
    padding: .all(24.px),
    overflow: Overflow.only(x: Overflow.auto),
    fontSize: 0.88.rem,
    lineHeight: 1.68.em,
    backgroundColor: AppColors.bg,
  ),

  // Topology Stack
  css('.topology-grid').styles(
    display: Display.grid,
    gap: Gap(row: 12.px, column: 12.px),
    margin: .only(top: 24.px),
    gridTemplate: GridTemplate(
      columns: GridTracks([
        GridTrack.repeat(
          TrackRepeat.autoFit,
          [GridTrack(TrackSize.minmax(TrackSize(260.px), TrackSize.fr(1)))],
        ),
      ]),
    ),
  ),
  css('.topology-card').styles(
    padding: .symmetric(vertical: 16.px, horizontal: 20.px),
    radius: BorderRadius.circular(4.px),
    backgroundColor: AppColors.surface,
    border: Border.all(color: AppColors.border, width: 1.px),
  ),

  css('.topology-card.flutter-layer').styles(
    backgroundColor: AppColors.surfaceElevated,
    border: Border.all(color: AppColors.cyan, width: 1.px),
  ),

  css('.topology-title').styles(
    fontSize: 0.92.rem,
    fontWeight: FontWeight.w600,
    color: AppColors.cyan,
    margin: .only(bottom: 6.px),
  ),
  css('.topology-desc').styles(
    fontSize: 0.82.rem,
    lineHeight: 1.45.em,
    color: AppColors.inkMuted,
  ),
];
