import 'package:jaspr/dom.dart';

import 'theme_tokens.dart';

/// Markdown docs pages (`content/docs/`): one idea per page, plain type.
@css
List<StyleRule> get markdownStyles => [
  css('.md-sidebar').styles(fontSize: 0.92.rem),
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
    maxWidth: 760.px,
    fontSize: 1.08.rem,
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
    raw: {'scroll-margin-top': '88px'},
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
  css('.md-drawer-footer').styles(display: Display.none),

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

  css.media(MediaQuery.screen(maxWidth: 992.px), [
    css('.md-layout').styles(raw: {'grid-template-columns': 'minmax(0, 1fr)'}),
    css('.md-content').styles(fontSize: 1.rem),
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
  // Phones: the navbar keeps only the brand and ☰; Playground and the
  // icon links move to the drawer's footer.
  css.media(MediaQuery.screen(maxWidth: 600.px), [
    css('.docs-page .nav-links > :not(.navbar-docs-toggle)').styles(display: Display.none),
    css('.md-drawer-footer').styles(
      display: Display.flex,
      alignItems: AlignItems.center,
      gap: Gap(column: 14.px),
      margin: .only(top: Unit.auto),
      padding: .only(top: 16.px),
      border: Border.only(
        top: BorderSide.solid(color: AppColors.border, width: 1.px),
      ),
    ),
    css('.md-drawer-footer .md-drawer-playground').styles(
      color: AppColors.ink,
      textDecoration: TextDecoration.none,
      raw: {'margin-right': 'auto'},
    ),
  ]),
];
