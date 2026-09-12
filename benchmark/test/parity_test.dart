import 'package:flutter_test/flutter_test.dart';
import 'package:keyed_form_benchmark/model/advanced_forms_harness.dart';
import 'package:keyed_form_benchmark/model/formz_harness.dart';
import 'package:keyed_form_benchmark/model/keyed_form_harness.dart';
import 'package:keyed_form_benchmark/model/model_harness.dart';
import 'package:keyed_form_benchmark/model/reactive_forms_harness.dart';
import 'package:keyed_form_benchmark/scenario.dart';

/// The comparison is only fair if every harness models the *same* form and
/// agrees on the observable outcomes of a scripted edit sequence.
void main() {
  final builders = <ModelHarness Function()>[
    () => KeyedFormHarness(scoped: false),
    () => KeyedFormHarness(scoped: true),
    ReactiveFormsHarness.new,
    FormzHarness.new,
    AdvancedFormsHarness.new,
  ];

  const scenario = Scenario(fieldCount: 6, rowCount: 3, maxNights: 5);

  for (final make in builders) {
    test('parity — ${make().name}', () {
      final h = make()..build(scenario);
      addTearDown(h.dispose);

      // Fresh build: seeded valid, pristine.
      expect(h.isValid, isTrue, reason: 'seeded values are all valid');
      expect(h.isDirty, isFalse, reason: 'no edits yet');
      expect(h.rowCount, 3);
      expect(h.fieldValue(2), 'val');

      // Invalid write -> invalid + dirty.
      h.setField(2, 'no');
      expect(h.fieldValue(2), 'no');
      expect(h.isDirty, isTrue);
      expect(h.isValid, isFalse, reason: 'min length 3');

      // Fix it -> valid again (still dirty).
      h.setField(2, 'yes ok');
      expect(h.isValid, isTrue);
      expect(h.isDirty, isTrue);

      // Rows: seeded 3 rows * 1 night = 3 <= maxNights 5 -> valid.
      // Add two more rows -> 5 nights, still ok; a sixth tips it over.
      h.addRow(const RowData(city: 'A', nights: 1));
      h.addRow(const RowData(city: 'B', nights: 1));
      expect(h.rowCount, 5);
      expect(h.isValid, isTrue, reason: '5 nights == maxNights');

      h.addRow(const RowData(city: 'C', nights: 1));
      expect(h.isValid, isFalse, reason: '6 > maxNights 5');

      h.removeRow(h.rowCount - 1);
      expect(h.rowCount, 5);
      expect(h.isValid, isTrue, reason: 'back under the cap');
    });
  }
}
