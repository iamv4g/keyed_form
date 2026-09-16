import 'package:jaspr/dom.dart';

import 'theme_tokens.dart';

/// Styles for the /playground page — the live KeyedFormController demo.
@css
List<StyleRule> get playgroundStyles => [
  css('.playground-page').styles(
    padding: .only(top: 56.px, bottom: 72.px),
  ),

  css('.playground-grid').styles(
    display: Display.grid,
    gap: Gap(column: 28.px, row: 28.px),
    margin: .only(top: 36.px),
    raw: {
      'grid-template-columns': 'minmax(0, 1.1fr) minmax(0, 1fr)',
    },
  ),

  css('.playground-form').styles(
    padding: .all(24.px),
    radius: BorderRadius.circular(4.px),
  ),
  css('.playground-observers').styles(
    display: Display.flex,
    flexDirection: FlexDirection.column,
    gap: Gap(row: 16.px),
  ),

  css('.playground-panel-title').styles(
    fontSize: 0.74.rem,
    letterSpacing: 0.08.em,
    color: AppColors.cyan,
    margin: .only(bottom: 16.px),
  ),

  css('.playground-field').styles(
    margin: .only(bottom: 20.px),
  ),
  css('.playground-field-label').styles(
    display: Display.flex,
    justifyContent: JustifyContent.spaceBetween,
    alignItems: AlignItems.center,
    fontSize: 0.82.rem,
    color: AppColors.inkMuted,
    margin: .only(bottom: 6.px),
  ),
  css('.playground-rebuild-badge').styles(
    fontSize: 0.68.rem,
    padding: .symmetric(vertical: 2.px, horizontal: 7.px),
    backgroundColor: AppColors.cyanGlow,
    color: AppColors.cyan,
    radius: BorderRadius.circular(2.px),
  ),
  css('.playground-input').styles(
    width: 100.percent,
    padding: .symmetric(vertical: 9.px, horizontal: 12.px),
    fontSize: 0.92.rem,
    backgroundColor: AppColors.surfaceElevated,
    border: Border.all(color: AppColors.border, width: 1.px),
    color: AppColors.ink,
    radius: BorderRadius.circular(3.px),
    raw: {'outline': 'none'},
  ),
  css('.playground-input:focus').styles(
    border: Border.all(color: AppColors.cyan, width: 1.px),
  ),
  css('.playground-field-error').styles(
    margin: .only(top: 6.px),
    fontSize: 0.78.rem,
    color: AppColors.red,
  ),

  css('.playground-segmented').styles(
    display: Display.flex,
    gap: Gap(column: 8.px),
  ),
  css('.playground-segment').styles(
    padding: .symmetric(vertical: 8.px, horizontal: 16.px),
    backgroundColor: AppColors.surfaceElevated,
    border: Border.all(color: AppColors.border, width: 1.px),
    color: AppColors.inkMuted,
    fontSize: 0.85.rem,
    cursor: Cursor.pointer,
    radius: BorderRadius.circular(3.px),
    transition: const Transition('all', duration: Duration(milliseconds: 120)),
  ),
  css('.playground-segment.active').styles(
    backgroundColor: AppColors.cyanGlow,
    border: Border.all(color: AppColors.cyan, width: 1.px),
    color: AppColors.cyan,
    fontWeight: FontWeight.w600,
  ),

  css('.playground-panel').styles(
    padding: .all(20.px),
    radius: BorderRadius.circular(4.px),
  ),
  css('.playground-panel-body').styles(
    margin: .zero,
    fontSize: 0.8.rem,
    lineHeight: 1.5.em,
    color: AppColors.ink,
    overflow: Overflow.only(x: Overflow.auto),
    raw: {'white-space': 'pre'},
  ),

  css('.playground-notifications').styles(
    fontSize: 0.78.rem,
    lineHeight: 1.5.em,
    color: AppColors.inkMuted,
    padding: .symmetric(vertical: 12.px, horizontal: 4.px),
  ),

  css.media(MediaQuery.screen(maxWidth: 900.px), [
    css('.playground-grid').styles(
      raw: {'grid-template-columns': '1fr'},
    ),
  ]),
];
