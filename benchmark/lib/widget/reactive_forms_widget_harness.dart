import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../scenario.dart';
import 'widget_harness.dart';

/// `reactive_forms`: one [ReactiveTextField] per flat field under a
/// [ReactiveForm]. Each field subscribes to its own `FormControl` stream and
/// rebuilds only itself.
class ReactiveFormsWidgetHarness extends WidgetHarness {
  FormGroup? _form;

  @override
  String get name => 'reactive_forms';

  @override
  Widget build(Scenario scenario) {
    final form = FormGroup({
      for (var i = 0; i < scenario.fieldCount; i++)
        Scenario.fieldName(i): FormControl<String>(
          value: 'val',
          validators: [Validators.required, Validators.minLength(3)],
        ),
    });
    _form = form;
    return ReactiveForm(
      formGroup: form,
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (var i = 0; i < scenario.fieldCount; i++)
              ReactiveTextField<String>(
                key: ValueKey('bench_field_$i'),
                formControlName: Scenario.fieldName(i),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool isDirty() => _form?.dirty ?? false;
}
