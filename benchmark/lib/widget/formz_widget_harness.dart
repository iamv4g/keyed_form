import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../formz_model.dart';
import '../scenario.dart';
import 'widget_harness.dart';

/// `formz` ships **no** widget layer, so this is the idiomatic pairing from
/// formz's own example: a `flutter_bloc` cubit holds the `FormzInput` state
/// and each field is a plain `TextField` wrapped in a [BlocSelector] on its
/// own slice.
///
/// The rebuild granularity measured here is therefore **`flutter_bloc`'s** —
/// `BlocSelector` re-runs its `selector` on every emit (O(N) selector calls,
/// like `keyed_form`'s listener fan-out) but only rebuilds the field whose
/// selected `FlatInput` actually changed by `==`. `formz` contributes only
/// the validation model. A naïve whole-state `BlocBuilder` around the column
/// would instead be O(N) rebuilds — the same trap `flutter_form_builder`
/// falls into structurally.
class FormzWidgetHarness extends WidgetHarness {
  _FieldsCubit? _cubit;

  @override
  String get name => 'formz + flutter_bloc';

  @override
  Widget build(Scenario scenario) {
    final cubit = _FieldsCubit(scenario.fieldCount);
    _cubit = cubit;
    return BlocProvider<_FieldsCubit>.value(
      value: cubit,
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (var i = 0; i < scenario.fieldCount; i++)
              _FieldView(key: ValueKey('bench_row_$i'), index: i),
          ],
        ),
      ),
    );
  }

  @override
  bool isDirty() {
    final state = _cubit?.state;
    return state != null && state.any((f) => !f.isPure);
  }
}

/// State is the flat `List<FlatInput>`; `emit` gets a fresh list each write so
/// bloc never de-dupes it, and `BlocSelector` does the per-field diffing.
class _FieldsCubit extends Cubit<List<FlatInput>> {
  _FieldsCubit(int count)
      : super(List<FlatInput>.filled(count, const FlatInput.pure('val')));

  void setField(int index, String value) {
    emit([...state]..[index] = FlatInput.dirty(value));
  }
}

class _FieldView extends StatelessWidget {
  const _FieldView({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<_FieldsCubit, List<FlatInput>, FlatInput>(
      selector: (state) => state[index],
      builder: (context, field) => TextField(
        key: ValueKey('bench_field_$index'),
        onChanged: (v) => context.read<_FieldsCubit>().setField(index, v),
        decoration: InputDecoration(
          errorText: field.displayError == null ? null : 'invalid',
        ),
      ),
    );
  }
}
