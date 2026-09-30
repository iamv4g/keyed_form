import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../base_path.dart';
import 'copy_button.dart';
import 'demo/hero_login_demo.dart';

class HeroSection extends StatelessComponent {
  const HeroSection({super.key});

  static const _installCommand = 'flutter pub add keyed_form_flutter keyed_form_schema';

  @override
  Component build(BuildContext context) {
    return main_(classes: 'wrap hero', [
      div(classes: 'hero-copy', [
        div(classes: 'hero-chips mono', [
          for (final chip in const ['MIT', 'Pure Dart core', 'Flutter']) span(classes: 'chip', [.text(chip)]),
        ]),
        h1(classes: 'display', [
          .text('Big forms. Less code.'),
          span(classes: 'highlight', [.text('One rebuild per keystroke.')]),
        ]),
        p(classes: 'hero-tagline', [
          .text('Declare one schema; '),
          strong([.text('keyed_form')]),
          .text(
            ' generates the typed field refs, so each widget listens to its own slice of state — at 250 fields, '
            'across list reorders, with no string keys. Form logic stays plain Dart you can test without a widget '
            'tree.',
          ),
        ]),
        div(classes: 'cmd-bar mono', [
          span([.text(r'$ ')]),
          code([.text(_installCommand)]),
          const CopyButton(text: _installCommand),
        ]),
        div(classes: 'cta-group mono', [
          a(
            href: '$siteBasePath/docs/quickstart',
            classes: 'btn btn-cyan',
            [.text('Build your first form →')],
          ),
          a(
            href: 'https://github.com/iamv4g/keyed_form',
            target: Target.blank,
            classes: 'btn btn-outline',
            [.text('GitHub ↗')],
          ),
        ]),
      ]),
      const HeroLoginDemo(),
    ]);
  }
}
