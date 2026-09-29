import 'package:jaspr/dom.dart';

import 'theme_tokens.dart';

/// Markdown docs pages (`content/docs/`): one idea per page, plain type.
@css
List<StyleRule> get markdownStyles => [
  css('.md-sidebar').styles(
    position: Position.sticky(top: 88.px),
    alignSelf: AlignSelf.start,
    fontSize: 0.92.rem,
  ),
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
    margin: .only(top: 12.px, bottom: 36.px),
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
    css('.md-sidebar').styles(display: Display.none),
    css('.md-content').styles(fontSize: 1.rem),
  ]),
];
