import 'package:advanced_forms/advanced_forms.dart';

import '../scenario.dart';
import 'model_harness.dart';

/// One dynamic-list row: its own subform (the library's own recommended
/// pattern for a list of fields — there is no `FormArray` equivalent), with a
/// `city` text field and a `nights` int field.
class _Row {
  _Row(this.form, this.city, this.nights);

  final AdvancedFormController form;
  final AdvancedTextFieldController<String> city;
  final AdvancedFieldController<int, String> nights;
}

/// [ModelHarness] for `advanced_forms`. Flat fields are
/// `AdvancedTextFieldController`s registered on the root form; rows are
/// subforms (`addSubform`/`removeSubform`), the library's own pattern for a
/// dynamic list. The cross-row "total nights" rule has no group-level-
/// validator equivalent here, so it is modelled the way the library's own
/// docs recommend for a derived value: a hidden field on the root
/// (`_totalNights`) that the harness keeps in sync on every row change, the
/// same role `addRelation` plays in a real app.
class AdvancedFormsHarness extends ModelHarness {
  late AdvancedFormController _root;
  late List<AdvancedTextFieldController<String>> _flatFields;
  late AdvancedFieldController<int, String> _totalNights;
  late List<_Row> _rows;
  late int _maxNights;

  @override
  String get name => 'advanced_forms';

  @override
  void build(Scenario scenario) {
    _maxNights = scenario.maxNights;
    _root = AdvancedFormController(
      validationMode: ValidationMode.onUserInteraction,
    );
    _flatFields = [
      for (var i = 0; i < scenario.fieldCount; i++)
        AdvancedTextFieldController<String>(
          initialValue: 'val',
          validator: filled('required') & atLeastLength(3, 'min3'),
        ),
    ];
    _rows = [
      for (final r in seedRows(scenario.rowCount)) _makeRow(r.city, r.nights),
    ];
    _totalNights = AdvancedFieldController<int, String>(
      initialValue: _sumNights(),
      validator: (total) => total > _maxNights ? 'tooLong' : null,
    );
    _root.registerFields([..._flatFields, _totalNights]);
    for (final row in _rows) {
      _root.addSubform(row.form);
    }
  }

  _Row _makeRow(String city, int nights) {
    final cityField = AdvancedTextFieldController<String>(
      initialValue: city,
      validator: filled('required'),
    );
    final nightsField = AdvancedFieldController<int, String>(
      initialValue: nights,
    );
    final form = AdvancedFormController(
      validationMode: ValidationMode.onUserInteraction,
    )..registerFields([cityField, nightsField]);
    return _Row(form, cityField, nightsField);
  }

  int _sumNights() =>
      _rows.fold(0, (sum, row) => sum + row.nights.fieldValue);

  @override
  void setField(int index, String value) => _flatFields[index].setValue(value);

  @override
  void addRow(RowData row) {
    final r = _makeRow(row.city, row.nights);
    _rows.add(r);
    _root.addSubform(r.form);
    _totalNights.setValue(_sumNights());
  }

  @override
  void removeRow(int index) {
    if (index < 0 || index >= _rows.length) return;
    final r = _rows.removeAt(index);
    _root.removeSubform(r.form);
    r.form.dispose();
    _totalNights.setValue(_sumNights());
  }

  @override
  bool get isValid => _root.value.canSubmit;

  @override
  bool get isDirty => _root.value.wasModified;

  @override
  String fieldValue(int index) => _flatFields[index].fieldValue;

  @override
  int get rowCount => _rows.length;

  @override
  void dispose() => _root.dispose();
}
