import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../scenario.dart';
import 'widget_harness.dart';

/// `flutter_form_builder`: one [FormBuilderTextField] per flat field under a
/// [FormBuilder]. Fields save into the shared `FormBuilderState`.
class FormBuilderWidgetHarness extends WidgetHarness {
  final _key = GlobalKey<FormBuilderState>();

  @override
  String get name => 'flutter_form_builder';

  @override
  Widget build(Scenario scenario) {
    return FormBuilder(
      key: _key,
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (var i = 0; i < scenario.fieldCount; i++)
              FormBuilderTextField(
                key: ValueKey('bench_field_$i'),
                name: Scenario.fieldName(i),
                initialValue: 'val',
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(3),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool isDirty() => _key.currentState?.isDirty ?? false;
}
