// The one suite that produces **release-representative** numbers for all three
// libraries. `flutter test` on the host is JIT (~2× slower, noisier);
// `reactive_forms` imports `package:flutter/foundation` and
// `flutter_form_builder` is widget-only, so neither can `dart compile exe`
// (see bin/attribution.dart for the pure-Dart keyed_form AOT breakdown).
//
// `integration_test` needs a real target. Once, scaffold one:
//
//   cd benchmark && flutter create --platforms=macos .
//
// then run AOT:
//
//   flutter test integration_test/aot_benchmark_test.dart --profile -d macos
//   flutter test integration_test/aot_benchmark_test.dart --profile -d <emulator>
//
// The bodies are the same as test/model_benchmark_test.dart +
// test/rebuild_benchmark_test.dart (which pass under JIT `flutter test`);
// this file just runs them under IntegrationTestWidgetsFlutterBinding so a
// `--profile` build compiles them AOT. Rebuild counts are exact; µs are
// real-ish — read them as ratios.
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';

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

  const scenario = Scenario(fieldCount: 100);

  test('AOT — model layer, one setField (100 flat fields)', () {
    final report = Report('AOT · model · ${scenario.label}');
    final builders = <ModelHarness Function()>[
      () => KeyedFormHarness(scoped: false),
      () => KeyedFormHarness(scoped: true),
      KeyedFormCodegenHarness.new,
      ReactiveFormsHarness.new,
    ];
    for (final make in builders) {
      final lib = make().name;
      report.add(measure('$lib · build', () => make()..build(scenario),
          warmup: 200, iterations: 800));
      final h = make()..build(scenario);
      var n = 0;
      report.add(measure('$lib · setField (mid)',
          () => h.setField(50, 'v${n++ & 1023}'),
          warmup: 4000, iterations: 40000));
      h.dispose();
    }
    // ignore: avoid_print
    print(report.table());
    report.writeJson('benchmark_results/aot_model.json');
  });

  final widgetHarnesses = <WidgetHarness Function()>[
    KeyedFormWidgetHarness.new,
    ReactiveFormsWidgetHarness.new,
    FormBuilderWidgetHarness.new,
  ];

  for (final make in widgetHarnesses) {
    final harness = make();
    testWidgets('AOT — ${harness.name} · one keystroke · ${scenario.label}',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: harness.build(scenario))),
      );
      await tester.pumpAndSettle();
      await tester.showKeyboard(harness.editableAt(50));
      await tester.pumpAndSettle();

      var rebuilds = 0;
      debugOnRebuildDirtyWidget = (_, _) => rebuilds++;
      final sw = Stopwatch()..start();
      tester.testTextInput.enterText('hello world');
      await tester.pump();
      sw.stop();
      debugOnRebuildDirtyWidget = null;

      // ignore: avoid_print
      print('AOT ${harness.name.padRight(22)} rebuilds=${rebuilds.toString().padLeft(5)}'
          '  pump=${(sw.elapsedMicroseconds / 1000).toStringAsFixed(2)}ms');
    });
  }
}
