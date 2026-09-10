import 'package:formz/formz.dart';

/// The `FormzInput`s for the benchmark scenario, shared by the model harness
/// (`model/formz_harness.dart`) and the widget harness
/// (`widget/formz_widget_harness.dart`).
///
/// One class + one error enum per distinct field shape is the formz idiom —
/// that hand-written-per-field cost is itself a DX datapoint.

enum FlatError { empty, tooShort }

/// One flat text field: required + minLength(3).
class FlatInput extends FormzInput<String, FlatError> {
  const FlatInput.pure(super.value) : super.pure();
  const FlatInput.dirty(super.value) : super.dirty();

  @override
  FlatError? validator(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return FlatError.empty;
    if (trimmed.length < 3) return FlatError.tooShort;
    return null;
  }
}

enum CityError { empty }

/// A row's city field: required.
class CityInput extends FormzInput<String, CityError> {
  const CityInput.pure(super.value) : super.pure();
  const CityInput.dirty(super.value) : super.dirty();

  @override
  CityError? validator(String value) =>
      value.trim().isEmpty ? CityError.empty : null;
}
