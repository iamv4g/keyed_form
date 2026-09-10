@Tags(['benchmark'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:keyed_form_benchmark/model/keyed_form_codegen_harness.dart';
import 'package:keyed_form_benchmark/model/keyed_form_harness.dart';
import 'package:keyed_form_benchmark/model/model_harness.dart';
import 'package:keyed_form_benchmark/model/reactive_forms_harness.dart';
import 'package:keyed_form_benchmark/src/measure.dart';

/// How far does the parameterised, list-backed `keyed_form` stand-in
/// (hand-written resolver) sit from a **real `keyed_form_gen` model**
/// (`Bench100Schema` + `validateData` through `toMap()` + the `ks.*` schema)?
///
///   flutter test test/codegen_calibration_test.dart --tags benchmark
void main() {
  const scenario = KeyedFormCodegenHarness.supported; // 100 flat fields

  final builders = <ModelHarness Function()>[
    () => KeyedFormHarness(scoped: false),
    () => KeyedFormHarness(scoped: true),
    KeyedFormCodegenHarness.new,
    () => KeyedFormCodegenHarness(scoped: true),
    ReactiveFormsHarness.new,
  ];

  test('codegen calibration — ${scenario.label}', () {
    // Fairness: the codegen harness must agree with the stand-in.
    final a = KeyedFormHarness(scoped: false)..build(scenario);
    final b = KeyedFormCodegenHarness()..build(scenario);
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    expect(b.isValid, a.isValid, reason: 'both seeded valid');
    expect(b.isDirty, a.isDirty);
    b.setField(50, 'no');
    a.setField(50, 'no');
    expect(b.isValid, isFalse);
    expect(b.isValid, a.isValid);
    b.setField(50, 'fixed');
    a.setField(50, 'fixed');
    expect(b.isValid, a.isValid);
    expect(b.isDirty, isTrue);

    // The scoped codegen wiring (generated scopeOf + validateData tear-off)
    // reaches the same verdict.
    final s = KeyedFormCodegenHarness(scoped: true)..build(scenario);
    addTearDown(s.dispose);
    s.setField(50, 'no');
    expect(s.isValid, isFalse);
    s.setField(50, 'fixed');
    expect(s.isValid, isTrue);
    s.setField(12, 'no');
    expect(s.isValid, isFalse, reason: 'a second field is also seen');

    final report = Report('codegen calibration · ${scenario.label}');
    for (final make in builders) {
      final lib = make().name;
      report.add(measure('$lib · build', () => make()..build(scenario),
          warmup: 30, iterations: 120));
      final h = make()..build(scenario);
      var n = 0;
      report.add(measure(
        '$lib · setField (mid)',
        () => h.setField(50, 'v${n++ & 1023}'),
      ));
      h.dispose();
    }

    // ignore: avoid_print
    print(report.table());
    report.writeJson('benchmark_results/codegen_calibration.json');
  });
}
