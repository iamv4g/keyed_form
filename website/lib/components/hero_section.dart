import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'copy_button.dart';
import 'optics_raytracer.dart';

class HeroSection extends StatelessComponent {
  const HeroSection({super.key});

  @override
  Component build(BuildContext context) {
    return main_(classes: 'wrap hero', [
      div(classes: 'telemetry-tag mono', [
        .text('System Specification · Zero-Allocation Keyed Optics'),
      ]),
      h1(classes: 'display', [
        .text('Forms, addressed like '),
        span(classes: 'highlight', [.text('optics')]),
        .text(', not strings.'),
      ]),
      p(classes: 'hero-tagline', [
        strong([.text('keyed_form')]),
        .text(
          ' gives every field a stable, typed, serializable identity — so dynamic lists survive reorders without state cross-talk, rebuilds stay strictly ',
        ),
        strong([.text('O(1)')]),
        .text(
          ' at 250+ fields, and form state is a pure Dart value testable without a widget tree.',
        ),
      ]),
      div(classes: 'cmd-bar mono', [
        span([.text(r'$ ')]),
        code([.text('flutter pub add keyed_form_flutter keyed_form_schema')]),
        const CopyButton(
          text: 'flutter pub add keyed_form_flutter keyed_form_schema',
        ),
      ]),
      div(classes: 'cta-group mono', [
        a(
          href: 'https://pub.dev/packages/keyed_form_flutter',
          classes: 'btn btn-cyan',
          [.text('Start with keyed_form_flutter →')],
        ),
        a(
          href: 'https://github.com/iamv4g/keyed_form',
          classes: 'btn btn-outline',
          [.text('Read Source on GitHub ↗')],
        ),
      ]),
      const OpticsRaytracer(),
    ]);
  }
}
