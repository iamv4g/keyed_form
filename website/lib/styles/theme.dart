import 'package:jaspr/dom.dart';

abstract final class AppColors {
  // Brand & Accents
  static const cyan = Color('#00f0ff');
  static const cyanGlow = Color('rgba(0, 240, 255, 0.16)');
  static const amber = Color('#ffb020');
  static const amberGlow = Color('rgba(255, 176, 32, 0.16)');
  static const green = Color('#00e599');
  static const red = Color('#ff4d4d');

  // Dark Palette
  static const bgDark = Color('#070b0e');
  static const surfaceDark = Color('#0e141b');
  static const surfaceElevatedDark = Color('#141d26');
  static const borderDark = Color('#1f2c38');
  static const borderBrightDark = Color('#304456');
  static const inkDark = Color('#eaf2f8');
  static const inkMutedDark = Color('#8397a7');

  // Light Palette
  static const bgLight = Color('#f4f7f9');
  static const surfaceLight = Color('#ffffff');
  static const surfaceElevatedLight = Color('#eaf0f4');
  static const borderLight = Color('#d3dfe8');
  static const borderBrightLight = Color('#a8bfcf');
  static const inkLight = Color('#0b1924');
  static const inkMutedLight = Color('#4b6375');
}

@css
List<StyleRule> get appStyles => [
  // Reset & Base
  css('*').styles(
    boxSizing: BoxSizing.borderBox,
    margin: .zero,
    padding: .zero,
  ),

  css('body').styles(
    overflow: Overflow.only(x: Overflow.clip),
    fontFamily: const .list([FontFamily('Inter'), FontFamilies.sansSerif]),
    fontSize: 15.px,
    lineHeight: 1.6.em,
    transition: const Transition('background', duration: Duration(milliseconds: 200)),
  ),

  // Theme Coloring (Dark / Light)
  css('[data-theme="dark"] body').styles(
    backgroundColor: AppColors.bgDark,
    color: AppColors.inkDark,
  ),
  css('[data-theme="light"] body').styles(
    backgroundColor: AppColors.bgLight,
    color: AppColors.inkLight,
  ),

  // Typography helpers
  css('.mono').styles(
    fontFamily: const .list([FontFamily('JetBrains Mono'), FontFamilies.monospace]),
  ),
  css('.display').styles(
    fontFamily: const .list([FontFamily('Space Grotesk'), FontFamilies.sansSerif]),
  ),
  css('code, pre').styles(
    fontFamily: const .list([FontFamily('JetBrains Mono'), FontFamilies.monospace]),
  ),

  // Blueprint Corner Accents
  css('.blueprint-box', [
    css('&').styles(
      position: Position.relative(),
    ),
    css('&::before, &::after').styles(
      content: '""',
      position: Position.absolute(),
      width: 6.px,
      height: 6.px,
      pointerEvents: PointerEvents.none,
    ),
    css('&::before').styles(
      position: Position.absolute(top: (-1).px, left: (-1).px),
      border: Border.only(
        top: BorderSide.solid(color: AppColors.cyan, width: 2.px),
        left: BorderSide.solid(color: AppColors.cyan, width: 2.px),
      ),
    ),
    css('&::after').styles(
      position: Position.absolute(bottom: (-1).px, right: (-1).px),
      border: Border.only(
        bottom: BorderSide.solid(color: AppColors.cyan, width: 2.px),
        right: BorderSide.solid(color: AppColors.cyan, width: 2.px),
      ),
    ),
  ]),

  css('[data-theme="dark"] .blueprint-box').styles(
    backgroundColor: AppColors.surfaceDark,
    border: Border.all(color: AppColors.borderDark, width: 1.px),
  ),
  css('[data-theme="light"] .blueprint-box').styles(
    backgroundColor: AppColors.surfaceLight,
    border: Border.all(color: AppColors.borderLight, width: 1.px),
  ),

  // Layout Container & Divider
  css('.wrap').styles(
    maxWidth: 1140.px,
    margin: .symmetric(horizontal: .auto),
    padding: .symmetric(horizontal: 24.px),
  ),

  css('.rule').styles(
    border: Border.unset,
    height: 1.px,
    maxWidth: 1140.px,
    margin: .symmetric(vertical: 80.px, horizontal: .auto),
    display: Display.block,
  ),
  css('[data-theme="dark"] .rule').styles(
    backgroundColor: AppColors.borderDark,
  ),
  css('[data-theme="light"] .rule').styles(
    backgroundColor: AppColors.borderLight,
  ),

  // Navbar
  css('header').styles(
    position: Position.sticky(top: 0.px),
    zIndex: ZIndex(1000),
    width: 100.percent,
    backdropFilter: Filter.blur(16.px),
    shadow: BoxShadow(
      offsetX: 0.px,
      offsetY: 4.px,
      blur: 16.px,
      color: Color('rgba(0, 0, 0, 0.08)'),
    ),
  ),
  css('[data-theme="dark"] header').styles(
    backgroundColor: Color('rgba(7, 11, 14, 0.88)'),
    border: Border.only(bottom: BorderSide.solid(color: AppColors.borderDark, width: 1.px)),
  ),
  css('[data-theme="light"] header').styles(
    backgroundColor: Color('rgba(244, 247, 249, 0.88)'),
    border: Border.only(bottom: BorderSide.solid(color: AppColors.borderLight, width: 1.px)),
  ),

  css('.nav-inner').styles(
    display: Display.flex,
    alignItems: AlignItems.center,
    justifyContent: JustifyContent.spaceBetween,
    height: 64.px,
  ),

  css('.brand').styles(
    display: Display.flex,
    alignItems: AlignItems.center,
    gap: Gap(column: 10.px),
    textDecoration: TextDecoration.none,
    fontWeight: FontWeight.w700,
    fontSize: 1.15.rem,
    letterSpacing: (-0.02).em,
  ),
  css('[data-theme="dark"] .brand').styles(color: AppColors.inkDark),
  css('[data-theme="light"] .brand').styles(color: AppColors.inkLight),

  css('.brand-badge').styles(
    fontSize: 0.7.rem,
    padding: .symmetric(vertical: 2.px, horizontal: 7.px),
    color: AppColors.cyan,
    radius: BorderRadius.circular(2.px),
  ),
  css('[data-theme="dark"] .brand-badge').styles(
    backgroundColor: AppColors.surfaceElevatedDark,
    border: Border.all(color: AppColors.borderBrightDark, width: 1.px),
  ),
  css('[data-theme="light"] .brand-badge').styles(
    backgroundColor: AppColors.surfaceElevatedLight,
    border: Border.all(color: AppColors.borderBrightLight, width: 1.px),
  ),

  css('.nav-links', [
    css('&').styles(
      display: Display.flex,
      alignItems: AlignItems.center,
      gap: Gap(column: 20.px),
      fontSize: 0.85.rem,
    ),
    css('a').styles(
      textDecoration: TextDecoration.none,
      transition: const Transition('color', duration: Duration(milliseconds: 150)),
    ),
    css('a:hover').styles(
      color: AppColors.cyan,
    ),
  ]),
  css('[data-theme="dark"] .nav-links a').styles(color: AppColors.inkMutedDark),
  css('[data-theme="light"] .nav-links a').styles(color: AppColors.inkMutedLight),

  css('.theme-toggle').styles(
    padding: .symmetric(vertical: 6.px, horizontal: 12.px),
    radius: BorderRadius.circular(4.px),
    cursor: Cursor.pointer,
    fontSize: 0.78.rem,
    display: Display.flex,
    alignItems: AlignItems.center,
    gap: Gap(column: 6.px),
    transition: const Transition('all', duration: Duration(milliseconds: 150)),
  ),
  css('[data-theme="dark"] .theme-toggle').styles(
    backgroundColor: AppColors.surfaceElevatedDark,
    border: Border.all(color: AppColors.borderDark, width: 1.px),
    color: AppColors.inkDark,
  ),
  css('[data-theme="light"] .theme-toggle').styles(
    backgroundColor: AppColors.surfaceElevatedLight,
    border: Border.all(color: AppColors.borderLight, width: 1.px),
    color: AppColors.inkLight,
  ),
  css('.theme-toggle:hover').styles(
    color: AppColors.cyan,
    border: Border.all(color: AppColors.cyan, width: 1.px),
  ),

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
    border: Border.all(color: Color('rgba(0, 240, 255, 0.35)'), width: 1.px),
  ),
  css('.telemetry-tag::before').styles(
    content: '""',
    width: 6.px,
    height: 6.px,
    backgroundColor: AppColors.cyan,
    radius: BorderRadius.circular(50.percent),
    shadow: BoxShadow(
      offsetX: 0.px,
      offsetY: 0.px,
      blur: 8.px,
      color: AppColors.cyan,
    ),
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
  ),
  css('[data-theme="dark"] .hero-tagline').styles(color: AppColors.inkMutedDark),
  css('[data-theme="light"] .hero-tagline').styles(color: AppColors.inkMutedLight),

  // Command bar
  css('.cmd-bar').styles(
    display: Display.inlineFlex,
    alignItems: AlignItems.center,
    gap: Gap(column: 12.px),
    padding: .symmetric(vertical: 8.px, horizontal: 14.px),
    margin: .only(top: 28.px),
    radius: BorderRadius.circular(4.px),
  ),
  css('[data-theme="dark"] .cmd-bar').styles(
    backgroundColor: AppColors.surfaceDark,
    border: Border.all(color: AppColors.borderDark, width: 1.px),
  ),
  css('[data-theme="light"] .cmd-bar').styles(
    backgroundColor: AppColors.surfaceLight,
    border: Border.all(color: AppColors.borderLight, width: 1.px),
  ),
  css('.cmd-bar code').styles(
    color: AppColors.cyan,
    fontSize: 0.88.rem,
  ),

  css('.copy-btn').styles(
    padding: .symmetric(vertical: 5.px, horizontal: 10.px),
    fontSize: 0.75.rem,
    cursor: Cursor.pointer,
    radius: BorderRadius.circular(2.px),
    transition: const Transition('all', duration: Duration(milliseconds: 150)),
  ),
  css('[data-theme="dark"] .copy-btn').styles(
    backgroundColor: AppColors.surfaceElevatedDark,
    border: Border.all(color: AppColors.borderDark, width: 1.px),
    color: AppColors.inkMutedDark,
  ),
  css('[data-theme="light"] .copy-btn').styles(
    backgroundColor: AppColors.surfaceElevatedLight,
    border: Border.all(color: AppColors.borderLight, width: 1.px),
    color: AppColors.inkMutedLight,
  ),
  css('.copy-btn:hover').styles(
    border: Border.all(color: AppColors.cyan, width: 1.px),
  ),
  css('[data-theme="dark"] .copy-btn:hover').styles(color: AppColors.inkDark),
  css('[data-theme="light"] .copy-btn:hover').styles(color: AppColors.inkLight),

  // CTA Buttons
  css('.cta-group').styles(
    display: Display.flex,
    flexWrap: FlexWrap.wrap,
    gap: Gap(column: 12.px, row: 12.px),
    margin: .only(top: 24.px),
  ),

  css('.btn').styles(
    padding: .symmetric(vertical: 11.px, horizontal: 22.px),
    fontSize: 0.85.rem,
    fontWeight: FontWeight.w600,
    textDecoration: TextDecoration.none,
    radius: BorderRadius.circular(3.px),
    display: Display.inlineFlex,
    alignItems: AlignItems.center,
    gap: Gap(column: 8.px),
    transition: const Transition('all', duration: Duration(milliseconds: 150)),
  ),
  css('.btn-cyan').styles(
    backgroundColor: AppColors.cyan,
    color: Color('#041419'),
    border: Border.all(color: AppColors.cyan, width: 1.px),
  ),
  css('.btn-cyan:hover').styles(
    shadow: BoxShadow(
      offsetX: 0.px,
      offsetY: 0.px,
      blur: 16.px,
      color: AppColors.cyanGlow,
    ),
  ),
  css('.btn-outline').styles(
    textDecoration: TextDecoration.none,
  ),
  css('[data-theme="dark"] .btn-outline').styles(
    backgroundColor: AppColors.surfaceDark,
    color: AppColors.inkDark,
    border: Border.all(color: AppColors.borderBrightDark, width: 1.px),
  ),
  css('[data-theme="light"] .btn-outline').styles(
    backgroundColor: AppColors.surfaceLight,
    color: AppColors.inkLight,
    border: Border.all(color: AppColors.borderBrightLight, width: 1.px),
  ),
  css('.btn-outline:hover').styles(
    color: AppColors.cyan,
    border: Border.all(color: AppColors.cyan, width: 1.px),
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
  ),
  css('[data-theme="dark"] .workbench-header').styles(
    border: Border.only(bottom: BorderSide.solid(color: AppColors.borderDark, width: 1.px)),
  ),
  css('[data-theme="light"] .workbench-header').styles(
    border: Border.only(bottom: BorderSide.solid(color: AppColors.borderLight, width: 1.px)),
  ),

  css('.workbench-title').styles(
    fontSize: 0.8.rem,
    textTransform: TextTransform.upperCase,
    letterSpacing: 0.1.em,
  ),
  css('[data-theme="dark"] .workbench-title').styles(color: AppColors.inkMutedDark),
  css('[data-theme="light"] .workbench-title').styles(color: AppColors.inkMutedLight),

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

  css('.beam-status').styles(
    margin: .only(top: 16.px),
    padding: .symmetric(vertical: 12.px, horizontal: 16.px),
    fontSize: 0.82.rem,
    display: Display.flex,
    alignItems: AlignItems.center,
    justifyContent: JustifyContent.spaceBetween,
    flexWrap: FlexWrap.wrap,
    gap: Gap(row: 10.px, column: 10.px),
  ),
  css('[data-theme="dark"] .beam-status').styles(
    backgroundColor: AppColors.surfaceElevatedDark,
    border: Border.all(color: AppColors.borderDark, width: 1.px),
  ),
  css('[data-theme="light"] .beam-status').styles(
    backgroundColor: AppColors.surfaceElevatedLight,
    border: Border.all(color: AppColors.borderLight, width: 1.px),
  ),

  // Section Headings
  css('section').styles(
    padding: .only(top: 72.px, bottom: 56.px),
  ),
  css('.section-kicker').styles(
    fontSize: 0.74.rem,
    letterSpacing: 0.12.em,
    textTransform: TextTransform.upperCase,
    color: AppColors.cyan,
    fontWeight: FontWeight.w600,
    display: Display.block,
  ),
  css('.section-title').styles(
    fontSize: 2.1.rem,
    fontWeight: FontWeight.w700,
    letterSpacing: (-0.02).em,
    margin: .only(top: 8.px),
  ),
  css('.section-lede').styles(
    margin: .only(top: 12.px),
    fontSize: 1.02.rem,
    maxWidth: 780.px,
  ),
  css('[data-theme="dark"] .section-lede').styles(color: AppColors.inkMutedDark),
  css('[data-theme="light"] .section-lede').styles(color: AppColors.inkMutedLight),

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
    transition: const Transition('border-color', duration: Duration(milliseconds: 150)),
  ),
  css('[data-theme="dark"] .grid-card').styles(
    backgroundColor: AppColors.surfaceDark,
    border: Border.all(color: AppColors.borderDark, width: 1.px),
  ),
  css('[data-theme="light"] .grid-card').styles(
    backgroundColor: AppColors.surfaceLight,
    border: Border.all(color: AppColors.borderLight, width: 1.px),
  ),
  css('[data-theme="dark"] .grid-card:hover').styles(
    border: Border.all(color: AppColors.borderBrightDark, width: 1.px),
  ),
  css('[data-theme="light"] .grid-card:hover').styles(
    border: Border.all(color: AppColors.borderBrightLight, width: 1.px),
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
  ),
  css('[data-theme="dark"] .card-h').styles(color: AppColors.inkDark),
  css('[data-theme="light"] .card-h').styles(color: AppColors.inkLight),

  css('.card-p').styles(
    fontSize: 0.88.rem,
    margin: .only(bottom: 16.px),
    lineHeight: 1.5.em,
  ),
  css('[data-theme="dark"] .card-p').styles(color: AppColors.inkMutedDark),
  css('[data-theme="light"] .card-p').styles(color: AppColors.inkMutedLight),

  css('.card-diff').styles(
    padding: .symmetric(vertical: 10.px, horizontal: 14.px),
    fontSize: 0.82.rem,
    border: Border.only(left: BorderSide.solid(color: AppColors.cyan, width: 2.px)),
  ),
  css('[data-theme="dark"] .card-diff').styles(
    backgroundColor: AppColors.surfaceElevatedDark,
    color: AppColors.inkDark,
  ),
  css('[data-theme="light"] .card-diff').styles(
    backgroundColor: AppColors.surfaceElevatedLight,
    color: AppColors.inkLight,
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
  ),
  css('[data-theme="dark"] .stat-tile').styles(
    backgroundColor: AppColors.surfaceDark,
    border: Border.all(color: AppColors.borderDark, width: 1.px),
  ),
  css('[data-theme="light"] .stat-tile').styles(
    backgroundColor: AppColors.surfaceLight,
    border: Border.all(color: AppColors.borderLight, width: 1.px),
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
  ),
  css('[data-theme="dark"] .stat-desc').styles(color: AppColors.inkMutedDark),
  css('[data-theme="light"] .stat-desc').styles(color: AppColors.inkMutedLight),

  css('.chart-panel').styles(
    margin: .only(top: 28.px),
    radius: BorderRadius.circular(4.px),
    padding: .all(24.px),
    overflow: Overflow.only(x: Overflow.auto),
  ),
  css('[data-theme="dark"] .chart-panel').styles(
    border: Border.all(color: AppColors.borderDark, width: 1.px),
    backgroundColor: AppColors.surfaceDark,
  ),
  css('[data-theme="light"] .chart-panel').styles(
    border: Border.all(color: AppColors.borderLight, width: 1.px),
    backgroundColor: AppColors.surfaceLight,
  ),

  css('.chart-title').styles(
    fontSize: 0.88.rem,
    margin: .only(bottom: 16.px),
  ),
  css('[data-theme="dark"] .chart-title').styles(color: AppColors.inkMutedDark),
  css('[data-theme="light"] .chart-title').styles(color: AppColors.inkMutedLight),
  css('[data-theme="dark"] .chart-title b').styles(color: AppColors.inkDark),
  css('[data-theme="light"] .chart-title b').styles(color: AppColors.inkLight),

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

  // Tables
  css('.table-scroll').styles(
    overflow: Overflow.only(x: Overflow.auto),
    margin: .only(top: 24.px),
  ),
  css('table.spec').styles(
    width: 100.percent,
    fontSize: 0.88.rem,
    radius: BorderRadius.circular(4.px),
  ),
  css('[data-theme="dark"] table.spec').styles(
    backgroundColor: AppColors.surfaceDark,
    border: Border.all(color: AppColors.borderDark, width: 1.px),
  ),
  css('[data-theme="light"] table.spec').styles(
    backgroundColor: AppColors.surfaceLight,
    border: Border.all(color: AppColors.borderLight, width: 1.px),
  ),
  css('table.spec caption').styles(
    textAlign: TextAlign.left,
    fontSize: 0.82.rem,
    margin: .only(bottom: 10.px),
    fontFamily: const .list([FontFamily('JetBrains Mono'), FontFamilies.monospace]),
  ),
  css('[data-theme="dark"] table.spec caption').styles(color: AppColors.inkMutedDark),
  css('[data-theme="light"] table.spec caption').styles(color: AppColors.inkMutedLight),

  css('table.spec th, table.spec td').styles(
    textAlign: TextAlign.left,
    padding: .symmetric(vertical: 12.px, horizontal: 16.px),
  ),
  css('[data-theme="dark"] table.spec th, [data-theme="dark"] table.spec td').styles(
    border: Border.only(bottom: BorderSide.solid(color: AppColors.borderDark, width: 1.px)),
  ),
  css('[data-theme="light"] table.spec th, [data-theme="light"] table.spec td').styles(
    border: Border.only(bottom: BorderSide.solid(color: AppColors.borderLight, width: 1.px)),
  ),

  css('table.spec thead th').styles(
    fontFamily: const .list([FontFamily('JetBrains Mono'), FontFamilies.monospace]),
    fontSize: 0.72.rem,
    letterSpacing: 0.08.em,
    textTransform: TextTransform.upperCase,
  ),
  css('[data-theme="dark"] table.spec thead th').styles(
    color: AppColors.inkMutedDark,
    backgroundColor: AppColors.surfaceElevatedDark,
    border: Border.only(bottom: BorderSide.solid(color: AppColors.borderBrightDark, width: 1.px)),
  ),
  css('[data-theme="light"] table.spec thead th').styles(
    color: AppColors.inkMutedLight,
    backgroundColor: AppColors.surfaceElevatedLight,
    border: Border.only(bottom: BorderSide.solid(color: AppColors.borderBrightLight, width: 1.px)),
  ),

  css('table.spec td.num, table.spec th.num').styles(
    textAlign: TextAlign.right,
    fontFamily: const .list([FontFamily('JetBrains Mono'), FontFamilies.monospace]),
  ),
  css('[data-theme="dark"] table.spec tbody tr:hover, [data-theme="dark"] table.matrix tbody tr:hover').styles(
    backgroundColor: AppColors.surfaceElevatedDark,
  ),
  css('[data-theme="light"] table.spec tbody tr:hover, [data-theme="light"] table.matrix tbody tr:hover').styles(
    backgroundColor: AppColors.surfaceElevatedLight,
  ),

  css('.note').styles(
    fontSize: 0.82.rem,
    margin: .only(top: 14.px),
    lineHeight: 1.5.em,
  ),
  css('[data-theme="dark"] .note').styles(color: AppColors.inkMutedDark),
  css('[data-theme="light"] .note').styles(color: AppColors.inkMutedLight),

  // Matrix
  css('table.matrix').styles(
    width: 100.percent,
    margin: .only(top: 24.px),
    fontSize: 0.88.rem,
    minWidth: 720.px,
    radius: BorderRadius.circular(4.px),
  ),
  css('[data-theme="dark"] table.matrix').styles(
    backgroundColor: AppColors.surfaceDark,
    border: Border.all(color: AppColors.borderDark, width: 1.px),
  ),
  css('[data-theme="light"] table.matrix').styles(
    backgroundColor: AppColors.surfaceLight,
    border: Border.all(color: AppColors.borderLight, width: 1.px),
  ),
  css('table.matrix th, table.matrix td').styles(
    padding: .symmetric(vertical: 12.px, horizontal: 14.px),
  ),
  css('[data-theme="dark"] table.matrix th, [data-theme="dark"] table.matrix td').styles(
    border: Border.only(bottom: BorderSide.solid(color: AppColors.borderDark, width: 1.px)),
  ),
  css('[data-theme="light"] table.matrix th, [data-theme="light"] table.matrix td').styles(
    border: Border.only(bottom: BorderSide.solid(color: AppColors.borderLight, width: 1.px)),
  ),
  css('table.matrix thead th').styles(
    fontFamily: const .list([FontFamily('JetBrains Mono'), FontFamilies.monospace]),
    fontSize: 0.72.rem,
    letterSpacing: 0.06.em,
    textTransform: TextTransform.upperCase,
    textAlign: TextAlign.center,
  ),
  css('[data-theme="dark"] table.matrix thead th').styles(
    color: AppColors.inkMutedDark,
    backgroundColor: AppColors.surfaceElevatedDark,
    border: Border.only(bottom: BorderSide.solid(color: AppColors.borderBrightDark, width: 1.px)),
  ),
  css('[data-theme="light"] table.matrix thead th').styles(
    color: AppColors.inkMutedLight,
    backgroundColor: AppColors.surfaceElevatedLight,
    border: Border.only(bottom: BorderSide.solid(color: AppColors.borderBrightLight, width: 1.px)),
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
  css('.yes').styles(
    color: AppColors.green,
    fontWeight: FontWeight.w700,
  ),
  css('.partial').styles(
    color: AppColors.amber,
    fontWeight: FontWeight.w700,
  ),
  css('.no').styles(
    color: AppColors.inkMutedDark,
  ),
  css('.matrix-legend').styles(
    margin: .only(top: 12.px),
    fontSize: 0.8.rem,
    display: Display.flex,
    gap: Gap(column: 20.px),
  ),
  css('[data-theme="dark"] .matrix-legend').styles(color: AppColors.inkMutedDark),
  css('[data-theme="light"] .matrix-legend').styles(color: AppColors.inkMutedLight),

  // Code Container
  css('.code-container').styles(
    margin: .only(top: 36.px),
    radius: BorderRadius.circular(4.px),
    overflow: Overflow.hidden,
  ),
  css('[data-theme="dark"] .code-container').styles(
    backgroundColor: AppColors.surfaceDark,
    border: Border.all(color: AppColors.borderDark, width: 1.px),
  ),
  css('[data-theme="light"] .code-container').styles(
    backgroundColor: AppColors.surfaceLight,
    border: Border.all(color: AppColors.borderLight, width: 1.px),
  ),

  css('.code-header-bar').styles(
    display: Display.flex,
    alignItems: AlignItems.center,
    justifyContent: JustifyContent.spaceBetween,
    padding: .symmetric(vertical: 4.px, horizontal: 8.px),
  ),
  css('[data-theme="dark"] .code-header-bar').styles(
    backgroundColor: AppColors.surfaceElevatedDark,
    border: Border.only(bottom: BorderSide.solid(color: AppColors.borderDark, width: 1.px)),
  ),
  css('[data-theme="light"] .code-header-bar').styles(
    backgroundColor: AppColors.surfaceElevatedLight,
    border: Border.only(bottom: BorderSide.solid(color: AppColors.borderLight, width: 1.px)),
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
  ),
  css('[data-theme="dark"] .tab-btn').styles(color: AppColors.inkMutedDark),
  css('[data-theme="light"] .tab-btn').styles(color: AppColors.inkMutedLight),

  css('.tab-btn.active').styles(
    color: AppColors.cyan,
    fontWeight: FontWeight.w600,
    shadow: BoxShadow(
      offsetX: 0.px,
      offsetY: 1.px,
      blur: 3.px,
      color: Color('rgba(0, 0, 0, 0.2)'),
    ),
  ),
  css('[data-theme="dark"] .tab-btn.active').styles(backgroundColor: AppColors.surfaceDark),
  css('[data-theme="light"] .tab-btn.active').styles(backgroundColor: AppColors.surfaceLight),

  css('.code-content').styles(
    padding: .all(24.px),
    overflow: Overflow.only(x: Overflow.auto),
    fontSize: 0.88.rem,
    lineHeight: 1.68.em,
  ),
  css('[data-theme="dark"] .code-content').styles(backgroundColor: AppColors.bgDark),
  css('[data-theme="light"] .code-content').styles(backgroundColor: AppColors.bgLight),

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
  ),
  css('[data-theme="dark"] .topology-card').styles(
    backgroundColor: AppColors.surfaceDark,
    border: Border.all(color: AppColors.borderDark, width: 1.px),
  ),
  css('[data-theme="light"] .topology-card').styles(
    backgroundColor: AppColors.surfaceLight,
    border: Border.all(color: AppColors.borderLight, width: 1.px),
  ),

  css('[data-theme="dark"] .topology-card.flutter-layer').styles(
    backgroundColor: AppColors.surfaceElevatedDark,
    border: Border.all(color: AppColors.cyan, width: 1.px),
  ),
  css('[data-theme="light"] .topology-card.flutter-layer').styles(
    backgroundColor: AppColors.surfaceElevatedLight,
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
  ),
  css('[data-theme="dark"] .topology-desc').styles(color: AppColors.inkMutedDark),
  css('[data-theme="light"] .topology-desc').styles(color: AppColors.inkMutedLight),

  // Footer
  css('footer').styles(
    margin: .only(top: 80.px),
    padding: .only(top: 56.px, bottom: 72.px),
  ),
  css('[data-theme="dark"] footer').styles(
    backgroundColor: AppColors.surfaceDark,
    border: Border.only(top: BorderSide.solid(color: AppColors.borderDark, width: 1.px)),
  ),
  css('[data-theme="light"] footer').styles(
    backgroundColor: AppColors.surfaceLight,
    border: Border.only(top: BorderSide.solid(color: AppColors.borderLight, width: 1.px)),
  ),

  css('.footer-bottom').styles(
    margin: .only(top: 40.px),
    display: Display.flex,
    justifyContent: JustifyContent.spaceBetween,
    alignItems: AlignItems.center,
    flexWrap: FlexWrap.wrap,
    gap: Gap(row: 16.px, column: 16.px),
    fontSize: 0.82.rem,
  ),
  css('[data-theme="dark"] .footer-bottom').styles(color: AppColors.inkMutedDark),
  css('[data-theme="light"] .footer-bottom').styles(color: AppColors.inkMutedLight),

  // =========================================================================
  // Responsive Media Queries (Tablets & Mobile)
  // =========================================================================
  css.media(MediaQuery.screen(maxWidth: 992.px), [
    css('.blueprint-grid').styles(
      gridTemplate: GridTemplate(
        columns: GridTracks([
          GridTrack(TrackSize.fr(1)),
          GridTrack(TrackSize.fr(1)),
        ]),
      ),
    ),
  ]),

  css.media(MediaQuery.screen(maxWidth: 768.px), [
    css('body').styles(
      overflow: Overflow.only(x: Overflow.clip),
      width: 100.percent,
    ),
    css('.wrap').styles(
      padding: .symmetric(horizontal: 16.px),
    ),
    css('.rule').styles(
      margin: .symmetric(vertical: 44.px, horizontal: .auto),
      maxWidth: 100.percent,
    ),
    css('section').styles(
      padding: .only(top: 48.px, bottom: 38.px),
    ),

    // Navbar Mobile
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
      overflow: Overflow.only(x: Overflow.auto),
      gap: Gap(column: 14.px),
      padding: .only(top: 2.px, bottom: 6.px),
      fontSize: 0.8.rem,
    ),
    css('.nav-links a, .nav-links .theme-toggle').styles(
      whiteSpace: WhiteSpace.noWrap,
      flex: Flex(shrink: 0),
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
      fontSize: 2.2.rem,
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
      flex: Flex(grow: 1),
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
      overflow: Overflow.only(x: Overflow.auto),
      padding: .only(bottom: 6.px),
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
      overflow: Overflow.only(x: Overflow.auto),
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
      radius: BorderRadius.circular(4.px),
    ),
    css('[data-theme="dark"] .table-scroll').styles(
      border: Border.all(color: AppColors.borderDark, width: 1.px),
    ),
    css('[data-theme="light"] .table-scroll').styles(
      border: Border.all(color: AppColors.borderLight, width: 1.px),
    ),

    css('table.spec, table.matrix').styles(
      border: Border.unset,
      margin: .only(top: 0.px),
      fontSize: 0.78.rem,
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
      maxWidth: 180.px,
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
      overflow: Overflow.only(x: Overflow.auto),
      whiteSpace: WhiteSpace.noWrap,
      padding: .only(bottom: 4.px),
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
