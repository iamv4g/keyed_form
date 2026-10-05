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
  // Stretch to the article's height: the sticky panel inside can only travel
  // within this column, so a shrink-wrapped column scrolls away with the page.
  css('.md-sidebar').styles(
    width: Unit.expression('var(--sidebar-width)'),
    fontSize: 0.875.rem,
    raw: {'flex': 'none', 'align-self': 'stretch'},
  ),
  css('.md-sidebar-panel').styles(
    display: Display.flex,
    position: Position.sticky(top: Unit.expression('var(--docs-header-h)')),
    height: Unit.expression('calc(100svh - var(--docs-header-h))'),
    flexDirection: FlexDirection.column,
  ),
  css('.md-sidebar-scroll').styles(
    minHeight: 0.px,
    padding: .only(top: 32.px, bottom: 32.px, left: 8.px),
    overflow: Overflow.only(y: Overflow.auto),
    raw: {'flex': '1', 'scrollbar-width': 'none'},
  ),
  css('.md-sidebar-scroll::-webkit-scrollbar').styles(display: Display.none),
  // The list fades out under the header and at the bottom edge.
  css('.md-sidebar-fade').styles(
    position: Position.absolute(left: 0.px, right: 0.px),
    zIndex: ZIndex(1),
    height: 48.px,
    pointerEvents: PointerEvents.none,
  ),
  css('.md-sidebar-fade.top').styles(
    position: Position.absolute(top: 0.px),
    raw: {'background': 'linear-gradient(to bottom, var(--bg), transparent)'},
  ),
  css('.md-sidebar-fade.bottom').styles(
    position: Position.absolute(bottom: 0.px),
    raw: {'background': 'linear-gradient(to top, var(--bg), transparent)'},
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
    padding: .only(top: 40.px, left: 24.px, right: 24.px),
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
  css('.md-sidebar ul').styles(listStyle: ListStyle.none),
  css('.md-sidebar a').styles(textDecoration: TextDecoration.none),
  css('.md-sidebar-links').styles(
    display: Display.flex,
    padding: .only(left: 8.px),
    flexDirection: FlexDirection.column,
    gap: Gap(row: 12.px),
  ),
  css('.md-sidebar-link').styles(
    display: Display.flex,
    alignItems: AlignItems.center,
    gap: Gap(column: 8.px),
    color: AppColors.ink,
  ),
  css('.md-sidebar-icon').styles(
    display: Display.inlineFlex,
    width: 28.px,
    height: 28.px,
    alignItems: AlignItems.center,
    justifyContent: JustifyContent.center,
    border: Border.all(color: AppColors.border, width: 1.px),
    radius: BorderRadius.circular(8.px),
    raw: {'flex': 'none', 'background-color': 'var(--control-bg)', 'border-color': 'var(--control-border)'},
  ),
  css('.md-sidebar-link:hover .md-sidebar-icon').styles(backgroundColor: AppColors.surfaceElevated),
  css('.md-separator, .md-group-separator').styles(height: 1.px, backgroundColor: AppColors.border),
  css('.md-separator').styles(margin: .symmetric(vertical: 16.px)),
  css('.md-group-separator').styles(margin: .only(bottom: 16.px)),
  css('.md-group').styles(padding: .all(8.px)),
  css('.md-group-label').styles(
    display: Display.flex,
    height: 32.px,
    padding: .symmetric(horizontal: 8.px),
    margin: .only(bottom: 4.px),
    alignItems: AlignItems.center,
    color: AppColors.ink,
    opacity: 0.7,
    fontSize: 0.75.rem,
    fontWeight: FontWeight.w500,
  ),
  css('.md-group-items').styles(
    display: Display.flex,
    flexDirection: FlexDirection.column,
    gap: Gap(row: 4.px),
  ),
  css('.md-sidebar-item').styles(
    display: Display.flex,
    minHeight: 32.px,
    padding: .all(8.px),
    alignItems: AlignItems.center,
    gap: Gap(column: 8.px),
    radius: BorderRadius.circular(8.px),
    color: AppColors.inkMuted,
    fontSize: 0.875.rem,
    lineHeight: 1.25.rem,
  ),
  css('.md-sidebar-item svg').styles(raw: {'flex': 'none'}),
  css('.md-sidebar-item:hover, .md-sidebar-item.active').styles(
    color: AppColors.ink,
    backgroundColor: AppColors.surfaceElevated,
  ),
  css('.md-sidebar-item.active').styles(fontWeight: FontWeight.w500),

  css('.md-content').styles(
    fontSize: 1.rem,
    lineHeight: 1.75.em,
    color: AppColors.ink,
  ),
  // Title row: the page title with Copy page on its right, then the
  // description.
  css('.docs-page-header').styles(margin: .only(bottom: 32.px)),
  css('.docs-title-row').styles(
    display: Display.flex,
    alignItems: AlignItems.center,
    gap: Gap(column: 16.px),
  ),
  css('.md-content h1').styles(
    fontFamily: const .list([FontFamily('Space Grotesk'), FontFamilies.sansSerif]),
    fontSize: 1.875.rem,
    lineHeight: 1.2.em,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    raw: {'flex': '1', 'min-width': '0'},
  ),
  css.media(MediaQuery.screen(minWidth: 768.px), [
    css('.md-content h1').styles(fontSize: 2.25.rem),
  ]),
  css('.docs-description').styles(
    margin: .only(top: 8.px),
    fontSize: 1.125.rem,
    lineHeight: 1.75.rem,
    color: AppColors.inkMuted,
  ),
  css('.copy-page').styles(position: Position.relative(), raw: {'flex': 'none'}),
  // One outlined block: each button is fully rounded, the group trims the
  // inner corners and the shared border.
  css('.copy-page-group').styles(display: Display.flex, alignItems: AlignItems.stretch),
  css('.copy-page-button').styles(
    display: Display.inlineFlex,
    height: 32.px,
    padding: .symmetric(horizontal: 10.px),
    alignItems: AlignItems.center,
    gap: Gap(column: 8.px),
    border: Border.all(color: AppColors.border, width: 1.px),
    radius: BorderRadius.circular(8.px),
    cursor: Cursor.pointer,
    color: AppColors.ink,
    fontFamily: const .list([FontFamily('Inter'), FontFamilies.sansSerif]),
    fontSize: 0.875.rem,
    fontWeight: FontWeight.w500,
    whiteSpace: WhiteSpace.noWrap,
    raw: {'flex': 'none', 'background-color': 'var(--control-bg)', 'border-color': 'var(--control-border)'},
  ),
  css('.copy-page-group > :not(:first-child)').styles(
    raw: {'border-top-left-radius': '0', 'border-bottom-left-radius': '0', 'border-left-width': '0'},
  ),
  css('.copy-page-group > :not(:last-child)').styles(
    raw: {'border-top-right-radius': '0', 'border-bottom-right-radius': '0'},
  ),
  css('.copy-page-trigger').styles(
    padding: .only(left: 8.px, right: 10.px),
  ),
  css('.copy-page-button:hover, .copy-page-trigger[aria-expanded="true"]').styles(
    raw: {'background-color': 'var(--surface-elevated)'},
  ),
  css('.copy-page-menu').styles(
    display: Display.flex,
    position: Position.absolute(top: Unit.expression('calc(100% + 4px)'), right: 0.px),
    zIndex: ZIndex(50),
    minWidth: 200.px,
    padding: .all(4.px),
    flexDirection: FlexDirection.column,
    border: Border.all(color: AppColors.border, width: 1.px),
    radius: BorderRadius.circular(10.px),
    backgroundColor: AppColors.bg,
    raw: {'box-shadow': 'var(--card-shadow)'},
  ),
  css('.md-content .copy-page-item').styles(
    display: Display.flex,
    height: 32.px,
    padding: .symmetric(horizontal: 8.px),
    alignItems: AlignItems.center,
    gap: Gap(column: 8.px),
    radius: BorderRadius.circular(6.px),
    color: AppColors.ink,
    fontSize: 0.875.rem,
    textDecoration: TextDecoration.none,
    whiteSpace: WhiteSpace.noWrap,
  ),
  css('.md-content .copy-page-item:hover').styles(backgroundColor: AppColors.surfaceElevated),
  css.media(MediaQuery.screen(maxWidth: 767.px), [
    css('.copy-page-label').styles(display: Display.none),
  ]),
  css('.md-content h2').styles(
    margin: .only(top: 16.px, bottom: 16.px),
    padding: .only(top: 32.px),
    fontFamily: const .list([FontFamily('Space Grotesk'), FontFamilies.sansSerif]),
    fontSize: 1.875.rem,
    lineHeight: 1.2.em,
    color: AppColors.ink,
  ),
  css('.md-content h3').styles(
    margin: .only(top: 32.px, bottom: 12.px),
    fontFamily: const .list([FontFamily('Space Grotesk'), FontFamilies.sansSerif]),
    fontSize: 1.25.rem,
    lineHeight: 1.3.em,
    color: AppColors.ink,
  ),
  css('.md-content :is(h2, h3)[id]').styles(raw: {'scroll-margin-top': 'var(--docs-header-h)'}),
  // `#` beside h2/h3, shown on hover or focus.
  css('.md-heading').styles(
    display: Display.flex,
    alignItems: AlignItems.center,
    gap: Gap(column: 12.px),
  ),
  css('.md-content .md-anchor').styles(
    display: Display.inlineFlex,
    width: 24.px,
    height: 24.px,
    alignItems: AlignItems.center,
    justifyContent: JustifyContent.center,
    opacity: 0,
    border: Border.all(color: AppColors.border, width: 1.px),
    radius: BorderRadius.circular(6.px),
    color: AppColors.inkMuted,
    fontFamily: const .list([FontFamily('Inter'), FontFamilies.sansSerif]),
    fontSize: 0.875.rem,
    fontWeight: FontWeight.w500,
    textDecoration: TextDecoration.none,
    transition: const Transition('opacity', duration: Duration(milliseconds: 150)),
    raw: {'flex': 'none', 'background-color': 'var(--control-bg)', 'border-color': 'var(--control-border)'},
  ),
  css('.md-heading:hover .md-anchor, .md-content .md-anchor:focus-visible').styles(opacity: 1),
  css('.md-content .md-anchor:hover').styles(color: AppColors.ink),
  // jaspr_content wraps the body in <section class="content">; undo the
  // landing's section padding.
  css('.md-content section.content').styles(padding: .zero),
  css('.md-content p').styles(margin: .only(bottom: 16.px), opacity: 0.9),
  css('.md-content a').styles(
    color: AppColors.cyan,
    fontWeight: FontWeight.w500,
    raw: {'text-underline-offset': '4px'},
  ),
  css('.md-content a:hover').styles(opacity: 0.8),
  css('.md-content ul, .md-content ol').styles(
    margin: .symmetric(vertical: 16.px),
    padding: .only(left: 24.px),
  ),
  css('.md-content li').styles(margin: .only(top: 8.px)),
  css('.md-content strong').styles(color: AppColors.ink),
  css('.md-content :not(pre) > code').styles(
    padding: .symmetric(horizontal: 6.px, vertical: 2.px),
    fontSize: 0.875.em,
    color: AppColors.ink,
    backgroundColor: AppColors.surfaceElevated,
    radius: BorderRadius.circular(6.px),
  ),
  // Code block: language + copy in a caption bar over the code.
  css('.md-codeblock').styles(
    margin: .symmetric(vertical: 24.px),
    border: Border.all(color: AppColors.border, width: 1.px),
    radius: BorderRadius.circular(8.px),
    overflow: Overflow.hidden,
    backgroundColor: AppColors.surface,
  ),
  css('.md-codeblock-bar').styles(
    display: Display.flex,
    height: 36.px,
    padding: .only(left: 16.px, right: 6.px),
    alignItems: AlignItems.center,
    justifyContent: JustifyContent.spaceBetween,
    border: Border.only(
      bottom: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
  ),
  css('.md-codeblock-lang').styles(fontSize: 0.75.rem, color: AppColors.inkMuted),
  css('.md-codeblock-copy').styles(
    height: 26.px,
    padding: .symmetric(horizontal: 8.px),
    border: Border.unset,
    radius: BorderRadius.circular(6.px),
    cursor: Cursor.pointer,
    color: AppColors.inkMuted,
    fontFamily: const .list([FontFamily('Inter'), FontFamilies.sansSerif]),
    fontSize: 0.75.rem,
    fontWeight: FontWeight.w500,
    backgroundColor: Colors.transparent,
  ),
  css('.md-codeblock-copy:hover').styles(color: AppColors.ink, backgroundColor: AppColors.surfaceElevated),
  css('.md-code').styles(
    margin: .zero,
    padding: .symmetric(vertical: 12.px, horizontal: 16.px),
    fontSize: 0.875.rem,
    lineHeight: 1.6.em,
    color: AppColors.ink,
    overflow: Overflow.only(x: Overflow.auto),
  ),
  css('.md-content .code-tabs-box').styles(radius: BorderRadius.circular(8.px)),
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

  // Previous / next: secondary buttons at the end of the article.
  css('.md-pager').styles(
    display: Display.flex,
    margin: .only(top: 48.px),
    justifyContent: JustifyContent.spaceBetween,
    gap: Gap(column: 16.px),
  ),
  css('.md-content .md-pager-link').styles(
    display: Display.inlineFlex,
    height: 32.px,
    padding: .symmetric(horizontal: 10.px),
    alignItems: AlignItems.center,
    gap: Gap(column: 6.px),
    radius: BorderRadius.circular(10.px),
    color: AppColors.ink,
    backgroundColor: AppColors.surfaceElevated,
    fontSize: 0.875.rem,
    fontWeight: FontWeight.w500,
    textDecoration: TextDecoration.none,
  ),
  css('.md-content .md-pager-link:hover').styles(opacity: 0.8),
  css('.md-pager-link.next').styles(raw: {'margin-left': 'auto'}),

  // Footer inside the article column.
  css('.docs-footer').styles(
    display: Display.flex,
    margin: .only(top: 48.px),
    padding: .symmetric(vertical: 48.px),
    flexWrap: FlexWrap.wrap,
    alignItems: AlignItems.center,
    justifyContent: JustifyContent.spaceBetween,
    gap: Gap(row: 16.px, column: 16.px),
    backgroundColor: Colors.transparent,
    border: Border.only(
      top: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
  ),
  css('.docs-footer .docs-footer-text').styles(
    margin: .zero,
    fontSize: 0.8.rem,
    color: AppColors.inkMuted,
    opacity: 1,
  ),
  css('.docs-footer .docs-footer-text a').styles(
    color: AppColors.inkMuted,
    fontWeight: FontWeight.w400,
    textDecoration: TextDecoration.none,
  ),
  css('.docs-footer .docs-footer-text a:hover').styles(color: AppColors.ink),
  css('.docs-footer-icons').styles(
    display: Display.flex,
    alignItems: AlignItems.center,
    gap: Gap(column: 4.px),
  ),
  css('.docs-footer .header-icon-button').styles(color: AppColors.ink),
  css('.docs-footer-icons .jaspr-badge').styles(margin: .only(left: 8.px)),

  // On this page: a left rule, the section being read marked on it.
  css('.md-toc').styles(
    listStyle: ListStyle.none,
    border: Border.only(
      left: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
  ),
  css('.md-toc-link').styles(
    display: Display.block,
    padding: .only(top: 4.px, bottom: 4.px, left: 12.px),
    margin: .only(left: (-1).px),
    border: Border.only(
      left: BorderSide.solid(color: Colors.transparent, width: 1.px),
    ),
    color: AppColors.inkMuted,
    fontSize: 0.875.rem,
    lineHeight: 1.25.rem,
    textDecoration: TextDecoration.none,
    transition: const Transition('color', duration: Duration(milliseconds: 150)),
  ),
  css('.md-toc-link.nested').styles(padding: .only(left: 24.px)),
  css('.md-toc-link:hover').styles(color: AppColors.ink),
  css('.md-toc-link.active').styles(
    color: AppColors.ink,
    raw: {'border-left-color': 'var(--cyan)'},
  ),
  // At md the sidebar becomes a drawer from the left, opened from the
  // header's tab row (html.docs-menu-open): 75% wide (24rem cap from sm),
  // fading in over a light, blurred backdrop.
  css.media(MediaQuery.screen(maxWidth: 768.px), [
    css('.md-sidebar').styles(width: 0.px),
    css('.md-backdrop').styles(
      display: Display.block,
      position: Position.fixed(top: 0.px, left: 0.px, right: 0.px, bottom: 0.px),
      zIndex: ZIndex(1150),
      backgroundColor: Color('rgba(0, 0, 0, 0.1)'),
      raw: {
        'backdrop-filter': 'blur(4px)',
        '-webkit-backdrop-filter': 'blur(4px)',
        'visibility': 'hidden',
        'opacity': '0',
        'transition': 'opacity 0.2s ease-in-out, visibility 0.2s ease-in-out',
      },
    ),
    css('.md-sidebar-panel').styles(
      position: Position.fixed(top: 0.px, left: 0.px, bottom: 0.px),
      zIndex: ZIndex(1200),
      width: 75.percent,
      height: Unit.expression('100svh'),
      backgroundColor: AppColors.bg,
      border: Border.only(
        right: BorderSide.solid(color: AppColors.border, width: 1.px),
      ),
      transform: Transform.translate(x: (-2.5).rem),
      raw: {
        'box-shadow': '0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)',
        'visibility': 'hidden',
        'opacity': '0',
        'transition': 'opacity 0.2s ease-in-out, transform 0.2s ease-in-out, visibility 0.2s ease-in-out',
      },
    ),
    css('html.docs-menu-open .md-backdrop').styles(raw: {'visibility': 'visible', 'opacity': '1'}),
    css('html.docs-menu-open .md-sidebar-panel').styles(
      transform: Transform.translate(x: 0.px),
      raw: {'visibility': 'visible', 'opacity': '1'},
    ),
  ]),
  css.media(MediaQuery.screen(minWidth: 640.px, maxWidth: 768.px), [
    css('.md-sidebar-panel').styles(maxWidth: 24.rem),
  ]),
];
