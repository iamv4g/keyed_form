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

import 'package:keyed_form_benchmark/model/keyed_form_codegen_harness.dart';
import 'package:keyed_form_benchmark/model/keyed_form_harness.dart';
import 'package:keyed_form_benchmark/model/model_harness.dart';
import 'package:keyed_form_benchmark/model/reactive_forms_harness.dart';
import 'package:keyed_form_benchmark/scenario.dart';
import 'package:keyed_form_benchmark/src/measure.dart';
import 'package:keyed_form_benchmark/widget/form_builder_widget_harness.dart';
import 'package:keyed_form_benchmark/widget/keyed_form_widget_harness.dart';
import 'package:keyed_form_benchmark/widget/reactive_forms_widget_harness.dart';
import 'package:keyed_form_benchmark/widget/widget_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const widgetSizes = [100, 250, 500, 1000];
  const modelSizes = [100, 500, 1000, 2000];

  // ── model layer — build + one setField, swept ──────────────────────────
  test('AOT · model · setField vs form size', () {
    final report = Report('AOT · model · setField(mid) µs by field count');
    for (final n in modelSizes) {
      final scenario = Scenario(fieldCount: n);
      final builders = <ModelHarness Function()>[
        () => KeyedFormHarness(scoped: false),
        () => KeyedFormHarness(scoped: true),
        ReactiveFormsHarness.new,
      ];
      for (final make in builders) {
        final h = make()..build(scenario);
        var k = 0;
        report.add(measure(
          '${make().name} · ${n}f',
          () => h.setField(n ~/ 2, 'v${k++ & 1023}'),
          warmup: 2000,
          iterations: 20000,
        ));
        h.dispose();
      }
    }
    // codegen model is fixed at 100 fields (Bench100Schema)
    for (final scoped in [false, true]) {
      final h = KeyedFormCodegenHarness(scoped: scoped)
        ..build(KeyedFormCodegenHarness.supported);
      var k = 0;
      report.add(measure(
        '${h.name} · 100f',
        () => h.setField(50, 'v${k++ & 1023}'),
        warmup: 2000,
        iterations: 20000,
      ));
      h.dispose();
    }
    // ignore: avoid_print
    print(report.table());
    report.writeJson('benchmark_results/aot_model_sweep.json');
  });

  // ── widget layer — one keystroke, swept ────────────────────────────────
  final widgetHarnesses = <WidgetHarness Function()>[
    KeyedFormWidgetHarness.new,
    ReactiveFormsWidgetHarness.new,
    FormBuilderWidgetHarness.new,
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
