import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../base_path.dart';

/// Measured cost, stated as flatness rather than as a comparison: the
/// rebuild count for one keystroke doesn't move with form size. Figures
/// come from the widget-layer and 100-row tables in `BenchmarksDoc`.
class TelemetrySection extends StatelessComponent {
  const TelemetrySection({super.key});

  // Widget rebuilds for one keystroke, by form size (benchmarks doc).
  static const _rebuilds = [
    (fields: 10, rebuilds: 44),
    (fields: 50, rebuilds: 44),
    (fields: 100, rebuilds: 44),
    (fields: 250, rebuilds: 44),
  ];

  @override
  Component build(BuildContext context) {
    return section(id: 'benchmarks', classes: 'wrap', [
      span(classes: 'section-kicker mono', [.text('// MEASURED')]),
      h2(classes: 'section-title display', [.text("O(1) isn't a claim here — it's measured.")]),
      p(classes: 'section-lede', [
        .text('One keystroke into one field, counted in the '),
        code(classes: 'mono', [.text('benchmark/')]),
        .text(' harness in the repository — reproducible, JIT debug numbers.'),
      ]),
      div(classes: 'perf-grid', [
        div(classes: 'blueprint-box stat-tile', [
          _chart(),
          // Wrapped in a span: the pre-renderer breaks lines between inline
          // children of a div, which shows up as a space before the comma.
          p(classes: 'stat-desc', [
            span([
              .text("One keystroke rebuilds one field's subtree — "),
              strong([.text('44 widgets')]),
              .text(', whether the form has 10 fields or 250.'),
            ]),
          ]),
        ]),
        div(classes: 'blueprint-box stat-tile', [
          div(classes: 'stat-big mono', [.text('~2 µs')]),
          div(classes: 'stat-desc', [
            .text('To commit one field edit in a form with 20 fields and 100 rows. '),
            .text('Measured in JIT debug mode; a release build is faster still.'),
          ]),
        ]),
      ]),
      a(classes: 'section-link mono', href: '$siteBasePath/docs#benchmarks-methodology', [
        .text('Benchmarks & methodology →'),
      ]),
    ]);
  }

  /// Four equal bars: the point is that they don't grow.
  static Component _chart() {
    const width = 360;
    const height = 170;
    const baseline = 132;
    const barWidth = 46;
    const barHeight = 84;
    const gap = (width - _barCount * barWidth) / (_barCount + 1);
    return svg(
      classes: 'perf-chart',
      viewBox: '0 0 $width $height',
      attributes: {
        'role': 'img',
        'aria-label': 'Widget rebuilds per keystroke: 44 at 10, 50, 100 and 250 fields.',
      },
      [
        line(x1: '0', y1: '$baseline', x2: '$width', y2: '$baseline', classes: 'perf-axis', []),
        for (var i = 0; i < _barCount; i++) ...[
          rect(
            classes: 'perf-bar',
            x: '${gap + i * (barWidth + gap)}',
            y: '${baseline - barHeight}',
            width: '$barWidth',
            height: '$barHeight',
            attributes: {'rx': '3'},
            [],
          ),
          _svgText(
            'perf-value',
            x: gap + i * (barWidth + gap) + barWidth / 2,
            y: baseline - barHeight - 10,
            '${_rebuilds[i].rebuilds}',
          ),
          _svgText(
            'perf-label',
            x: gap + i * (barWidth + gap) + barWidth / 2,
            y: baseline + 20,
            '${_rebuilds[i].fields} fields',
          ),
        ],
      ],
    );
  }

  static const _barCount = 4;

  // jaspr has no builder for SVG's <text>.
  static Component _svgText(String classes, String label, {required num x, required num y}) => Component.element(
    tag: 'text',
    classes: classes,
    attributes: {'x': '$x', 'y': '$y', 'text-anchor': 'middle'},
    children: [Component.text(label)],
  );
}
