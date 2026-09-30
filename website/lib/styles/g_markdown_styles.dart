import 'package:jaspr/dom.dart';

import 'container_rule.dart';
import 'theme_tokens.dart';

/// Markdown docs pages (`content/docs/`): one idea per page, plain type.
@css
List<StyleRule> get markdownStyles => [
  // Sidebar | article + on-this-page, inside the header's `.docs-shell`.
  css('.docs-body').styles(
    display: Display.flex,
    alignItems: AlignItems.start,
  ),
  css('.md-sidebar').styles(
    width: Unit.expression('var(--sidebar-width)'),
    fontSize: 0.875.rem,
    raw: {'flex': 'none'},
  ),
  css('.md-sidebar-panel').styles(
    position: Position.sticky(top: Unit.expression('var(--docs-header-h)')),
    height: Unit.expression('calc(100svh - var(--docs-header-h))'),
    padding: .only(top: 32.px, bottom: 32.px, left: 8.px),
    overflow: Overflow.only(y: Overflow.auto),
  ),
  // The article's padding and the TOC follow this column's width, not the
  // viewport's.
  css('.docs-main').styles(
    display: Display.flex,
    minWidth: 0.px,
    raw: {'flex': '1', 'container-type': 'inline-size'},
  ),
  css('.docs-article').styles(
    minWidth: 0.px,
    padding: .only(top: 40.px, bottom: 48.px, left: 24.px, right: 24.px),
    raw: {'flex': '1'},
  ),
  css('.docs-toc').styles(
    display: Display.none,
    width: 272.px,
    raw: {'flex': 'none'},
  ),
  css('.docs-toc-inner').styles(
    position: Position.sticky(top: Unit.expression('var(--docs-header-h)')),
    maxHeight: Unit.expression('calc(100svh - var(--docs-header-h))'),
    padding: .only(top: 40.px, bottom: 32.px),
    overflow: Overflow.only(y: Overflow.auto),
  ),
  ContainerStyleRule('(min-width: 48rem)', [
    css('.docs-article').styles(
      padding: .only(left: 56.px, right: 56.px),
    ),
    css('.docs-toc').styles(display: Display.block),
  ]),
  ContainerStyleRule('(min-width: 64rem)', [
    css('.docs-article').styles(
      padding: .only(left: 64.px, right: 64.px),
    ),
  ]),
  css('.docs-toc-header').styles(
    margin: .only(bottom: 8.px),
    fontSize: 0.875.rem,
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
  ),
  css('.md-backdrop').styles(display: Display.none),
  css('.md-sidebar-group').styles(
    margin: .only(top: 20.px, bottom: 8.px),
    fontSize: 0.78.rem,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  ),
  css('.md-sidebar-group:first-child').styles(
    margin: .only(top: 0.px, bottom: 8.px),
  ),
  css('.md-sidebar ul').styles(listStyle: ListStyle.none),
  css('.md-sidebar a').styles(
    display: Display.block,
    padding: .symmetric(vertical: 6.px, horizontal: 10.px),
    color: AppColors.inkMuted,
    textDecoration: TextDecoration.none,
    radius: BorderRadius.circular(6.px),
  ),
  css('.md-sidebar a:hover').styles(color: AppColors.ink),
  css('.md-sidebar a.active').styles(
    color: AppColors.cyan,
    backgroundColor: AppColors.cyanGlow,
  ),

  css('.md-content').styles(
    fontSize: 1.rem,
    lineHeight: 1.7.em,
    color: AppColors.inkMuted,
  ),
  css('.md-eyebrow').styles(
    display: Display.block,
    margin: .only(bottom: 8.px),
    fontSize: 0.88.rem,
    fontWeight: FontWeight.w600,
    color: AppColors.cyan,
  ),
  css('.md-content h1').styles(
    fontFamily: const .list([FontFamily('Space Grotesk'), FontFamilies.sansSerif]),
    fontSize: 2.3.rem,
    lineHeight: 1.2.em,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  ),
  css('.md-lead').styles(
    margin: .only(top: 12.px, bottom: 28.px),
    fontSize: 1.25.rem,
    lineHeight: 1.55.em,
    color: AppColors.inkMuted,
  ),
  css('.md-content h2').styles(
    margin: .only(top: 48.px, bottom: 12.px),
    fontFamily: const .list([FontFamily('Space Grotesk'), FontFamilies.sansSerif]),
    fontSize: 1.5.rem,
    lineHeight: 1.3.em,
    color: AppColors.ink,
    raw: {'scroll-margin-top': 'calc(var(--docs-header-h) + 16px)'},
  ),
  css('.md-content h3').styles(
    margin: .only(top: 32.px, bottom: 8.px),
    fontSize: 1.15.rem,
    color: AppColors.ink,
  ),
  // jaspr_content wraps the body in <section class="content">; undo the
  // landing's section padding.
  css('.md-content section.content').styles(padding: .zero),
  css('.md-content p').styles(margin: .only(bottom: 16.px)),
  css('.md-content a').styles(color: AppColors.cyan),
  css('.md-content ul, .md-content ol').styles(
    margin: .only(bottom: 16.px),
    padding: .only(left: 22.px),
  ),
  css('.md-content li').styles(margin: .only(bottom: 6.px)),
  css('.md-content strong').styles(color: AppColors.ink),
  css('.md-content :not(pre) > code').styles(
    padding: .symmetric(horizontal: 6.px, vertical: 1.px),
    fontSize: 0.88.em,
    color: AppColors.ink,
    backgroundColor: AppColors.surfaceElevated,
    radius: BorderRadius.circular(4.px),
  ),
  css('.md-code').styles(
    margin: .only(bottom: 20.px),
    padding: .symmetric(vertical: 16.px, horizontal: 18.px),
    fontSize: 0.85.rem,
    lineHeight: 1.6.em,
    color: AppColors.ink,
    backgroundColor: AppColors.surface,
    border: Border.all(color: AppColors.border, width: 1.px),
    radius: BorderRadius.circular(6.px),
    overflow: Overflow.only(x: Overflow.auto),
  ),
  css('.md-content .code-tabs-box, .md-content .pack-demo').styles(margin: .only(bottom: 24.px)),
  css('.md-content table').styles(
    width: 100.percent,
    margin: .only(bottom: 20.px),
    fontSize: 0.95.rem,
    raw: {'border-collapse': 'collapse'},
  ),
  css('.md-content th, .md-content td').styles(
    padding: .symmetric(vertical: 10.px, horizontal: 12.px),
    textAlign: TextAlign.left,
    border: Border.only(
      bottom: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
  ),
  css('.md-content th').styles(color: AppColors.ink, fontWeight: FontWeight.w600),

  css('.md-note').styles(
    margin: .only(bottom: 20.px),
    padding: .symmetric(vertical: 14.px, horizontal: 18.px),
    backgroundColor: AppColors.surface,
    border: Border.only(
      left: BorderSide.solid(color: AppColors.cyan, width: 3.px),
    ),
    radius: BorderRadius.circular(4.px),
  ),
  css('.md-note > :last-child').styles(margin: .only(bottom: 0.px)),

  css('.md-page-footer').styles(
    margin: .only(top: 56.px),
    padding: .only(top: 24.px),
    border: Border.only(
      top: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
  ),
  css('.md-pager').styles(
    display: Display.flex,
    justifyContent: JustifyContent.spaceBetween,
    gap: Gap(column: 16.px),
  ),
  css('.md-pager-link').styles(
    display: Display.flex,
    flexDirection: FlexDirection.column,
    gap: Gap(row: 2.px),
    padding: .symmetric(vertical: 12.px, horizontal: 16.px),
    border: Border.all(color: AppColors.border, width: 1.px),
    radius: BorderRadius.circular(6.px),
    textDecoration: TextDecoration.none,
    raw: {'flex': '1', 'max-width': '50%'},
  ),
  css('.md-pager-link:hover').styles(
    border: Border.all(color: AppColors.cyan, width: 1.px),
  ),
  css('.md-pager-link.next').styles(alignItems: AlignItems.end, raw: {'margin-left': 'auto'}),
  css('.md-pager-label').styles(fontSize: 0.8.rem, color: AppColors.inkMuted),
  css('.md-pager-title').styles(color: AppColors.cyan, fontWeight: FontWeight.w600),
  css('.md-edit').styles(
    display: Display.inlineBlock,
    margin: .only(top: 20.px),
    fontSize: 0.85.rem,
    color: AppColors.inkMuted,
  ),

  css('.md-toc-mobile').styles(display: Display.none),

  css('.md-toc ul').styles(
    listStyle: ListStyle.none,
    padding: .only(left: 12.px),
    border: Border.only(
      left: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
  ),
  css('.md-toc li').styles(margin: .only(bottom: 8.px)),
  css('.md-toc a').styles(
    fontSize: 0.85.rem,
    color: AppColors.inkMuted,
    textDecoration: TextDecoration.none,
  ),
  css('.md-toc a:hover').styles(color: AppColors.cyan),

  ContainerStyleRule('(max-width: 48rem)', [
    css('.md-toc-mobile').styles(
      display: Display.block,
      margin: .only(bottom: 24.px),
      padding: .symmetric(vertical: 10.px, horizontal: 14.px),
      border: Border.all(color: AppColors.border, width: 1.px),
      radius: BorderRadius.circular(6.px),
      fontSize: 0.92.rem,
    ),
    css('.md-toc-mobile summary').styles(color: AppColors.ink, cursor: Cursor.pointer),
    css('.md-toc-mobile ul').styles(
      listStyle: ListStyle.none,
      margin: .only(top: 8.px),
      padding: .zero,
    ),
    css('.md-toc-mobile a').styles(color: AppColors.inkMuted, textDecoration: TextDecoration.none),
  ]),
  // At md the sidebar becomes a drawer from the left, opened from the
  // header's tab row (html.docs-menu-open).
  css.media(MediaQuery.screen(maxWidth: 768.px), [
    css('.md-sidebar').styles(width: 0.px),
    css('.md-backdrop').styles(
      display: Display.block,
      position: Position.fixed(top: 0.px, left: 0.px, right: 0.px, bottom: 0.px),
      zIndex: ZIndex(1150),
      backgroundColor: Color('rgba(0, 0, 0, 0.55)'),
      raw: {'visibility': 'hidden', 'opacity': '0', 'transition': 'opacity 0.2s, visibility 0.2s'},
    ),
    css('.md-sidebar-panel').styles(
      position: Position.fixed(top: 0.px, left: 0.px, bottom: 0.px),
      zIndex: ZIndex(1200),
      width: 80.percent,
      maxWidth: 300.px,
      height: Unit.expression('100svh'),
      padding: .all(20.px),
      backgroundColor: AppColors.bg,
      border: Border.only(
        right: BorderSide.solid(color: AppColors.border, width: 1.px),
      ),
      transform: Transform.translate(x: (-105).percent),
      transition: const Transition('transform', duration: Duration(milliseconds: 200)),
    ),
    css('html.docs-menu-open .md-backdrop').styles(raw: {'visibility': 'visible', 'opacity': '1'}),
    css('html.docs-menu-open .md-sidebar-panel').styles(transform: Transform.translate(x: 0.percent)),
  ]),
];
