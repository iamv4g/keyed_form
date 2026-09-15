import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

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
      // Blueprint Log-Scale SVG Bar Chart
      div(classes: 'blueprint-box chart-panel', [
        div(classes: 'chart-title mono', [
          .text('Widget rebuilds per keystroke, '),
          b([.text('250-field form')]),
          .text(' — logarithmic scale'),
        ]),
        svg(
          viewBox: '0 0 530 190',
          attributes: {
            'role': 'img',
            'aria-label': 'Bar chart of widget rebuilds per keystroke at 250 fields, log scale',
            'preserveAspectRatio': 'xMinYMid meet',
          },
          [
            // Gridlines / ticks mapped log10 across x 10..470
            Component.element(
              tag: 'g',
              attributes: {
                'font-size': '10.5',
                'fill': 'var(--ink-muted)',
              },
              children: [
                line(
                  x1: '10',
                  y1: '10',
                  x2: '10',
                  y2: '150',
                  attributes: {
                    'stroke': 'var(--border)',
                    'stroke-dasharray': '3 3',
                  },
                  [],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {'x': '10', 'y': '165'},
                  children: [.text('1')],
                ),
                line(
                  x1: '125',
                  y1: '10',
                  x2: '125',
                  y2: '150',
                  attributes: {
                    'stroke': 'var(--border)',
                    'stroke-dasharray': '3 3',
                  },
                  [],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {'x': '125', 'y': '165'},
                  children: [.text('10')],
                ),
                line(
                  x1: '240',
                  y1: '10',
                  x2: '240',
                  y2: '150',
                  attributes: {
                    'stroke': 'var(--border)',
                    'stroke-dasharray': '3 3',
                  },
                  [],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {'x': '240', 'y': '165'},
                  children: [.text('100')],
                ),
                line(
                  x1: '355',
                  y1: '10',
                  x2: '355',
                  y2: '150',
                  attributes: {
                    'stroke': 'var(--border)',
                    'stroke-dasharray': '3 3',
                  },
                  [],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {'x': '355', 'y': '165'},
                  children: [.text('1,000')],
                ),
                line(
                  x1: '470',
                  y1: '10',
                  x2: '470',
                  y2: '150',
                  attributes: {
                    'stroke': 'var(--border)',
                    'stroke-dasharray': '3 3',
                  },
                  [],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {'x': '470', 'y': '165'},
                  children: [.text('10,000')],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {
                    'x': '240',
                    'y': '182',
                    'text-anchor': 'middle',
                    'fill': 'var(--ink-muted)',
                  },
                  children: [.text('rebuilds per keystroke (log scale)')],
                ),
              ],
            ),
            // Bars: x = 10 + 115*log10(value)
            // keyed_form_flutter: 44 -> 199
            Component.element(
              tag: 'g',
              children: [
                rect(
                  x: '10',
                  y: '14',
                  width: '189',
                  height: '24',
                  rx: '2',
                  attributes: {'fill': 'var(--cyan)'},
                  [],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {
                    'x': '206',
                    'y': '30',
                    'font-size': '12',
                    'fill': 'var(--ink)',
                    'font-weight': '600',
                  },
                  children: [.text('44 · keyed_form_flutter')],
                ),
              ],
            ),
            // string-keyed reactive: 45 -> 200
            Component.element(
              tag: 'g',
              children: [
                rect(
                  x: '10',
                  y: '46',
                  width: '190',
                  height: '24',
                  rx: '2',
                  attributes: {'fill': 'var(--border-bright)'},
                  [],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {
                    'x': '207',
                    'y': '62',
                    'font-size': '12',
                    'fill': 'var(--ink-muted)',
                  },
                  children: [.text('45 · string-keyed reactive')],
                ),
              ],
            ),
            // sealed-state validator: 44 -> 199
            Component.element(
              tag: 'g',
              children: [
                rect(
                  x: '10',
                  y: '78',
                  width: '189',
                  height: '24',
                  rx: '2',
                  attributes: {'fill': 'var(--border-bright)'},
                  [],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {
                    'x': '206',
                    'y': '94',
                    'font-size': '12',
                    'fill': 'var(--ink-muted)',
                  },
                  children: [.text('44 · sealed-state validator')],
                ),
              ],
            ),
            // declarative builder: 6021 -> 445
            Component.element(
              tag: 'g',
              children: [
                rect(
                  x: '10',
                  y: '110',
                  width: '435',
                  height: '24',
                  rx: '2',
                  attributes: {'fill': 'var(--red)'},
                  [],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {
                    'x': '20',
                    'y': '126',
                    'font-size': '12',
                    'fill': '#fff',
                    'font-weight': '600',
                  },
                  children: [.text('6,021 · declarative builder')],
                ),
              ],
            ),
          ],
        ),
      ]),
      // Detailed Latency Table
      div(classes: 'table-scroll', [
        table(classes: 'spec', [
          caption([
            .text(
              '// MODEL LAYER LATENCY: 20 fields + 100 rows — median µs per operation (lower is better)',
            ),
          ]),
          thead([
            tr([
              th([.text('Library Architecture')]),
              th(classes: 'num', [.text('Commit an edit')]),
              th(classes: 'num', [.text('isDirty check')]),
              th(classes: 'num', [.text('isValid check')]),
              th(classes: 'num', [.text('Add + remove a row')]),
            ]),
          ]),
          tbody([
            tr([
              td([
                strong(classes: 'text-cyan', [.text('keyed_form')]),
              ]),
              td(classes: 'num text-cyan font-semibold', [
                .text('2.00 µs'),
              ]),
              td(classes: 'num', [.text('0.01 µs')]),
              td(classes: 'num', [.text('0.00 µs')]),
              td(classes: 'num text-cyan font-semibold', [
                .text('18.00 µs'),
              ]),
            ]),
            tr([
              td([.text('String-Keyed Reactive')]),
              td(classes: 'num text-red', [.text('30.00 µs')]),
              td(classes: 'num', [.text('0.00 µs')]),
              td(classes: 'num', [.text('0.00 µs')]),
              td(classes: 'num', [.text('108.00 µs')]),
            ]),
            tr([
              td([.text('Sealed-State Validator')]),
              td(classes: 'num', [.text('0.00 µs')]),
              td(classes: 'num', [.text('0.02 µs')]),
              td(classes: 'num', [.text('2.85 µs')]),
              td(classes: 'num', [.text('0.00 µs')]),
            ]),
          ]),
        ]),
      ]),
      p(classes: 'note mono', [
        .text(
          '*Note: the sealed-state validator architecture ships no form controller or widget tree binding — its "commit" measures only a single Input\'s isolated validation, which is why row/list state management remains user code to implement. Full methodology and reproducible harnesses: ',
        ),
        code(classes: 'mono', [.text('benchmark/README.md')]),
        .text('.'),
      ]),
    ]);
  }
}
