@Tags(['benchmark'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyed_form_benchmark/scenario.dart';
import 'package:keyed_form_benchmark/src/measure.dart';
import 'package:keyed_form_benchmark/widget/form_builder_widget_harness.dart';
import 'package:keyed_form_benchmark/widget/keyed_form_widget_harness.dart';
import 'package:keyed_form_benchmark/widget/reactive_forms_widget_harness.dart';
import 'package:keyed_form_benchmark/widget/widget_harness.dart';

/// Widget-layer cost of one keystroke, swept over form size. Run with:
///
///   flutter test test/rebuild_benchmark_test.dart --tags benchmark
///
/// Measures, per `enterText` on a middle field:
///  * total widget rebuilds in the tree (`debugOnRebuildDirtyWidget`)
///  * the type breakdown of those rebuilds
///  * wall time of the settling `pump()` — this is where `keyed_form`'s
///    O(fields) listener fan-out shows up even though it is not a rebuild.
void main() {
  final harnesses = <WidgetHarness Function()>[
    KeyedFormWidgetHarness.new,
    ReactiveFormsWidgetHarness.new,
    FormBuilderWidgetHarness.new,
  ];

  final flatSizes = [
    const Scenario(fieldCount: 10),
    const Scenario(fieldCount: 50),
    const Scenario(fieldCount: 100),
    const Scenario(fieldCount: 250),
  ];

  final report = Report('one keystroke · widget layer');

  for (final scenario in flatSizes) {
    for (final make in harnesses) {
      final harness = make();

      testWidgets('${harness.name} · ${scenario.label}', (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: harness.build(scenario))),
        );
        await tester.pumpAndSettle();

        final mid = scenario.fieldCount ~/ 2;

        // Focus the target field first and let the focus churn settle, so the
        // measured window contains only the reaction to the *text change*, not
        // Flutter's focus-traversal rebuilds.
        await tester.showKeyboard(harness.editableAt(mid));
        await tester.pumpAndSettle();

        final byType = <String, int>{};
        var total = 0;
        debugOnRebuildDirtyWidget = (element, builtOnce) {
          total++;
          final t = element.widget.runtimeType.toString();
          byType[t] = (byType[t] ?? 0) + 1;
        };

        final sw = Stopwatch()..start();
        tester.testTextInput.enterText('hello world');
        await tester.pump();
        sw.stop();

        debugOnRebuildDirtyWidget = null;

        final top = (byType.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .take(4)
            .map((e) => '${e.key}:${e.value}')
            .join('  ');

        report
          ..add(Sample('${harness.name} · ${scenario.label} · rebuilds',
              [total.toDouble()]))
          ..add(Sample('${harness.name} · ${scenario.label} · pump µs',
              [sw.elapsedMicroseconds.toDouble()]));

        // ignore: avoid_print
        print('${harness.name.padRight(22)} ${scenario.label.padLeft(5)}  '
            'rebuilds=${total.toString().padLeft(5)}  '
            'pump=${(sw.elapsedMicroseconds / 1000).toStringAsFixed(2).padLeft(7)}ms   '
            '[$top]');
      });
    }
  }

  tearDownAll(() {
    // ignore: avoid_print
    print(report.table());
    report.writeJson('benchmark_results/rebuild.json');
  });
}
