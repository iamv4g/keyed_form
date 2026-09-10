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
/// [scoped] toggles the generated `Bench100Schema.scopeOf` — a scoped
/// controller re-validates only the written field instead of walking all 100.
class KeyedFormCodegenHarness extends ModelHarness {
  KeyedFormCodegenHarness({this.scoped = false});

  /// When true, wire the generated `scopeOf` so a write re-validates only its
  /// own field instead of the whole 100-field schema.
  final bool scoped;
  late KeyedFormController<Bench100Schema> _form;

  static const supported = Scenario(fieldCount: 100);

  @override
  String get name => scoped ? 'keyed_form_gen (scoped)' : 'keyed_form_gen';

  @override
  void build(Scenario scenario) {
    assert(
      scenario.fieldCount == 100 && scenario.rowCount == 0,
      'the codegen harness is fixed to $supported',
    );
    _form = KeyedFormController<Bench100Schema>(
      initialValue: benchSeed(),
      mode: KeyedFormMode.onChange,
      resolver: Bench100Schema.validateData,
      scopeOf: scoped ? Bench100Schema.scopeOf : null,
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
