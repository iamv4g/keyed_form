import '../scenario.dart';

/// The library-agnostic surface the model-layer benchmarks drive. "Model
/// layer" = no widgets: just the form-state object doing copy / validate /
/// diff / notify work.
///
/// `flutter_form_builder` has no model layer (it is widget-only), so it does
/// not implement this — see `widget/` for its comparison.
abstract class ModelHarness {
  String get name;

  /// Builds a fresh form for [scenario]. Every flat field starts at a valid
  /// value ('val'); rows start as [seedRows].
  void build(Scenario scenario);

  /// Writes [value] to flat field [index] and performs whatever the library
  /// does synchronously on a value change (revalidation for on-change libs,
  /// dirty tracking, listener notification).
  void setField(int index, String value);

  /// Appends one row to the dynamic list.
  void addRow(RowData row);

  /// Removes the row at [index].
  void removeRow(int index);

  /// Whole-form validity right now.
  bool get isValid;

  /// Whole-form dirty state versus the just-built baseline.
  bool get isDirty;

  /// Current value of flat field [index] — for parity assertions.
  String fieldValue(int index);

  /// Number of rows right now — for parity assertions.
  int get rowCount;

  void dispose() {}
}
