import 'package:keyed_form/keyed_form.dart';

import '../codegen/bench_refs.dart';
import '../codegen/bench_schema.dart';
import '../scenario.dart';
import 'model_harness.dart';

/// [ModelHarness] backed by a **real `keyed_form_gen` model** — the generated
/// `Bench100Schema` class, its `Bench100Fields` refs, and
/// `Bench100Schema.validateData`.
///
/// Fixed at 100 flat fields, no rows: it exists to calibrate the
/// parameterised, list-backed `KeyedFormHarness` (which uses a hand-written
/// resolver) against the shape and validation path real users get from
/// codegen.
///
/// Note there is no scoped variant: `validateData` round-trips the whole
/// object through `toMap()` and the `ks.*` schema on **every** write — a
/// generated model cannot re-validate just one subtree, so per-write cost is
/// inherently O(fields). Scoped validation means dropping to a hand-written
/// resolver.
class KeyedFormCodegenHarness extends ModelHarness {
  late KeyedFormController<Bench100Schema> _form;

  static const supported = Scenario(fieldCount: 100);

  @override
  String get name => 'keyed_form_gen';

  @override
  void build(Scenario scenario) {
    assert(
      scenario.fieldCount == 100 && scenario.rowCount == 0,
      'the codegen harness is fixed to $supported',
    );
    _form = KeyedFormController<Bench100Schema>(
      initialValue: benchSeed(),
      mode: KeyedFormMode.onChange,
      resolver: (draft, _) => Bench100Schema.validateData(draft),
    );
  }

  @override
  void setField(int index, String value) =>
      _form.field(bench100Refs[index]).set(value);

  @override
  void addRow(RowData row) => throw UnsupportedError('codegen harness is flat');

  @override
  void removeRow(int index) => throw UnsupportedError('codegen harness is flat');

  @override
  bool get isValid => _form.errors.isEmpty;

  @override
  bool get isDirty => _form.isDirty;

  @override
  String fieldValue(int index) => _form.field(bench100Refs[index]).value ?? '';

  @override
  int get rowCount => 0;

  @override
  void dispose() => _form.dispose();
}
