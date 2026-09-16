import 'package:jaspr/dom.dart';

import 'theme_tokens.dart';

/// Styles specific to the /docs page: sidebar, chapter content, callouts,
/// code blocks, and the "on this page" TOC. The header is the shared
/// Navbar (b_home_styles.dart) — the same on every page.
@css
List<StyleRule> get docsStyles => [
  // Docs Layout Container
  css('.docs-container').styles(
    maxWidth: 1440.px,
    margin: .symmetric(horizontal: .auto),
    padding: .symmetric(horizontal: 24.px),
  ),
  css('.docs-layout').styles(
    display: Display.grid,
    gap: Gap(column: 36.px),
    padding: .only(top: 32.px, bottom: 64.px),
    raw: {
      'grid-template-columns': '260px minmax(0, 1fr) 210px',
    },
  ),

  // Docs Sidebar
  css('.docs-sidebar').styles(
    position: Position.sticky(top: 88.px),
    height: Unit.expression('calc(100vh - 100px)'),
    overflow: Overflow.only(y: Overflow.auto),
    padding: .only(right: 12.px),
  ),
  css('.docs-search-box').styles(
    margin: .only(bottom: 20.px),
  ),
  css('.docs-search-input').styles(
    width: 100.percent,
    padding: .symmetric(vertical: 8.px, horizontal: 12.px),
    fontSize: 0.8.rem,
    backgroundColor: AppColors.surface,
    border: Border.all(color: AppColors.border, width: 1.px),
    color: AppColors.ink,
    radius: BorderRadius.circular(4.px),
    raw: {
      'outline': 'none',
      'transition': 'border-color 0.15s, box-shadow 0.15s',
    },
  ),
  css('.docs-search-input:focus').styles(
    border: Border.all(color: AppColors.cyan, width: 1.px),
    raw: {
      'box-shadow': '0 0 8px var(--cyan-glow)',
    },
  ),
  css('.docs-nav-group').styles(
    margin: .only(bottom: 22.px),
  ),
  css('.docs-nav-group-title').styles(
    fontSize: 0.68.rem,
    letterSpacing: 0.1.em,
    color: AppColors.inkFaint,
    margin: .only(bottom: 8.px),
    textTransform: TextTransform.upperCase,
    fontWeight: FontWeight.w700,
  ),
  css('.docs-nav-list').styles(
    listStyle: ListStyle.none,
  ),
  css('.docs-nav-item').styles(
    margin: .only(bottom: 2.px),
  ),
  css('.docs-nav-link').styles(
    display: Display.flex,
    alignItems: AlignItems.center,
    justifyContent: JustifyContent.spaceBetween,
    padding: .symmetric(vertical: 6.px, horizontal: 10.px),
    radius: BorderRadius.circular(3.px),
    fontSize: 0.82.rem,
    color: AppColors.inkMuted,
    textDecoration: const TextDecoration(line: TextDecorationLine.none),
    transition: const Transition('all', duration: Duration(milliseconds: 120)),
  ),
  css('.docs-nav-link:hover').styles(
    color: AppColors.cyan,
    backgroundColor: AppColors.surfaceElevated,
  ),
  css('.docs-nav-link .nav-badge').styles(
    fontSize: 0.62.rem,
    padding: .symmetric(vertical: 1.px, horizontal: 5.px),
    backgroundColor: AppColors.cyanGlow,
    color: AppColors.cyan,
    radius: BorderRadius.circular(2.px),
    fontWeight: FontWeight.w700,
  ),

  // Docs Content
  css('.docs-content').styles(
    minWidth: 0.px,
    overflow: Overflow.only(x: Overflow.clip),
  ),
  css('.docs-section').styles(
    padding: .only(bottom: 24.px),
  ),
  css('.docs-anchor').styles(
    raw: {
      'scroll-margin-top': '90px',
    },
  ),
  css('.docs-h2').styles(
    fontSize: 1.85.rem,
    fontWeight: FontWeight.w700,
    letterSpacing: (-0.02).em,
    margin: .only(top: 8.px, bottom: 16.px),
    color: AppColors.ink,
  ),
  css('.docs-h3').styles(
    fontSize: 1.25.rem,
    fontWeight: FontWeight.w600,
    margin: .only(top: 28.px, bottom: 12.px),
    color: AppColors.ink,
  ),
  css('.docs-lead').styles(
    fontSize: 1.05.rem,
    lineHeight: 1.65.em,
    color: AppColors.ink,
    margin: .only(bottom: 16.px),
  ),
  css('.docs-section p').styles(
    margin: .only(bottom: 14.px),
    lineHeight: 1.65.em,
    color: AppColors.inkMuted,
  ),
  css('.docs-section p b').styles(
    color: AppColors.ink,
  ),
  css('.docs-list').styles(
    margin: .only(top: 8.px, bottom: 16.px, left: 20.px),
    lineHeight: 1.65.em,
    color: AppColors.inkMuted,
  ),
  css('.docs-list li').styles(
    margin: .only(bottom: 6.px),
  ),
  css('.docs-list li code').styles(
    color: AppColors.cyan,
    fontSize: 0.88.rem,
  ),

  // Docs Callouts
  css('.docs-callout').styles(
    margin: .symmetric(vertical: 20.px),
    padding: .symmetric(vertical: 18.px, horizontal: 20.px),
    radius: BorderRadius.circular(4.px),
    backgroundColor: AppColors.surface,
    border: Border.all(color: AppColors.border, width: 1.px),
  ),
  css('.docs-callout.callout-reassurance').styles(
    backgroundColor: AppColors.surfaceElevated,
    border: Border.only(
      left: BorderSide.solid(color: AppColors.cyan, width: 3.px),
      top: BorderSide.solid(color: AppColors.border, width: 1.px),
      right: BorderSide.solid(color: AppColors.border, width: 1.px),
      bottom: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
  ),
  css('.docs-callout.callout-tip').styles(
    border: Border.only(
      left: BorderSide.solid(color: AppColors.cyan, width: 3.px),
      top: BorderSide.solid(color: AppColors.border, width: 1.px),
      right: BorderSide.solid(color: AppColors.border, width: 1.px),
      bottom: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
  ),
  css('.docs-callout.callout-warning').styles(
    border: Border.only(
      left: BorderSide.solid(color: AppColors.amber, width: 3.px),
      top: BorderSide.solid(color: AppColors.border, width: 1.px),
      right: BorderSide.solid(color: AppColors.border, width: 1.px),
      bottom: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
  ),
  css('.callout-kicker').styles(
    fontSize: 0.68.rem,
    letterSpacing: 0.1.em,
    fontWeight: FontWeight.w700,
    color: AppColors.cyan,
    display: Display.block,
    margin: .only(bottom: 6.px),
  ),
  css('.callout-warning .callout-kicker').styles(
    color: AppColors.amber,
  ),
  css('.callout-title').styles(
    fontSize: 1.05.rem,
    fontWeight: FontWeight.w600,
    margin: .only(bottom: 12.px),
    color: AppColors.ink,
  ),
  css('.callout-body p').styles(
    margin: .only(bottom: 10.px),
    fontSize: 0.9.rem,
    lineHeight: 1.6.em,
  ),

  // Docs Code Box
  css('.docs-code-box').styles(
    margin: .symmetric(vertical: 18.px),
    radius: BorderRadius.circular(4.px),
    overflow: Overflow.hidden,
    backgroundColor: AppColors.surface,
    border: Border.all(color: AppColors.border, width: 1.px),
  ),
  css('.docs-code-header').styles(
    display: Display.flex,
    alignItems: AlignItems.center,
    justifyContent: JustifyContent.spaceBetween,
    padding: .symmetric(vertical: 8.px, horizontal: 14.px),
    backgroundColor: AppColors.surfaceElevated,
    border: Border.only(
      bottom: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
  ),
  css('.docs-code-title').styles(
    display: Display.flex,
    alignItems: AlignItems.center,
    gap: Gap(column: 8.px),
    fontSize: 0.78.rem,
    color: AppColors.inkMuted,
  ),
  css('.code-dot').styles(
    width: 6.px,
    height: 6.px,
    backgroundColor: AppColors.cyan,
    radius: BorderRadius.circular(50.percent),
  ),
  css('.docs-code-actions').styles(
    display: Display.flex,
    alignItems: AlignItems.center,
    gap: Gap(column: 10.px),
  ),
  css('.code-lang-tag').styles(
    fontSize: 0.65.rem,
    color: AppColors.inkFaint,
    letterSpacing: 0.08.em,
  ),
  css('.docs-code-content').styles(
    padding: .all(20.px),
    overflow: Overflow.only(x: Overflow.auto),
    fontSize: 0.85.rem,
    lineHeight: 1.65.em,
    backgroundColor: AppColors.bg,
    raw: {
      '-webkit-overflow-scrolling': 'touch',
    },
  ),

  // Docs TOC
  css('.docs-toc').styles(
    position: Position.sticky(top: 88.px),
    height: Unit.expression('calc(100vh - 100px)'),
    overflow: Overflow.only(y: Overflow.auto),
  ),
  css('.docs-toc-header').styles(
    fontSize: 0.68.rem,
    letterSpacing: 0.1.em,
    color: AppColors.inkFaint,
    fontWeight: FontWeight.w700,
    margin: .only(bottom: 4.px),
  ),
  css('.docs-toc-group-title').styles(
    fontSize: 0.72.rem,
    letterSpacing: 0.06.em,
    color: AppColors.cyan,
    fontWeight: FontWeight.w700,
    margin: .only(bottom: 12.px),
  ),
  css('.docs-toc-list').styles(
    listStyle: ListStyle.none,
    border: Border.only(
      left: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
    padding: .only(left: 12.px),
  ),
  css('.docs-toc-list li').styles(
    margin: .only(bottom: 8.px),
  ),
  css('.docs-toc-list a').styles(
    fontSize: 0.78.rem,
    color: AppColors.inkMuted,
    textDecoration: const TextDecoration(line: TextDecorationLine.none),
    display: Display.block,
    transition: const Transition('color', duration: Duration(milliseconds: 120)),
  ),
  css('.docs-toc-list a:hover').styles(
    color: AppColors.cyan,
  ),
  css('.docs-toc-list a.active').styles(
    color: AppColors.cyan,
    fontWeight: FontWeight.w600,
  ),
];
