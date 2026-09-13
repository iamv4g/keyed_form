import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class Footer extends StatelessComponent {
  const Footer({super.key});

  @override
  Component build(BuildContext context) {
    return footer([
      div(classes: 'wrap', [
        div(classes: 'cta-group mono', [
          a(
            classes: 'btn btn-cyan',
            href: 'https://pub.dev/packages/keyed_form_flutter',
            [.text('Get Started with keyed_form_flutter →')],
          ),
          a(
            classes: 'btn btn-outline',
            href: 'https://github.com/iamv4g/keyed_form',
            [.text('Read Source on GitHub ↗')],
          ),
        ]),
        div(classes: 'footer-bottom mono', [
          div([
            strong([.text('keyed_form')]),
            .text(
              ' — Typed forms on keyed optics. Released under the MIT License.',
            ),
          ]),
          div(classes: 'footer-links', [
            a(
              href: 'https://pub.dev/packages/keyed_form_flutter',
              target: Target.blank,
              classes: 'footer-link',
              [.text('pub.dev')],
            ),
            a(
              href: 'https://github.com/iamv4g/keyed_form',
              target: Target.blank,
              classes: 'footer-link',
              [.text('GitHub')],
            ),
            a(
              href: 'https://github.com/iamv4g/keyed_form/blob/main/LICENSE',
              target: Target.blank,
              classes: 'footer-link',
              [.text('License')],
            ),
          ]),
        ]),
      ]),
    ]);
  }
}
