import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../icons.dart';

const _repo = 'https://github.com/iamv4g/keyed_form';

/// The footer at the bottom of the docs and playground column: project
/// links on the left, icon links on the right.
class DocsFooter extends StatelessComponent {
  const DocsFooter({super.key});

  @override
  Component build(BuildContext context) {
    return footer(classes: 'docs-footer', [
      p(classes: 'docs-footer-text mono', [
        .text('keyed_form · '),
        a(href: '$_repo/blob/main/LICENSE', target: Target.blank, [.text('MIT License')]),
        .text(' · '),
        a(href: '$_repo/blob/main/packages/keyed_form_flutter/CHANGELOG.md', target: Target.blank, [
          .text('Changelog'),
        ]),
        .text(' · '),
        a(href: '$_repo/issues', target: Target.blank, [.text('Issues')]),
      ]),
      div(classes: 'docs-footer-icons', [
        a(
          classes: 'header-icon-button',
          href: _repo,
          target: Target.blank,
          attributes: {'aria-label': 'GitHub', 'title': 'GitHub'},
          [SiteIcons.github(size: 16)],
        ),
        a(
          classes: 'header-icon-button',
          href: 'https://pub.dev/packages/keyed_form_flutter',
          target: Target.blank,
          attributes: {'aria-label': 'pub.dev', 'title': 'pub.dev'},
          [SiteIcons.dart(size: 16)],
        ),
        // CSS shows the variant matching the theme.
        a(
          classes: 'jaspr-badge',
          href: 'https://jaspr.site',
          target: Target.blank,
          attributes: {'aria-label': 'Built with Jaspr'},
          [
            span(classes: 'jaspr-badge-light', [const JasprBadge.lightTwoTone()]),
            span(classes: 'jaspr-badge-dark', [const JasprBadge.darkTwoTone()]),
          ],
        ),
      ]),
    ]);
  }
}
