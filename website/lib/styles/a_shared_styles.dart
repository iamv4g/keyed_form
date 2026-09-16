import 'package:jaspr/dom.dart';

import 'theme_tokens.dart';

/// Styles shared across the landing page and the docs page — foundational
/// resets, typography, and the small set of components (Footer, buttons,
/// code display, tables) that appear on both.
@css
List<StyleRule> get sharedStyles => [
  // Base default fallback tokens (dark theme default)
  css(':root').styles(raw: darkThemeTokens),

  // Automatic System Theme Preference
  css.media(const MediaQuery.all(prefersColorScheme: ColorScheme.light), [
    css(':root:not([data-theme="dark"])').styles(raw: lightThemeTokens),
  ]),
  css.media(const MediaQuery.all(prefersColorScheme: ColorScheme.dark), [
    css(':root:not([data-theme="light"])').styles(raw: darkThemeTokens),
  ]),

  // Manual Overrides (set via theme toggle)
  css(':root[data-theme="dark"]').styles(raw: darkThemeTokens),
  css(':root[data-theme="light"]').styles(raw: lightThemeTokens),

  // Reset & Base
  css('*').styles(
    boxSizing: BoxSizing.borderBox,
    margin: .zero,
    padding: .zero,
  ),

  css('html').styles(
    raw: {
      'scroll-behavior': 'smooth',
      'overflow-x': 'hidden',
    },
  ),

  css('body').styles(
    overflow: Overflow.only(x: Overflow.clip),
    maxWidth: 100.percent,
    fontFamily: const .list([FontFamily('Inter'), FontFamilies.sansSerif]),
    fontSize: 15.px,
    lineHeight: 1.6.em,
    color: AppColors.ink,
    backgroundColor: AppColors.bg,
    raw: {
      'background-image':
          'linear-gradient(to right, var(--grid) 1px, transparent 1px), linear-gradient(to bottom, var(--grid) 1px, transparent 1px)',
      'background-size': '32px 32px',
      '-webkit-font-smoothing': 'antialiased',
      'transition': 'background 0.2s, color 0.2s',
      'overflow-x': 'clip',
    },
  ),

  css('section, [id]').styles(
    raw: {
      'scroll-margin-top': '80px',
    },
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
      border: Border.all(color: AppColors.border, width: 1.px),
      backgroundColor: AppColors.surface,
    ),
    css('&::before, &::after').styles(
      content: '',
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
    raw: {
      'background':
          'linear-gradient(90deg, transparent, var(--border) 15%, var(--border-bright) 50%, var(--border) 85%, transparent)',
      'width': 'calc(100% - 48px)',
    },
  ),

  css('.theme-toggle').styles(
    backgroundColor: AppColors.surfaceElevated,
    border: Border.all(color: AppColors.border, width: 1.px),
    color: AppColors.ink,
    padding: .symmetric(vertical: 6.px, horizontal: 12.px),
    radius: BorderRadius.circular(4.px),
    cursor: Cursor.pointer,
    fontSize: 0.78.rem,
    display: Display.flex,
    alignItems: AlignItems.center,
    gap: Gap(column: 6.px),
    transition: const Transition('all', duration: Duration(milliseconds: 150)),
  ),
  css('.theme-toggle:hover').styles(
    color: AppColors.cyan,
    border: Border.all(color: AppColors.cyan, width: 1.px),
  ),

  css('.copy-btn').styles(
    backgroundColor: AppColors.surfaceElevated,
    border: Border.all(color: AppColors.border, width: 1.px),
    color: AppColors.inkMuted,
    padding: .symmetric(vertical: 5.px, horizontal: 10.px),
    fontSize: 0.75.rem,
    cursor: Cursor.pointer,
    radius: BorderRadius.circular(2.px),
    transition: const Transition('all', duration: Duration(milliseconds: 150)),
  ),
  css('.copy-btn:hover').styles(
    color: AppColors.ink,
    border: Border.all(color: AppColors.cyan, width: 1.px),
  ),

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
    transform: Transform.translate(y: (-1).px),
    raw: {
      'box-shadow': '0 0 16px var(--cyan-glow)',
    },
  ),
  css('.btn-outline').styles(
    backgroundColor: AppColors.surface,
    color: AppColors.ink,
    border: Border.all(color: AppColors.borderBright, width: 1.px),
    textDecoration: TextDecoration.none,
  ),
  css('.btn-outline:hover').styles(
    color: AppColors.cyan,
    border: Border.all(color: AppColors.cyan, width: 1.px),
  ),

  // Section Headings (reused by every home section and every docs chapter)
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
    color: AppColors.inkMuted,
  ),

  // Tables
  css('table').styles(
    raw: {
      'border-collapse': 'collapse',
      'border-spacing': '0',
    },
  ),

  css('.table-scroll').styles(
    overflow: Overflow.only(x: Overflow.auto),
    margin: .only(top: 24.px),
  ),
  css('table.spec').styles(
    width: 100.percent,
    border: Border.all(color: AppColors.border, width: 1.px),
    radius: BorderRadius.circular(4.px),
    overflow: Overflow.hidden,
    fontSize: 0.88.rem,
    backgroundColor: AppColors.surface,
    raw: {
      'border-collapse': 'collapse',
      'border-spacing': '0',
    },
  ),
  css('table.spec caption').styles(
    textAlign: TextAlign.left,
    fontSize: 0.82.rem,
    margin: .only(bottom: 10.px),
    fontFamily: const .list([FontFamily('JetBrains Mono'), FontFamilies.monospace]),
    color: AppColors.inkMuted,
  ),

  css('table.spec th, table.spec td').styles(
    textAlign: TextAlign.left,
    padding: .symmetric(vertical: 12.px, horizontal: 16.px),
    border: Border.only(
      bottom: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
  ),

  css('table.spec thead th').styles(
    fontFamily: const .list([FontFamily('JetBrains Mono'), FontFamilies.monospace]),
    fontSize: 0.72.rem,
    letterSpacing: 0.08.em,
    textTransform: TextTransform.upperCase,
    color: AppColors.inkMuted,
    backgroundColor: AppColors.surfaceElevated,
    border: Border.only(
      bottom: BorderSide.solid(color: AppColors.borderBright, width: 1.px),
    ),
  ),

  css('table.spec td.num, table.spec th.num').styles(
    textAlign: TextAlign.right,
    fontFamily: const .list([FontFamily('JetBrains Mono'), FontFamilies.monospace]),
  ),
  css('table.spec tbody tr:hover, table.matrix tbody tr:hover').styles(
    backgroundColor: AppColors.surfaceElevated,
  ),

  css('.note').styles(
    fontSize: 0.82.rem,
    margin: .only(top: 14.px),
    lineHeight: 1.5.em,
    color: AppColors.inkMuted,
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
    color: AppColors.inkMuted,
  ),

  // Footer (rendered on both the landing page and the docs page)
  css('footer').styles(
    margin: .only(top: 80.px),
    padding: .only(top: 56.px, bottom: 72.px),
    backgroundColor: AppColors.surface,
    border: Border.only(
      top: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
  ),

  css('.footer-bottom').styles(
    margin: .only(top: 40.px),
    display: Display.flex,
    justifyContent: JustifyContent.spaceBetween,
    alignItems: AlignItems.center,
    flexWrap: FlexWrap.wrap,
    gap: Gap(row: 16.px, column: 16.px),
    fontSize: 0.82.rem,
    color: AppColors.inkMuted,
  ),
  css('.footer-links').styles(
    display: Display.flex,
    flexWrap: FlexWrap.wrap,
    gap: Gap(row: 8.px, column: 16.px),
  ),
  css('.footer-link').styles(
    color: AppColors.inkMuted,
    textDecoration: const TextDecoration(line: TextDecorationLine.none),
  ),

  // Syntax highlighting & misc utility classes (used by both CodeSection and
  // every DocsCodeBlock)
  css('.syntax-comment').styles(color: AppColors.inkMuted),
  css('.syntax-keyword').styles(color: AppColors.cyan),
  css('.syntax-string').styles(color: AppColors.amber),
  css('.syntax-success').styles(color: AppColors.green),
  css('.text-cyan').styles(color: AppColors.cyan),
  css('.text-red').styles(color: AppColors.red),
  css('.font-semibold').styles(fontWeight: FontWeight.w600),
  css('.mt-24').styles(margin: .only(top: 24.px)),
  css('.code-filename').styles(
    fontSize: 0.8.rem,
    color: AppColors.inkMuted,
  ),
];
