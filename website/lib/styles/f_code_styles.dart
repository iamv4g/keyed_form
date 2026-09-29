import 'package:jaspr/dom.dart';

import '../code/code_tabs.dart';
import 'theme_tokens.dart';

/// Styles for [CodeTabs] and the `tk-*` token classes.
@css
List<StyleRule> get codeStyles => [
  css('.code-tabs-box').styles(
    position: Position.relative(),
    backgroundColor: AppColors.surface,
    border: Border.all(color: AppColors.border, width: 1.px),
    radius: BorderRadius.circular(6.px),
    overflow: Overflow.hidden,
    minWidth: 0.px,
  ),

  // Hidden but focusable: arrow keys switch tabs.
  css('.code-tab-input').styles(
    position: Position.absolute(),
    opacity: 0,
    pointerEvents: PointerEvents.none,
  ),

  css('.code-tabs-bar').styles(
    display: Display.flex,
    backgroundColor: AppColors.surfaceElevated,
    border: Border.only(
      bottom: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
    overflow: Overflow.only(x: Overflow.auto),
    raw: {'scrollbar-width': 'none'},
  ),
  css('.code-tab-label').styles(
    padding: .symmetric(vertical: 10.px, horizontal: 14.px),
    fontSize: 0.76.rem,
    color: AppColors.inkMuted,
    cursor: Cursor.pointer,
    whiteSpace: WhiteSpace.noWrap,
    border: Border.only(
      bottom: BorderSide.solid(color: Colors.transparent, width: 2.px),
    ),
    transition: const Transition('color', duration: Duration(milliseconds: 120)),
  ),
  css('.code-tab-label:hover').styles(color: AppColors.ink),

  css('.code-tab-panel').styles(
    display: Display.none,
    position: Position.relative(),
  ),
  css('.code-tab-panel .copy-btn').styles(
    position: Position.absolute(top: 10.px, right: 10.px),
    zIndex: ZIndex(1),
  ),
  css('.code-tab-pre').styles(
    margin: .zero,
    padding: .only(top: 18.px, bottom: 18.px, left: 20.px, right: 84.px),
    fontSize: 0.8.rem,
    lineHeight: 1.6.em,
    color: AppColors.ink,
    overflow: Overflow.only(x: Overflow.auto),
    raw: {'white-space': 'pre', 'tab-size': '2'},
  ),

  css('.code-tabs-caption').styles(
    padding: .symmetric(vertical: 12.px, horizontal: 16.px),
    fontSize: 0.78.rem,
    lineHeight: 1.5.em,
    color: AppColors.inkMuted,
    border: Border.only(
      top: BorderSide.solid(color: AppColors.border, width: 1.px),
    ),
  ),
  css('.code-tabs-caption a').styles(color: AppColors.cyan),

  for (var i = 1; i <= CodeTabs.maxTabs; i++) ...[
    css('.code-tab-input:nth-of-type($i):checked ~ .code-tab-panels .code-tab-panel:nth-child($i)').styles(
      display: Display.block,
    ),
    css('.code-tab-input:nth-of-type($i):checked ~ .code-tabs-bar .code-tab-label:nth-child($i)').styles(
      color: AppColors.ink,
      border: Border.only(
        bottom: BorderSide.solid(color: AppColors.cyan, width: 2.px),
      ),
    ),
    css('.code-tab-input:nth-of-type($i):focus-visible ~ .code-tabs-bar .code-tab-label:nth-child($i)').styles(
      raw: {'outline': '2px solid var(--cyan)', 'outline-offset': '-2px'},
    ),
  ],

  // Tokens
  css('.tk-keyword').styles(color: AppColors.cyan),
  css('.tk-type').styles(color: AppColors.amber),
  css('.tk-string').styles(color: AppColors.green),
  css('.tk-number').styles(color: AppColors.amber),
  css('.tk-annotation').styles(color: AppColors.amber),
  css('.tk-function').styles(raw: {'color': 'color-mix(in srgb, var(--cyan) 55%, var(--ink))'}),
  css('.tk-comment').styles(color: AppColors.inkMuted, fontStyle: FontStyle.italic),

  css.media(MediaQuery.screen(maxWidth: 768.px), [
    css('.code-tab-pre').styles(
      fontSize: 0.74.rem,
      padding: .only(top: 44.px, bottom: 16.px, left: 14.px, right: 14.px),
    ),
  ]),
];
