@Tags(['benchmark'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:keyed_form_benchmark/model/keyed_form_harness.dart';
import 'package:keyed_form_benchmark/model/model_harness.dart';
import 'package:keyed_form_benchmark/model/reactive_forms_harness.dart';
import 'package:keyed_form_benchmark/scenario.dart';
import 'package:keyed_form_benchmark/src/measure.dart';

/// Model-layer (no widgets) timings. Run with:
///
///   flutter test test/model_benchmark_test.dart --tags benchmark --no-pause-upon-exit
///
/// Results table is printed and also written to
/// `benchmark_results/model_<scenario>.json`.
void main() {
  final builders = <ModelHarness Function()>[
    () => KeyedFormHarness(scoped: false),
    () => KeyedFormHarness(scoped: true),
    ReactiveFormsHarness.new,
  ];

  for (final scenario in Scenario.sweep) {
    test('model — ${scenario.label}', () {
      final report = Report('model layer · $scenario');

      for (final make in builders) {
        final lib = make().name;

        // build: construct a fresh form of this size.
        report.add(measure(
          '$lib · build',
          () => make()..build(scenario),
          warmup: 50,
          iterations: 150,
        ));

        // setField: the hot path — one valid write + whatever the library
        // does synchronously (revalidate / dirty / notify).
        {
          final h = make()..build(scenario);
          final mid = scenario.fieldCount ~/ 2;
          var n = 0;
          report.add(measure(
            '$lib · setField (mid)',
            () => h.setField(mid, 'v${n++ & 1023}'),
          ));
          h.dispose();
        }

        // isDirty / isValid reads after a write.
        {
          final h = make()..build(scenario);
          h.setField(0, 'dirtynow');
          report.add(measure('$lib · isDirty', () => h.isDirty, batch: 500));
          report.add(measure('$lib · isValid', () => h.isValid, batch: 500));
          h.dispose();
        }

        // list churn (row scenarios only).
        if (scenario.rowCount > 0) {
          final h = make()..build(scenario);
          report.add(measure(
            '$lib · addRow + removeRow',
            () {
              h.addRow(const RowData(city: 'X', nights: 1));
              h.removeRow(h.rowCount - 1);
            },
            warmup: 50,
            iterations: 100,
          ));
          h.dispose();
        }
      }

      // ignore: avoid_print
      print(report.table());
      report.writeJson('benchmark_results/model_${scenario.label}.json');
    });
  }
}
