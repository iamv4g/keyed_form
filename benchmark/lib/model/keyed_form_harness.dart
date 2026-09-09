import 'package:keyed_form/keyed_form.dart';

import '../kf_form.dart';
import '../scenario.dart';
import 'model_harness.dart';

/// [ModelHarness] for `keyed_form`.
///
/// [scoped] toggles `scopeOf`: when false the resolver re-runs every rule on
/// every write (the simplest wiring); when true a flat-field write only
/// re-validates that one field, matching reactive_forms' per-control model.
class KeyedFormHarness extends ModelHarness {
  KeyedFormHarness({this.scoped = false});

  final bool scoped;
  late KeyedFormController<KfDraft> _form;

  @override
  String get name => scoped ? 'keyed_form (scoped)' : 'keyed_form (whole)';

  @override
  void build(Scenario scenario) =>
      _form = buildKfController(scenario, scoped: scoped);

  @override
  void setField(int index, String value) =>
      _form.field(kfFieldRef(index)).set(value);

  @override
  void addRow(RowData row) => _form.field(kfRowsRef).list().append(
        KfRow(
          clientId: 'r${DateTime.now().microsecondsSinceEpoch}',
          city: row.city,
          nights: row.nights,
        ),
      );

  @override
  void removeRow(int index) {
    final rows = kfRowsRef.getOrNull(_form.value) ?? const [];
    if (index < 0 || index >= rows.length) return;
    _form.field(kfRowsRef).list().removeById(rows[index].clientId);
  }

  @override
  bool get isValid => _form.errors.isEmpty;

  @override
  bool get isDirty => _form.isDirty;

  @override
  String fieldValue(int index) =>
      _form.field(kfFieldRef(index)).value ?? '';

  @override
  int get rowCount => (kfRowsRef.getOrNull(_form.value) ?? const []).length;

  @override
  void dispose() => _form.dispose();
}
