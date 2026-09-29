import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../base_path.dart';
import 'brand_mark.dart';

const _repo = 'https://github.com/iamv4g/keyed_form';

class Footer extends StatelessComponent {
  const Footer({super.key});

  @override
  Component build(BuildContext context) {
    return footer([
      div(classes: 'wrap', [
        div(classes: 'footer-grid', [
          div(classes: 'footer-brand', [
            a(classes: 'brand display', href: '$siteBasePath/', [const BrandMark(), .text('keyed_form')]),
            p([.text('Typed Flutter forms, one rebuild per keystroke.')]),
          ]),
          _column('Project', [
            _link('pub.dev', 'https://pub.dev/packages/keyed_form_flutter', external: true),
            _link('GitHub', _repo, external: true),
            _link('Changelog', '$_repo/blob/main/packages/keyed_form_flutter/CHANGELOG.md', external: true),
            _link('Issues', '$_repo/issues', external: true),
            _link('API reference', 'https://pub.dev/documentation/keyed_form_flutter/latest/', external: true),
          ]),
          _column('Docs', [
            _link('Quickstart', '$siteBasePath/docs#quickstart'),
            _link('Dynamic lists', '$siteBasePath/docs#virtualization'),
            _link('Validation', '$siteBasePath/docs#validation'),
            _link('Testing', '$siteBasePath/docs#testing-without-widgets'),
            _link('Benchmarks', '$siteBasePath/docs#benchmarks-methodology'),
          ]),
          _column('Resources', [
            _link('Playground', '$siteBasePath/playground'),
            _link('Agent skill (SKILL.md)', '$_repo/blob/main/skills/keyed_form/SKILL.md', external: true),
            _link('Full examples', '$_repo/tree/main/packages/keyed_form_flutter/example', external: true),
          ]),
        ]),
        div(classes: 'footer-bottom mono', [
          span([
            .text('MIT License · '),
            a(classes: 'footer-link', href: '$_repo/blob/main/LICENSE', target: Target.blank, [.text('LICENSE')]),
          ]),
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
      ]),
    ]);
  }

  static Component _column(String title, List<Component> links) {
    return div(classes: 'footer-col', [
      div(classes: 'footer-col-title mono', [.text(title)]),
      ul([
        for (final link in links) li([link]),
      ]),
    ]);
  }

  static Component _link(String label, String href, {bool external = false}) {
    return a(classes: 'footer-link', href: href, target: external ? Target.blank : null, [.text(label)]);
  }
}
