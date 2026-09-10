// AOT model-layer comparison — keyed_form vs formz. Both are pure Dart, so
// both `dart compile exe` (≈ release/profile perf, no asserts). reactive_forms
// cannot (needs package:flutter/foundation) — the 3-way lives in the JIT
// model_benchmark_test.
//
//   dart compile exe bin/formz_aot.dart -o /tmp/kf_formz && /tmp/kf_formz
//
// ignore_for_file: avoid_print
import 'package:keyed_form_benchmark/model/formz_harness.dart';
import 'package:keyed_form_benchmark/model/keyed_form_harness.dart';
import 'package:keyed_form_benchmark/model/model_harness.dart';
import 'package:keyed_form_benchmark/scenario.dart';

double bench(
  String name,
  void Function() body, {
  int warmup = 20000,
  int iters = 300000,
}) {
  for (var i = 0; i < warmup; i++) {
    body();
  }
  final sw = Stopwatch()..start();
  for (var i = 0; i < iters; i++) {
    body();
  }
  sw.stop();
  final us = sw.elapsedMicroseconds / iters;
  print('  ${name.padRight(24)} ${us.toStringAsFixed(3)} us');
  return us;
}

void main() {
  const scenario = Scenario(fieldCount: 100);
  var n = 0;
  var sink = false;

  print('model layer — 100 flat fields, AOT (dart compile exe)\n');

  for (final make in <ModelHarness Function()>[
    () => KeyedFormHarness(scoped: false),
    () => KeyedFormHarness(scoped: true),
    FormzHarness.new,
  ]) {
    final h = make()..build(scenario);
    print(h.name);
    bench('setField (mid)', () => h.setField(50, 'v${n++ & 1023}'));
    bench('isValid (read)', () => sink = h.isValid);
    bench('isDirty (read)', () => sink = h.isDirty);
    h.dispose();
    print('');
  }

  // Keep `sink` observably live so the isValid/isDirty reads are not
  // optimised away.
  print('(sink=$sink)');
}
