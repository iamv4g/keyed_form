import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../scenario.dart';

/// The library-agnostic surface the widget-layer benchmarks drive: a form of
/// [Scenario] size, rendered with the library's own field widgets, with a
/// findable editable per flat field.
abstract class WidgetHarness {
  String get name;

  /// The widget under test — place it under a `MaterialApp`.
  Widget build(Scenario scenario);

  /// The `EditableText` for flat field [index].
  Finder editableAt(int index) => find.descendant(
        of: find.byKey(ValueKey('bench_field_$index')),
        matching: find.byType(EditableText),
      );

  /// Whole-form dirty — for parity assertions (may cost O(fields) in some
  /// libraries; that is itself a datapoint).
  bool isDirty();
}
