import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../base_path.dart';
import 'copy_button.dart';

class ClosingCta extends StatelessComponent {
  const ClosingCta({super.key});

  static const _installCommand = 'flutter pub add keyed_form_flutter keyed_form_schema';

  @override
  Component build(BuildContext context) {
    return section(id: 'start', classes: 'wrap closing-cta', [
      h2(classes: 'section-title display', [.text('Your next form is one schema away.')]),
      p(classes: 'section-lede', [
        .text('One schema, one controller, and a form that knows exactly which field changed.'),
      ]),
      div(classes: 'cmd-bar mono', [
        span([.text(r'$ ')]),
        code([.text(_installCommand)]),
        const CopyButton(text: _installCommand),
      ]),
      div(classes: 'cta-group mono', [
        a(href: '$siteBasePath/docs/quickstart', classes: 'btn btn-cyan', [.text('Build your first form →')]),
        a(
          href: 'https://github.com/iamv4g/keyed_form',
          target: Target.blank,
          classes: 'btn btn-outline',
          [.text('GitHub ↗')],
        ),
      ]),
    ]);
  }
}
