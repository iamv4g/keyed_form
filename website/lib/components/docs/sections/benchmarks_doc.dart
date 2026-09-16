import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../docs_callout.dart';

class BenchmarksDoc extends StatelessComponent {
  const BenchmarksDoc({super.key});

  @override
  Component build(BuildContext context) {
    return section(classes: 'docs-section', [
      div(id: 'benchmarks-methodology', classes: 'docs-anchor', []),
      span(classes: 'section-kicker mono', [.text('// 07 · BENCHMARKS & METHODOLOGY')]),
      h2(classes: 'docs-h2 display', [.text('How These Numbers Are Measured')]),
      p(classes: 'docs-lead', [
        .text(
          'Every benchmark number on the home page and in this doc comes from one harness comparing the same form shape (',
        ),
        code([.text('benchmark/')]),
        .text(
          ' in the repository) across four form architectures, measuring the same operations on the same machine.',
        ),
      ]),

      const DocsCallout(
        type: CalloutType.note,
        title: "These are JIT debug numbers, not AOT release",
        content: Component.fragment([
          p([
            .text(
              'Every table below runs through `flutter test` in JIT mode — slower and noisier than an AOT release build by roughly 2–3×. Widget rebuild counts are exact (they\'re counted); µs figures are directional ratios between architectures, not real on-device latency. Reproduce it yourself: ',
            ),
            code([.text('cd benchmark && ./tool/run.sh')]),
            .text('.'),
          ]),
        ]),
      ),

      h3(classes: 'docs-h3 display mt-24', [.text('Model Layer Latency — by Form Size')]),
      p([
        .text(
          'A flat form of `fieldCount` text fields (required + minLength(3)), median µs per operation. `keyed_form` here is the list-backed variant with a hand-written resolver, for a fair comparison at every size.',
        ),
      ]),
      div(classes: 'table-scroll', [
        table(classes: 'spec', [
          caption([.text('// median µs, lower is better')]),
          thead([
            tr([
              th([.text('Library Architecture')]),
              th(classes: 'num', [.text('10 fields')]),
              th(classes: 'num', [.text('50 fields')]),
              th(classes: 'num', [.text('100 fields')]),
              th(classes: 'num', [.text('250 fields')]),
            ]),
          ]),
          tbody([
            tr([
              td([strong(classes: 'text-cyan', [.text('keyed_form — setField')])]),
              td(classes: 'num text-cyan font-semibold', [.text('11.00 µs')]),
              td(classes: 'num text-cyan font-semibold', [.text('5.00 µs')]),
              td(classes: 'num text-cyan font-semibold', [.text('9.00 µs')]),
              td(classes: 'num text-cyan font-semibold', [.text('22.00 µs')]),
            ]),
            tr([
              td([.text('String-Keyed Reactive — setField')]),
              td(classes: 'num', [.text('25.00 µs')]),
              td(classes: 'num', [.text('20.00 µs')]),
              td(classes: 'num', [.text('24.00 µs')]),
              td(classes: 'num text-red', [.text('37.00 µs')]),
            ]),
            tr([
              td([.text('Sealed-State Validator — setField')]),
              td(classes: 'num', [.text('0.00 µs')]),
              td(classes: 'num', [.text('0.00 µs')]),
              td(classes: 'num', [.text('0.00 µs')]),
              td(classes: 'num', [.text('0.00 µs')]),
            ]),
            tr([
              td([strong(classes: 'text-cyan', [.text('keyed_form — isValid')])]),
              td(classes: 'num text-cyan font-semibold', [.text('0.004 µs')]),
              td(classes: 'num text-cyan font-semibold', [.text('0.004 µs')]),
              td(classes: 'num text-cyan font-semibold', [.text('0.004 µs')]),
              td(classes: 'num text-cyan font-semibold', [.text('0.004 µs')]),
            ]),
            tr([
              td([.text('String-Keyed Reactive — isValid')]),
              td(classes: 'num', [.text('0.004 µs')]),
              td(classes: 'num', [.text('0.004 µs')]),
              td(classes: 'num', [.text('0.004 µs')]),
              td(classes: 'num', [.text('0.004 µs')]),
            ]),
            tr([
              td([.text('Sealed-State Validator — isValid')]),
              td(classes: 'num', [.text('0.15 µs')]),
              td(classes: 'num', [.text('0.62 µs')]),
              td(classes: 'num', [.text('1.21 µs')]),
              td(classes: 'num text-red', [.text('3.04 µs')]),
            ]),
          ]),
        ]),
      ]),
      p(classes: 'note mono', [
        .text(
          '*The Sealed-State Validator architecture never validates on write — the real cost sits at every `isValid` read instead, growing near-linearly with field count because nothing is cached. keyed_form and String-Keyed Reactive validate once per write and cache the result, so isValid stays flat regardless of form size.',
        ),
      ]),

      h3(classes: 'docs-h3 display mt-24', [.text('Model Layer Latency — 20 Fields + 100 Rows')]),
      p([
        .text(
          'A more realistic scenario: a form with a 100-row dynamic list (2 fields per row) plus 20 flat fields, with a cross-field rule `sum(nights) <= maxNights`.',
        ),
      ]),
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
              td([strong(classes: 'text-cyan', [.text('keyed_form')])]),
              td(classes: 'num text-cyan font-semibold', [.text('2.00 µs')]),
              td(classes: 'num', [.text('0.01 µs')]),
              td(classes: 'num', [.text('0.00 µs')]),
              td(classes: 'num text-cyan font-semibold', [.text('18.00 µs')]),
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

      h3(classes: 'docs-h3 display mt-24', [.text('Widget Layer — Rebuilds Per Keystroke')]),
      p([
        .text(
          "Widget rebuilds triggered across the whole tree by typing one character into one field (focus already settled). Rebuild counts are exact, not estimates.",
        ),
      ]),
      div(classes: 'table-scroll', [
        table(classes: 'spec', [
          caption([.text('// widget rebuilds per keystroke, by form size')]),
          thead([
            tr([
              th([.text('Library Architecture')]),
              th(classes: 'num', [.text('10 fields')]),
              th(classes: 'num', [.text('50 fields')]),
              th(classes: 'num', [.text('100 fields')]),
              th(classes: 'num', [.text('250 fields')]),
            ]),
          ]),
          tbody([
            tr([
              td([strong(classes: 'text-cyan', [.text('keyed_form_flutter')])]),
              td(classes: 'num text-cyan font-semibold', [.text('44')]),
              td(classes: 'num text-cyan font-semibold', [.text('44')]),
              td(classes: 'num text-cyan font-semibold', [.text('44')]),
              td(classes: 'num text-cyan font-semibold', [.text('44')]),
            ]),
            tr([
              td([.text('String-Keyed Reactive')]),
              td(classes: 'num', [.text('45')]),
              td(classes: 'num', [.text('45')]),
              td(classes: 'num', [.text('45')]),
              td(classes: 'num', [.text('45')]),
            ]),
            tr([
              td([.text('Sealed-State Validator')]),
              td(classes: 'num', [.text('44')]),
              td(classes: 'num', [.text('44')]),
              td(classes: 'num', [.text('44')]),
              td(classes: 'num', [.text('44')]),
            ]),
            tr([
              td([.text('Declarative Builder')]),
              td(classes: 'num', [.text('261')]),
              td(classes: 'num', [.text('1,221')]),
              td(classes: 'num text-red', [.text('2,421')]),
              td(classes: 'num text-red', [.text('6,021')]),
            ]),
          ]),
        ]),
      ]),
      p(classes: 'note mono', [
        .text(
          'keyed_form, String-Keyed Reactive and Sealed-State Validator all rebuild O(1) — only the widget that actually changed. Declarative Builder rebuilds O(N) because every field listens to one shared FormBuilderState, and it starts timing out in the harness around ~1000 fields. Full methodology, JIT/AOT caveats, and reproduction steps: ',
        ),
        code(classes: 'mono', [.text('benchmark/README.md')]),
        .text(' in the repository.'),
      ]),
    ]);
  }
}
