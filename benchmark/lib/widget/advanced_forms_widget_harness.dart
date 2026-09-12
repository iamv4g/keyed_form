import 'package:advanced_forms/advanced_forms.dart';
import 'package:flutter/material.dart';

import '../scenario.dart';
import 'widget_harness.dart';

/// `advanced_forms`: one [AdvancedFieldBuilder] + [TextField] per flat field,
/// each bound to its own `AdvancedTextFieldController` (which owns the
/// `TextEditingController`), registered on one root `AdvancedFormController`.
class AdvancedFormsWidgetHarness extends WidgetHarness {
  AdvancedFormController? _form;

  @override
  String get name => 'advanced_forms';

  @override
  Widget build(Scenario scenario) {
    final fields = [
      for (var i = 0; i < scenario.fieldCount; i++)
        AdvancedTextFieldController<String>(
          initialValue: 'val',
          validator: filled('required') & atLeastLength(3, 'min3'),
        ),
    ];
    final form = AdvancedFormController(
      validationMode: ValidationMode.onUserInteraction,
    )..registerFields(fields);
    _form = form;
    return SingleChildScrollView(
      child: Column(
        children: [
          for (var i = 0; i < scenario.fieldCount; i++)
            AdvancedFieldBuilder<String, String>(
              key: ValueKey('bench_field_$i'),
              field: fields[i],
              builder: (context, state, _) => TextField(
                controller: fields[i].textController,
                decoration: InputDecoration(errorText: state.error),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool isDirty() => _form?.value.wasModified ?? false;
}
