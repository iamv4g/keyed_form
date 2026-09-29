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

  css('.nav-start').styles(
    display: Display.flex,
    alignItems: AlignItems.center,
    gap: Gap(column: 10.px),
  ),

  css('.nav-links', [
    css('&').styles(
      display: Display.flex,
      alignItems: AlignItems.center,
      gap: Gap(column: 18.px),
      fontSize: 0.85.rem,
    ),
    css('a').styles(
      color: AppColors.inkMuted,
      textDecoration: TextDecoration.none,
      whiteSpace: WhiteSpace.noWrap,
      transition: const Transition('color', duration: Duration(milliseconds: 150)),
    ),
    css('a:hover').styles(
      color: AppColors.cyan,
    ),
  ]),

  css('.nav-divider').styles(
    width: 1.px,
    height: 18.px,
    backgroundColor: AppColors.border,
  ),

  // Icon-only links: a square hit area (not just the 18px glyph) so they're
  // comfortable to tap on phones.
  css('.nav-icon').styles(
    display: Display.inlineFlex,
    alignItems: AlignItems.center,
    justifyContent: JustifyContent.center,
    width: 34.px,
    height: 34.px,
    margin: .symmetric(horizontal: (-6).px),
  ),

  // Hero Section
  // Hero: copy on the left, the live login demo on the right.
  css('.hero').styles(
    position: Position.relative(),
    display: Display.grid,
    alignItems: AlignItems.center,
    gap: Gap(column: 48.px, row: 32.px),
    padding: .only(top: 72.px, bottom: 56.px),
    raw: {'grid-template-columns': 'minmax(0, 1.25fr) minmax(0, 1fr)'},
  ),

  css('.hero-chips').styles(
    display: Display.flex,
    flexWrap: FlexWrap.wrap,
    gap: Gap(column: 8.px, row: 8.px),
    margin: .only(bottom: 22.px),
  ),
  css('.chip').styles(
    padding: .symmetric(vertical: 3.px, horizontal: 10.px),
    fontSize: 0.72.rem,
    letterSpacing: 0.04.em,
    color: AppColors.inkMuted,
    border: Border.all(color: AppColors.border, width: 1.px),
    radius: BorderRadius.circular(999.px),
  ),

  css('.hero h1').styles(
    fontWeight: FontWeight.w700,
    lineHeight: 1.1.em,
    letterSpacing: (-0.03).em,
    fontSize: 3.rem,
  ),
  // The payoff beat always starts its own line, so "One" never strands
  // at the end of the first line.
  css('.hero h1 .highlight').styles(
    display: Display.block,
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

  css('.hero-demo').styles(
    padding: .all(24.px),
    radius: BorderRadius.circular(4.px),
  ),
  css('.hero-demo .playground-field:last-of-type').styles(
    margin: .only(bottom: 8.px),
  ),
  css('.hero-demo-footer').styles(
    display: Display.flex,
    flexWrap: FlexWrap.wrap,
    justifyContent: JustifyContent.spaceBetween,
    gap: Gap(column: 12.px, row: 8.px),
    padding: .only(top: 14.px),
    fontSize: 0.74.rem,
    color: AppColors.inkMuted,
    border: Border.only(
      top: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
  ),
  css('.hero-demo-footer a').styles(
    color: AppColors.cyan,
    textDecoration: TextDecoration.none,
  ),

  css('section').styles(
    padding: .only(top: 72.px, bottom: 56.px),
  ),

  // Feature grid: one linked card per capability.
  css('.feature-grid').styles(
    display: Display.grid,
    gap: Gap(row: 16.px, column: 16.px),
    margin: .only(top: 32.px),
    raw: {'grid-template-columns': 'repeat(3, minmax(0, 1fr))'},
  ),
  css('.feature-card').styles(
    display: Display.flex,
    flexDirection: FlexDirection.column,
    gap: Gap(row: 10.px),
    padding: .all(22.px),
    backgroundColor: AppColors.surface,
    border: Border.all(color: AppColors.border, width: 1.px),
    radius: BorderRadius.circular(6.px),
    color: AppColors.ink,
    textDecoration: TextDecoration.none,
    transition: const Transition('border-color', duration: Duration(milliseconds: 150)),
  ),
  css('.feature-card:hover').styles(
    border: Border.all(color: AppColors.cyan, width: 1.px),
  ),
  css('.feature-icon').styles(color: AppColors.cyan),
  css('.feature-title').styles(
    fontSize: 1.05.rem,
    fontWeight: FontWeight.w600,
  ),
  css('.feature-body').styles(
    fontSize: 0.88.rem,
    lineHeight: 1.55.em,
    color: AppColors.inkMuted,
    raw: {'flex': '1'},
  ),
  css('.feature-api').styles(
    display: Display.flex,
    flexWrap: FlexWrap.wrap,
    gap: Gap(column: 6.px, row: 6.px),
  ),
  css('.feature-api code').styles(
    fontSize: 0.72.rem,
    padding: .symmetric(vertical: 2.px, horizontal: 7.px),
    color: AppColors.cyan,
    backgroundColor: AppColors.cyanGlow,
    radius: BorderRadius.circular(3.px),
  ),

  // Closing call to action (landing only).
  css('.closing-cta').styles(
    textAlign: TextAlign.center,
    display: Display.flex,
    flexDirection: FlexDirection.column,
    alignItems: AlignItems.center,
  ),
  css('.closing-cta .section-lede').styles(
    margin: .only(left: .auto, right: .auto),
  ),
  css('.closing-cta .cta-group').styles(justifyContent: JustifyContent.center),

  // Performance: the flat-rebuilds chart beside one latency figure.
  css('.perf-grid').styles(
    display: Display.grid,
    gap: Gap(row: 16.px, column: 16.px),
    margin: .only(top: 32.px),
    raw: {'grid-template-columns': 'minmax(0, 1.5fr) minmax(0, 1fr)'},
  ),
  css('.stat-tile').styles(
    display: Display.flex,
    flexDirection: FlexDirection.column,
    justifyContent: JustifyContent.center,
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
  css('.stat-desc').styles(
    margin: .only(top: 10.px),
    fontSize: 0.9.rem,
    lineHeight: 1.5.em,
    color: AppColors.inkMuted,
  ),
  css('.stat-desc strong').styles(color: AppColors.ink),
  css('.perf-chart').styles(
    display: Display.block,
    width: 100.percent,
    maxWidth: 420.px,
    height: Unit.auto,
  ),
  css('.perf-bar').styles(raw: {'fill': 'var(--cyan)', 'opacity': '0.85'}),
  css('.perf-axis').styles(raw: {'stroke': 'var(--border-bright)', 'stroke-width': '1'}),
  css('.perf-value').styles(
    fontFamily: const .list([FontFamily('JetBrains Mono'), FontFamilies.monospace]),
    raw: {'fill': 'var(--ink)', 'font-size': '15px', 'font-weight': '700'},
  ),
  css('.perf-label').styles(
    fontFamily: const .list([FontFamily('JetBrains Mono'), FontFamilies.monospace]),
    raw: {'fill': 'var(--ink-muted)', 'font-size': '12px'},
  ),

  // Capability matrix (docs benchmarks chapter)
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

  // Split: code on one side, the same code running on the other. Shared
  // by the Model and Dynamic-list sections.
  css('.split').styles(
    display: Display.grid,
    gap: Gap(column: 28.px, row: 20.px),
    alignItems: AlignItems.start,
    margin: .only(top: 32.px),
    raw: {'grid-template-columns': 'minmax(0, 1.15fr) minmax(0, 1fr)'},
  ),
  css('.split-code, .split-demo').styles(minWidth: 0.px),
  // The code column can run much taller than the demo; keep the demo in
  // view while reading down it.
  css('.split-demo').styles(position: Position.sticky(top: 88.px)),

  css('.model-demo').styles(
    display: Display.flex,
    flexDirection: FlexDirection.column,
    gap: Gap(row: 14.px),
  ),
  css('.model-demo-form').styles(
    padding: .all(22.px),
    radius: BorderRadius.circular(4.px),
  ),
  css('.model-demo-actions').styles(
    display: Display.flex,
    flexWrap: FlexWrap.wrap,
    alignItems: AlignItems.center,
    gap: Gap(column: 14.px, row: 10.px),
  ),
  css('.model-demo-actions .btn').styles(cursor: Cursor.pointer),
  css('.model-demo-status').styles(
    fontSize: 0.78.rem,
    color: AppColors.green,
  ),

  // Agent skill band
  css('.skill-box').styles(
    display: Display.grid,
    alignItems: AlignItems.center,
    gap: Gap(column: 36.px, row: 24.px),
    padding: .all(32.px),
    radius: BorderRadius.circular(6.px),
    raw: {'grid-template-columns': 'minmax(0, 1fr) minmax(0, 1.1fr)'},
  ),
  css('.skill-install').styles(minWidth: 0.px),
  css('.skill-note').styles(
    margin: .only(top: 16.px, bottom: 8.px),
    fontSize: 0.76.rem,
    color: AppColors.inkMuted,
  ),

  // A multi-line shell command with its own copy button beside it (not
  // over it — the command scrolls sideways on phones).
  css('.cmd-block').styles(
    display: Display.flex,
    alignItems: AlignItems.start,
    gap: Gap(column: 8.px),
    padding: .all(8.px),
    backgroundColor: AppColors.bg,
    border: Border.all(color: AppColors.border, width: 1.px),
    radius: BorderRadius.circular(4.px),
  ),
  css('.cmd-block pre').styles(
    margin: .zero,
    padding: .symmetric(vertical: 6.px, horizontal: 8.px),
    fontSize: 0.78.rem,
    lineHeight: 1.6.em,
    color: AppColors.cyan,
    overflow: Overflow.only(x: Overflow.auto),
    raw: {'white-space': 'pre', 'flex': '1', 'min-width': '0'},
  ),
  css('.cmd-block .copy-btn').styles(flex: Flex(shrink: 0)),

  // Dynamic-list demo
  css('.pack-demo').styles(
    display: Display.flex,
    flexDirection: FlexDirection.column,
    gap: Gap(row: 14.px),
  ),
  css('.pack-box').styles(
    padding: .all(22.px),
    radius: BorderRadius.circular(4.px),
  ),
  css('.pack-list').styles(
    display: Display.flex,
    flexDirection: FlexDirection.column,
    gap: Gap(row: 8.px),
  ),
  css('.pack-slot').styles(
    position: Position.relative(),
    transition: const Transition('transform', duration: Duration(milliseconds: 150)),
  ),
  // The dragged row follows the pointer 1:1 and floats above its siblings.
  css('.pack-slot.dragging').styles(
    zIndex: ZIndex(2),
    raw: {'transition': 'none'},
  ),
  css('.pack-slot.dragging .pack-row').styles(
    border: Border.all(color: AppColors.cyan, width: 1.px),
    raw: {'box-shadow': 'var(--card-shadow)'},
  ),
  css('.pack-row').styles(
    display: Display.flex,
    alignItems: AlignItems.start,
    gap: Gap(column: 10.px),
    padding: .all(6.px),
    backgroundColor: AppColors.surface,
    border: Border.all(color: Colors.transparent, width: 1.px),
    radius: BorderRadius.circular(4.px),
  ),
  css('.pack-row input[type="checkbox"]').styles(
    margin: .only(top: 12.px),
    raw: {'accent-color': 'var(--cyan)'},
  ),
  css('.pack-field').styles(
    raw: {'flex': '1', 'min-width': '0'},
  ),
  css('.pack-field .playground-field-error').styles(margin: .only(top: 4.px)),
  // Touch drags start on the handle only, so it opts out of scrolling.
  css('.pack-handle').styles(
    display: Display.inlineFlex,
    alignItems: AlignItems.center,
    justifyContent: JustifyContent.center,
    width: 28.px,
    height: 38.px,
    color: AppColors.inkMuted,
    fontSize: 1.1.rem,
    cursor: Cursor.grab,
    raw: {'touch-action': 'none', 'user-select': 'none'},
  ),
  css('.pack-handle:hover').styles(color: AppColors.cyan),
  css('.pack-remove, .pack-add').styles(
    backgroundColor: Colors.transparent,
    color: AppColors.inkMuted,
    cursor: Cursor.pointer,
    border: Border.all(color: AppColors.border, width: 1.px),
    radius: BorderRadius.circular(3.px),
  ),
  css('.pack-remove').styles(
    width: 38.px,
    height: 38.px,
    flex: Flex(shrink: 0),
  ),
  css('.pack-remove:disabled').styles(opacity: 0.35, cursor: Cursor.notAllowed),
  css('.pack-add').styles(
    margin: .only(top: 12.px),
    padding: .symmetric(vertical: 8.px, horizontal: 14.px),
    fontSize: 0.8.rem,
  ),
  css('.pack-remove:hover:not(:disabled), .pack-add:hover').styles(
    color: AppColors.cyan,
    border: Border.all(color: AppColors.cyan, width: 1.px),
  ),
  css('.demo-credit').styles(
    margin: .only(top: 10.px),
    fontSize: 0.74.rem,
    color: AppColors.inkMuted,
  ),
  css('.demo-credit a').styles(color: AppColors.cyan, textDecoration: TextDecoration.none),

  // Three bold-led points under a split, then a docs link.
  css('.points').styles(
    listStyle: ListStyle.none,
    display: Display.grid,
    gap: Gap(column: 28.px, row: 14.px),
    margin: .only(top: 28.px),
    gridTemplate: GridTemplate(
      columns: GridTracks([GridTrack(TrackSize.fr(1)), GridTrack(TrackSize.fr(1)), GridTrack(TrackSize.fr(1))]),
    ),
  ),
  css('.points li').styles(
    fontSize: 0.92.rem,
    lineHeight: 1.6.em,
    color: AppColors.inkMuted,
    padding: .only(left: 14.px),
    border: Border.only(
      left: BorderSide.solid(color: AppColors.cyan, width: 2.px),
    ),
  ),
  css('.points strong').styles(color: AppColors.ink),
  css('.points code').styles(
    fontSize: 0.85.em,
    color: AppColors.ink,
    backgroundColor: AppColors.surfaceElevated,
    padding: .symmetric(horizontal: 5.px, vertical: 1.px),
    radius: BorderRadius.circular(3.px),
  ),
  css('.section-link').styles(
    display: Display.inlineBlock,
    margin: .only(top: 22.px),
    fontSize: 0.85.rem,
    color: AppColors.cyan,
    textDecoration: TextDecoration.none,
  ),
  css('.section-link:hover').styles(raw: {'text-decoration': 'underline'}),

  // Package topology (docs Package Architecture section)
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
    display: Display.block,
    padding: .symmetric(vertical: 16.px, horizontal: 20.px),
    radius: BorderRadius.circular(4.px),
    backgroundColor: AppColors.surface,
    border: Border.all(color: AppColors.border, width: 1.px),
    textDecoration: TextDecoration.none,
    transition: const Transition('border-color', duration: Duration(milliseconds: 150)),
  ),
  css('.topology-card:hover').styles(
    border: Border.all(color: AppColors.cyan, width: 1.px),
  ),
  css('.topology-head').styles(
    display: Display.flex,
    justifyContent: JustifyContent.spaceBetween,
    alignItems: AlignItems.baseline,
    gap: Gap(column: 8.px),
    margin: .only(bottom: 6.px),
  ),
  css('.topology-version').styles(
    fontSize: 0.72.rem,
    padding: .symmetric(vertical: 1.px, horizontal: 6.px),
    color: AppColors.inkMuted,
    border: Border.all(color: AppColors.border, width: 1.px),
    radius: BorderRadius.circular(999.px),
    whiteSpace: WhiteSpace.noWrap,
  ),

  css('.topology-card.flutter-layer').styles(
    backgroundColor: AppColors.surfaceElevated,
    border: Border.all(color: AppColors.cyan, width: 1.px),
  ),

  css('.topology-title').styles(
    fontSize: 0.92.rem,
    fontWeight: FontWeight.w600,
    color: AppColors.cyan,
  ),
  css('.topology-desc').styles(
    fontSize: 0.82.rem,
    lineHeight: 1.45.em,
    color: AppColors.inkMuted,
  ),
];
