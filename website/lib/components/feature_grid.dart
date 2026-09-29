import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../base_path.dart';

class _Feature {
  const _Feature({
    required this.icon,
    required this.title,
    required this.body,
    required this.api,
    required this.anchor,
  });

  /// A 24×24 stroke-only SVG path (`d`).
  final String icon;
  final String title;
  final String body;
  final List<String> api;

  /// The docs section the card links to.
  final String anchor;
}

const _features = [
  _Feature(
    icon: 'M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20z M12 6v6l4 2',
    title: 'Async validation',
    body:
        'Server checks with a timeout. A check that throws or times out marks the field failed, not invalid, so '
        'retrying is the obvious next step.',
    api: ['validateAsync', 'isFailedValidation'],
    anchor: 'validation',
  ),
  _Feature(
    icon:
        'M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71 M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 '
        '7.07 7.07l1.71-1.71',
    title: 'Cross-field rules',
    body: 'Rules that read the whole draft, switch on and off with a condition, and pin their error to one field.',
    api: ['.refine(when:, path:)'],
    anchor: 'validation',
  ),
  _Feature(
    icon: 'M5 12h14 M12 5l7 7-7 7',
    title: 'Derived fields',
    body:
        "One field writes another. The text binding tells a derived write from the user's own typing, so the "
        'caret never jumps.',
    api: ['addRelation'],
    anchor: 'relations',
  ),
  _Feature(
    icon: 'M12 2L2 7l10 5 10-5-10-5z M2 17l10 5 10-5 M2 12l10 5 10-5',
    title: 'Nested objects & unions',
    body: 'Objects, lists of objects and discriminated unions, with typed refs all the way down to the leaf.',
    api: ['ks.object', 'ks.list', 'ks.discriminatedUnion'],
    anchor: 'recipe-discriminated-unions',
  ),
  _Feature(
    icon: 'M5 11h14a2 2 0 0 1 2 2v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2z M7 11V7a5 5 0 0 1 10 0v4',
    title: 'Freeze a subtree',
    body: 'One call freezes a field, a row or a whole section against writes. Frozen fields still validate.',
    api: ['markReadOnly'],
    anchor: 'field-handles',
  ),
  _Feature(
    icon: 'M12 5v14 M19 12l-7 7-7-7',
    title: 'Scroll to first error',
    body: 'Works in lazy lists too: it jumps to the right section first, then reveals the exact field.',
    api: ['revealFirst'],
    anchor: 'scroll-to-first-error',
  ),
  _Feature(
    icon: 'M22 2L11 13 M22 2l-7 20-4-9-9-4 20-7z',
    title: 'Submit flow',
    body:
        'Validate everything, reveal errors, scroll to the first one or run your callback, and track submitting — '
        'in one call.',
    api: ['handleSubmit'],
    anchor: 'quickstart',
  ),
  _Feature(
    icon:
        'M4 2h16a2 2 0 0 1 2 2v4a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2z M4 14h16a2 2 0 0 1 2 2v4a2 2 0 0 '
        '1-2 2H4a2 2 0 0 1-2-2v-4a2 2 0 0 1 2-2z M6 6h.01 M6 18h.01',
    title: 'Server errors',
    body: "Put a 422's messages on the right fields, by key or by wire path — shown at once, touched or not.",
    api: ['setServerErrors'],
    anchor: 'recipe-backend-errors',
  ),
  _Feature(
    icon: 'M9 11l3 3L22 4 M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11',
    title: 'Test without widgets',
    body: 'The controller is plain Dart. Drive a whole form in a unit test, with no widget tree to pump.',
    api: ['KeyedFormController'],
    anchor: 'testing-without-widgets',
  ),
];

/// Everything the demos above don't show, one card per capability, each
/// linking to its docs section.
class FeatureGrid extends StatelessComponent {
  const FeatureGrid({super.key});

  @override
  Component build(BuildContext context) {
    return section(id: 'features', classes: 'wrap', [
      span(classes: 'section-kicker mono', [.text('// FEATURES')]),
      h2(classes: 'section-title display', [.text('Everything else a real form needs.')]),
      div(classes: 'feature-grid', [
        for (final f in _features)
          a(classes: 'feature-card', href: '$siteBasePath/docs#${f.anchor}', [
            svg(
              classes: 'feature-icon',
              viewBox: '0 0 24 24',
              width: 20.px,
              height: 20.px,
              attributes: {
                'fill': 'none',
                'stroke': 'currentColor',
                'stroke-width': '2',
                'stroke-linecap': 'round',
                'stroke-linejoin': 'round',
                'aria-hidden': 'true',
              },
              [path(d: f.icon, [])],
            ),
            h3(classes: 'feature-title display', [.text(f.title)]),
            p(classes: 'feature-body', [.text(f.body)]),
            div(classes: 'feature-api mono', [
              for (final name in f.api) code([.text(name)]),
            ]),
          ]),
      ]),
    ]);
  }
}
