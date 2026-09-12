import 'package:reactive_forms/reactive_forms.dart';

import '../scenario.dart';
import 'model_harness.dart';

/// [ModelHarness] for `reactive_forms`. Flat fields are `FormControl<String>`
/// with `required` + `minLength(3)`; rows are a `FormArray<Map>` of
/// `FormGroup`s; the cross-field rule is a group-level delegate validator.
class ReactiveFormsHarness extends ModelHarness {
  late FormGroup _form;
  late int _maxNights;

  @override
  String get name => 'reactive_forms';

  @override
  void build(Scenario scenario) {
    _maxNights = scenario.maxNights;
    final seeded = seedRows(scenario.rowCount);
    _form = FormGroup(
      {
        for (var i = 0; i < scenario.fieldCount; i++)
          Scenario.fieldName(i): FormControl<String>(
            value: 'val',
            validators: [Validators.required, Validators.minLength(3)],
          ),
        'rows': FormArray<Map<String, Object?>>([
          for (final r in seeded) _rowGroup(r.city, r.nights),
        ]),
      },
      validators: [Validators.delegate(_totalNights)],
    );
  }

  FormGroup _rowGroup(String city, int nights) => FormGroup({
    'city': FormControl<String>(value: city, validators: [Validators.required]),
    'nights': FormControl<int>(value: nights),
  });

  Map<String, dynamic>? _totalNights(AbstractControl<dynamic> control) {
    final rows = (control as FormGroup).control('rows') as FormArray;
    var total = 0;
    for (final row in rows.controls) {
      total += ((row as FormGroup).control('nights').value as int?) ?? 0;
    }
    return total > _maxNights ? {'tooLong': true} : null;
  }

  FormArray get _rows => _form.control('rows') as FormArray;

  @override
  void setField(int index, String value) {
    // A programmatic updateValue leaves the control pristine; the reactive
    // widgets mark it dirty on user input, so mirror that here.
    _form.control(Scenario.fieldName(index))
      ..updateValue(value)
      ..markAsDirty();
  }

  @override
  void addRow(RowData row) => _rows.add(_rowGroup(row.city, row.nights));

  @override
  void removeRow(int index) {
    if (index < 0 || index >= _rows.controls.length) return;
    _rows.removeAt(index);
  }

  @override
  bool get isValid => _form.valid;

  @override
  bool get isDirty => _form.dirty;

  @override
  String fieldValue(int index) =>
      _form.control(Scenario.fieldName(index)).value as String? ?? '';

  @override
  int get rowCount => _rows.controls.length;
}
