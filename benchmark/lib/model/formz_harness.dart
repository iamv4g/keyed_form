import 'package:formz/formz.dart';

import '../formz_model.dart';
import '../scenario.dart';
import 'model_harness.dart';

/// [ModelHarness] for `formz` (Very Good Ventures) — the typed, Bloc-native,
/// model-only competitor. It is the philosophical neighbour of `keyed_form`:
/// one immutable state object, typed fields, pure Dart, no widget layer.
///
/// formz does **no** automatic recomputation. You rebuild the state object
/// yourself on every change (in a Bloc that is `emit(state.copyWith(...))`)
/// and read validity off [FormzMixin.isValid], which re-runs every input's
/// `validator` on each access — there is no cache unless the input mixes in
/// `FormzInputErrorCacheMixin`. So relative to the other harnesses the cost
/// moves: [setField] is just a list copy + one object (no validation), and
/// the O(N) validator pass lands on [isValid].
///
/// The cross-field `sum(nights) <= maxNights` rule is not expressible as a
/// `FormzInput`, so it is checked outside `isValid` — the same shape as
/// reactive_forms' group-level delegate validator.
class FormzHarness extends ModelHarness {
  late _FormzForm _form;
  late int _maxNights;
  late int _seedRowCount;

  @override
  String get name => 'formz';

  @override
  void build(Scenario scenario) {
    _maxNights = scenario.maxNights;
    final seeded = seedRows(scenario.rowCount);
    _seedRowCount = seeded.length;
    _form = _FormzForm(
      [
        for (var i = 0; i < scenario.fieldCount; i++)
          const FlatInput.pure('val'),
      ],
      [for (final r in seeded) _RowInput(CityInput.pure(r.city), r.nights)],
    );
  }

  @override
  void setField(int index, String value) {
    final next = [..._form.fields]..[index] = FlatInput.dirty(value);
    _form = _FormzForm(next, _form.rows);
  }

  @override
  void addRow(RowData row) => _form = _FormzForm(_form.fields, [
    ..._form.rows,
    _RowInput(CityInput.dirty(row.city), row.nights),
  ]);

  @override
  void removeRow(int index) {
    if (index < 0 || index >= _form.rows.length) return;
    _form = _FormzForm(_form.fields, [..._form.rows]..removeAt(index));
  }

  int get _totalNights => _form.rows.fold(0, (sum, r) => sum + r.nights);

  @override
  bool get isValid => _form.isValid && _totalNights <= _maxNights;

  @override
  bool get isDirty =>
      _form.rows.length != _seedRowCount ||
      _form.fields.any((f) => !f.isPure) ||
      _form.rows.any((r) => !r.city.isPure);

  @override
  String fieldValue(int index) => _form.fields[index].value;

  @override
  int get rowCount => _form.rows.length;
}

class _RowInput {
  const _RowInput(this.city, this.nights);
  final CityInput city;
  final int nights;
}

/// The hand-rolled state object — in a real app this is the Bloc/Cubit state
/// with a `copyWith`. `nights` carries no per-field rule, so only the `city`
/// inputs join [inputs]; the total-nights rule lives in the harness.
class _FormzForm with FormzMixin {
  _FormzForm(this.fields, this.rows);
  final List<FlatInput> fields;
  final List<_RowInput> rows;

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [
    ...fields,
    for (final r in rows) r.city,
  ];
}
