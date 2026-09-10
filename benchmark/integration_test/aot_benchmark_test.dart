// Release-representative numbers for all three libraries, swept to large N —
// the one place the `keyed_form_flutter` **listener fan-out** (every
// `KeyedFormField` listens to the whole controller, so a write fires N
// callbacks) can be seen, and the place to decide whether it needs fixing.
//
// `flutter test` on the host is JIT (~2× slower, noisier); `reactive_forms`
// imports `package:flutter/foundation` and `flutter_form_builder` is
// widget-only, so neither can `dart compile exe`.
//
// ── setup (once) ──────────────────────────────────────────────────────────
//   cd benchmark && flutter create --platforms=macos .
//   (or --platforms=ios / android for a device/emulator; the generated
//    runner is git-ignored)
//
// ── run (AOT) ─────────────────────────────────────────────────────────────
//   flutter test integration_test/aot_benchmark_test.dart --profile -d macos
//   flutter test integration_test/aot_benchmark_test.dart --profile -d <id>
//
// Rebuild counts are exact; µs are real-ish — read the SCALING (does a curve
// bend upward with N?), not the absolute values. JSON lands in
// benchmark_results/aot_*.json.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:keyed_form_benchmark/scenario.dart';
import 'package:keyed_form_benchmark/widget/form_builder_widget_harness.dart';
import 'package:keyed_form_benchmark/widget/formz_widget_harness.dart';
import 'package:keyed_form_benchmark/widget/keyed_form_widget_harness.dart';
import 'package:keyed_form_benchmark/widget/reactive_forms_widget_harness.dart';
import 'package:keyed_form_benchmark/widget/widget_harness.dart';

// This suite is the **widget** sweep only. Model-layer AOT numbers come from
// `dart compile exe bin/attribution.dart` / `bin/fanout.dart` (pure Dart, no
// harness swallowing `print`); `reactive_forms`' model layer is JIT-only in
// `test/model_benchmark_test.dart`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const widgetSizes = [100, 250, 500, 1000];

  // ── widget layer — one keystroke, swept ────────────────────────────────
  final widgetHarnesses = <WidgetHarness Function()>[
    KeyedFormWidgetHarness.new,
    ReactiveFormsWidgetHarness.new,
    FormBuilderWidgetHarness.new,
    FormzWidgetHarness.new,
  ];

  for (final n in widgetSizes) {
    final scenario = Scenario(fieldCount: n);
    for (final make in widgetHarnesses) {
      final harness = make();
      testWidgets('AOT · widget · ${harness.name} · one keystroke · ${n}f',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: harness.build(scenario))),
        );
        await tester.pumpAndSettle();
        await tester.showKeyboard(harness.editableAt(n ~/ 2));
        await tester.pumpAndSettle();

        var rebuilds = 0;
        debugOnRebuildDirtyWidget = (_, _) => rebuilds++;

        // median of several keystrokes to damp GC noise
        final samples = <double>[];
        for (var r = 0; r < 12; r++) {
          rebuilds = 0;
          final sw = Stopwatch()..start();
          tester.testTextInput.enterText('edit $r padding text');
          await tester.pump();
          sw.stop();
          samples.add(sw.elapsedMicroseconds.toDouble());
        }
        debugOnRebuildDirtyWidget = null;
        samples.sort();

        // ignore: avoid_print
        print('AOT ${harness.name.padRight(22)} ${n.toString().padLeft(5)}f  '
            'rebuilds=${rebuilds.toString().padLeft(5)}  '
            'pump median=${(samples[6] / 1000).toStringAsFixed(2)}ms  '
            'p90=${(samples[10] / 1000).toStringAsFixed(2)}ms');
      });
    }
  }
}
