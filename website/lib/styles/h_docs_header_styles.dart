import 'package:jaspr/dom.dart';

import 'theme_tokens.dart';

/// The two-row header on docs and playground pages, sized after
/// docs.jaspr.site: brand + actions, then the section tabs. Buttons and
/// tabs share its 10px radius; key caps use 6px.
@css
List<StyleRule> get docsHeaderStyles => [
  // Solid, no backdrop-filter: a filter would become the containing block of
  // the search overlay (position: fixed) and trap it inside the header.
  css('.docs-header').styles(
    backgroundColor: AppColors.bg,
    fontFamily: const .list([FontFamily('Inter'), FontFamilies.sansSerif]),
    raw: {'backdrop-filter': 'none', '-webkit-backdrop-filter': 'none'},
  ),
  css('.docs-header-top').styles(
    display: Display.flex,
    alignItems: AlignItems.center,
    justifyContent: JustifyContent.spaceBetween,
    gap: Gap(column: 12.px),
    padding: .only(top: 10.px, left: 20.px, right: 20.px),
    height: 48.px,
  ),
  css('.docs-header-actions').styles(
    display: Display.flex,
    alignItems: AlignItems.center,
    gap: Gap(column: 4.px),
  ),
  css('.docs-header-tabs').styles(
    display: Display.flex,
    alignItems: AlignItems.center,
    gap: Gap(column: 4.px),
    padding: .only(top: 6.px, bottom: 10.px, left: 16.px, right: 16.px),
  ),

  // Section tabs: a segmented control.
  css('.docs-tabs').styles(
    display: Display.inlineFlex,
    alignItems: AlignItems.center,
    padding: .all(3.px),
    backgroundColor: AppColors.surfaceElevated,
    radius: BorderRadius.circular(10.px),
    overflow: Overflow.only(x: Overflow.auto),
    raw: {'scrollbar-width': 'none', 'max-width': '100%'},
  ),
  css('.docs-tab').styles(
    display: Display.inlineFlex,
    alignItems: AlignItems.center,
    height: 28.px,
    padding: .symmetric(horizontal: 12.px),
    fontSize: 0.875.rem,
    fontWeight: FontWeight.w500,
    color: AppColors.inkMuted,
    whiteSpace: WhiteSpace.noWrap,
    textDecoration: TextDecoration.none,
    border: Border.all(color: Colors.transparent, width: 1.px),
    radius: BorderRadius.circular(10.px),
    transition: const Transition('all', duration: Duration(milliseconds: 150)),
    raw: {'flex': 'none'},
  ),
  css('.docs-tab:hover').styles(color: AppColors.ink),
  css('.docs-tab.active').styles(
    color: AppColors.ink,
    raw: {'background-color': 'var(--control-bg)', 'border-color': 'var(--control-border)'},
  ),

  // Outline button: Search.
  css('.search-button').styles(
    display: Display.inlineFlex,
    alignItems: AlignItems.center,
    gap: Gap(column: 8.px),
    height: 32.px,
    padding: .symmetric(horizontal: 10.px),
    fontSize: 0.875.rem,
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
    border: Border.all(color: AppColors.border, width: 1.px),
    radius: BorderRadius.circular(10.px),
    cursor: Cursor.pointer,
    raw: {'background-color': 'var(--control-bg)', 'border-color': 'var(--control-border)'},
  ),
  css('.search-button:hover').styles(backgroundColor: AppColors.surfaceElevated),
  css('.search-kbd').styles(
    display: Display.inlineFlex,
    alignItems: AlignItems.center,
    height: 17.px,
    padding: .symmetric(horizontal: 4.px),
    fontFamily: const .list([FontFamily('Inter'), FontFamilies.sansSerif]),
    fontSize: 0.75.rem,
    fontWeight: FontWeight.w500,
    color: AppColors.inkMuted,
    backgroundColor: AppColors.surfaceElevated,
    radius: BorderRadius.circular(6.px),
  ),

  // Ghost buttons: GitHub, theme, sidebar toggle.
  css('.header-icon-button, .docs-header .theme-toggle, .sidebar-trigger').styles(
    display: Display.inlineFlex,
    alignItems: AlignItems.center,
    justifyContent: JustifyContent.center,
    height: 36.px,
    padding: .symmetric(horizontal: 10.px),
    color: AppColors.ink,
    backgroundColor: Colors.transparent,
    border: Border.all(color: Colors.transparent, width: 1.px),
    radius: BorderRadius.circular(10.px),
    cursor: Cursor.pointer,
    raw: {'width': 'auto'},
  ),
  css('.header-icon-button:hover, .docs-header .theme-toggle:hover, .sidebar-trigger:hover').styles(
    backgroundColor: AppColors.surfaceElevated,
    color: AppColors.ink,
  ),
  css('.sidebar-trigger').styles(
    display: Display.none,
    height: 28.px,
    padding: .symmetric(horizontal: 6.px),
    raw: {'flex': 'none'},
  ),

  // Search dialog.
  css('.search-overlay').styles(
    position: Position.fixed(top: 0.px, left: 0.px, right: 0.px, bottom: 0.px),
    zIndex: ZIndex(2000),
    display: Display.flex,
    justifyContent: JustifyContent.center,
    alignItems: AlignItems.start,
    padding: .only(top: 12.vh, left: 16.px, right: 16.px),
    backgroundColor: Color('rgba(0, 0, 0, 0.5)'),
    raw: {'backdrop-filter': 'blur(2px)'},
  ),
  css('.search-dialog').styles(
    width: 100.percent,
    maxWidth: 560.px,
    backgroundColor: AppColors.bg,
    border: Border.all(color: AppColors.border, width: 1.px),
    radius: BorderRadius.circular(12.px),
    overflow: Overflow.hidden,
    raw: {'box-shadow': 'var(--card-shadow)'},
    fontFamily: const .list([FontFamily('Inter'), FontFamilies.sansSerif]),
  ),
  css('.search-field').styles(
    display: Display.flex,
    alignItems: AlignItems.center,
    gap: Gap(column: 10.px),
    padding: .symmetric(horizontal: 14.px),
    color: AppColors.inkMuted,
    border: Border.only(
      bottom: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
  ),
  css('.search-input').styles(
    height: 48.px,
    fontSize: 1.rem,
    color: AppColors.ink,
    backgroundColor: Colors.transparent,
    border: Border.unset,
    raw: {'flex': '1', 'outline': 'none', 'min-width': '0'},
  ),
  css('.search-empty').styles(
    padding: .all(20.px),
    fontSize: 0.9.rem,
    color: AppColors.inkMuted,
  ),
  css('.search-results').styles(
    listStyle: ListStyle.none,
    padding: .all(6.px),
    maxHeight: 60.vh,
    overflow: Overflow.only(y: Overflow.auto),
  ),
  css('.search-result').styles(
    display: Display.flex,
    flexDirection: FlexDirection.column,
    gap: Gap(row: 2.px),
    padding: .symmetric(vertical: 8.px, horizontal: 10.px),
    textDecoration: TextDecoration.none,
    radius: BorderRadius.circular(6.px),
  ),
  css('.search-result.selected, .search-result:hover').styles(backgroundColor: AppColors.surfaceElevated),
  css('.search-result-title').styles(
    fontSize: 0.9.rem,
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
  ),
  css('.search-result-text').styles(
    fontSize: 0.8.rem,
    lineHeight: 1.45.em,
    color: AppColors.inkMuted,
    raw: {
      'display': '-webkit-box',
      '-webkit-line-clamp': '2',
      '-webkit-box-orient': 'vertical',
      'overflow': 'hidden',
    },
  ),

  // At md: the Search label and ⌘K hide (icon only) and the sidebar toggle
  // appears before the tabs.
  css.media(MediaQuery.screen(maxWidth: 768.px), [
    css('.search-label, .search-button .search-kbd').styles(display: Display.none),
    css('.search-button').styles(width: 32.px, padding: .zero, justifyContent: JustifyContent.center),
    css('.sidebar-trigger').styles(display: Display.inlineFlex),
    css('.docs-header-top').styles(
      padding: .only(top: 10.px, left: 16.px, right: 12.px),
    ),
  ]),
];
