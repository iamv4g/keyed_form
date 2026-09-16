import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../base_path.dart';

class TelemetrySection extends StatelessComponent {
  const TelemetrySection({super.key});

  @override
  Component build(BuildContext context) {
    return section(id: 'benchmarks', classes: 'wrap', [
      span(classes: 'section-kicker mono', [
        .text('// MEASURED TELEMETRY'),
      ]),
      h2(classes: 'section-title display', [
        .text("O(1) isn't a claim here — it's measured"),
      ]),
      p(classes: 'section-lede', [
        .text(
          'Same 250-field, 100-row form, one keystroke into a middle field across four libraries in one harness (',
        ),
        code(classes: 'mono', [.text('benchmark/')]),
        .text(
          ' in repository — JIT debug numbers, reproducible, ~2–3× slower than release AOT).',
        ),
      ]),
      // Big Telemetry HUD Tiles
      div(classes: 'hud-stats', [
        div(classes: 'blueprint-box stat-tile', [
          div(classes: 'stat-big mono', [
            .text('44 '),
            span(classes: 'stat-bad', [.text('6,021')]),
          ]),
          div(classes: 'stat-desc mono', [
            .text('Widget rebuilds for one keystroke, 250-field form — '),
            strong([.text('keyed_form_flutter')]),
            .text(' vs a widget-per-field builder ('),
            strong([.text('99.3% reduction')]),
            .text(').'),
          ]),
        ]),
        div(classes: 'blueprint-box stat-tile', [
          div(classes: 'stat-big mono', [
            .text('2µs '),
            span(classes: 'stat-bad', [.text('30µs')]),
          ]),
          div(classes: 'stat-desc mono', [
            .text('Latency to commit one field update at 100 rows — '),
            strong([.text('keyed_form')]),
            .text(' vs a string-keyed reactive controller ('),
            strong([.text('15× faster')]),
            .text(').'),
          ]),
        ]),
        div(classes: 'blueprint-box stat-tile', [
          div(classes: 'stat-big mono', [.text('0.00µs')]),
          div(classes: 'stat-desc mono', [
            .text(
              'Amortized isValid check cost. Scoped optics caches preserve validity without traversing the tree.',
            ),
          ]),
        ]),
      ]),
      p(classes: 'note mono', [
        .text('Full scenario sweep, widget-rebuild tables, and reproduction steps: '),
        a(href: '$siteBasePath/docs#benchmarks-methodology', [.text('Benchmarks & Methodology →')]),
      ]),
    ]);
  }
}
