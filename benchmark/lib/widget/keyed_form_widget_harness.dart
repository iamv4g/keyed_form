import 'package:flutter/material.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

import '../kf_form.dart';
import '../scenario.dart';
import 'widget_harness.dart';

/// `keyed_form_flutter`: one [KeyedFormField] per flat field under a
/// [KeyedForm]. Each field subscribes to the controller and rebuilds
/// only itself when its own value/error changes.
class KeyedFormWidgetHarness extends WidgetHarness {
  KeyedFormWidgetHarness({this.scoped = false});
  final bool scoped;
  KeyedFormController<KfDraft>? _controller;

  @override
  String get name => 'keyed_form_flutter';

  @override
  Widget build(Scenario scenario) {
    final controller = buildKfController(scenario, scoped: scoped);
    _controller = controller;
    return KeyedForm<KfDraft>(
      controller: controller,
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (var i = 0; i < scenario.fieldCount; i++)
              KeyedFormField.text<KfDraft>(
                key: ValueKey('bench_row_$i'),
                field: kfFieldRef(i),
                anchor: false,
                builder: (context, state, textController) => TextField(
                  key: ValueKey('bench_field_$i'),
                  controller: textController,
                  onChanged: state.onChanged,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool isDirty() => _controller?.isDirty ?? false;
}
