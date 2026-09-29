import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:keyed_form/keyed_form.dart';

import '../../demos/login_schema.dart';
import 'observed_field.dart';

final _jsonEncoder = JsonEncoder.withIndent('  ');

@client
class ModelLoginDemo extends StatefulComponent {
  const ModelLoginDemo({super.key});

  @override
  State<ModelLoginDemo> createState() => _ModelLoginDemoState();
}

class _ModelLoginDemoState extends State<ModelLoginDemo> {
  late final form = KeyedFormController<LoginSchema>(
    initialValue: LoginSchema.create(),
    mode: KeyedFormMode.onTouched,
    resolver: LoginSchema.validateData,
  );

  String? _signedInAs;

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await form.submit((value) {
      setState(() => _signedInAs = value.email);
    });
  }

  Component _input(InputType type, String? value, ValueChanged<String> onChange, VoidCallback onBlur) {
    return input<String>(
      type: type,
      classes: 'playground-input',
      attributes: {'autocomplete': 'off'},
      value: value ?? '',
      onInput: (v) {
        if (_signedInAs != null) setState(() => _signedInAs = null);
        onChange(v);
      },
      events: {'blur': (_) => onBlur()},
    );
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'model-demo', [
      div(classes: 'model-demo-form blueprint-box', [
        div(classes: 'playground-panel-title mono', [.text('// RUNNING — submit it empty')]),
        ObservedField<LoginSchema, String>(
          form: form,
          field: LoginFields.email,
          label: 'Email',
          showRebuilds: false,
          builder: (value, onChange, onBlur) => _input(InputType.email, value, onChange, onBlur),
        ),
        ObservedField<LoginSchema, String>(
          form: form,
          field: LoginFields.password,
          label: 'Password',
          showRebuilds: false,
          builder: (value, onChange, onBlur) => _input(InputType.password, value, onChange, onBlur),
        ),
        div(classes: 'demo-actions', [
          button(
            type: ButtonType.button,
            classes: 'btn btn-cyan mono',
            onClick: _submit,
            [.text('Sign in')],
          ),
          if (_signedInAs != null) span(classes: 'demo-status mono', [.text('✓ valid — would sign in $_signedInAs')]),
        ]),
      ]),
      ObserverPanel<LoginSchema>(
        form: form,
        title: '// WATCH — form.value.toMap()',
        render: (f) => _jsonEncoder.convert(f.value.toMap()),
      ),
      ObserverPanel<LoginSchema>(
        form: form,
        title: '// ERRORS — form.visibleErrorKeys',
        render: (f) => f.visibleErrorKeys.isEmpty
            ? '{}'
            : _jsonEncoder.convert({
                for (final key in f.visibleErrorKeys) key.toPath(): f.errors.byKey(key),
              }),
      ),
    ]);
  }
}
