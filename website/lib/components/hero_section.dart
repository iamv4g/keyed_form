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
        h1(classes: 'display', [.text('Big forms, made easy.')]),
        p(classes: 'hero-tagline', [
          strong([.text('keyed_form')]),
          .text(' handles nested fields, dependent rules and rebuilds, so big forms stay fast.'),
        ]),
        div(classes: 'cmd-bar mono', [
          span([.text(r'$ ')]),
          code([.text(_installCommand)]),
          const CopyButton(text: _installCommand),
        ]),
        div(classes: 'cta-group mono', [
          a(
            href: '$siteBasePath/docs/guides/quickstart',
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
