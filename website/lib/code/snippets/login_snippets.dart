/// The three files the Model section shows — a trimmed version of
/// `packages/keyed_form_flutter/example/lib/login/`. Plain strings, not
/// compiled here: when the Flutter API changes, re-check them by dropping
/// the last two into the example app and running `flutter analyze`.
abstract final class LoginSnippets {
  static const schema = r'''@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'login_schema.kfg.dart';

final _loginSchema = ks.object({
  'email': ks
      .string(error: .text('Enter your email'))
      .email(error: .text('That does not look like an email')),
  'password': ks
      .string(error: .text('Enter your password'))
      .min(8, error: .text('At least 8 characters')),
});''';

  static const form = r'''import 'package:flutter/material.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

import 'login_schema.dart';

part 'login_text_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final form = KeyedFormController<LoginSchema>(
    initialValue: LoginSchema.create(),
    mode: KeyedFormMode.onTouched,
    resolver: LoginSchema.validateData,
  );

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedForm<LoginSchema>(
      controller: form,
      child: Column(
        children: [
          _LoginTextField(field: LoginFields.email, label: 'Email'),
          _LoginTextField(
            field: LoginFields.password,
            label: 'Password',
            obscureText: true,
          ),
          // handleSubmit needs a context below KeyedForm.
          Builder(
            builder: (context) => FilledButton(
              onPressed: () => form.handleSubmit(context, (value) async {
                // value is a LoginSchema that passed validation.
              }),
              child: const Text('Sign in'),
            ),
          ),
        ],
      ),
    );
  }
}''';

  static const textField = r'''part of 'login_form.dart';

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    required this.field,
    required this.label,
    this.obscureText = false,
  });

  final FieldRef<LoginSchema, String> field;
  final String label;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return KeyedFormField.text<LoginSchema>(
      field: field,
      builder: (context, f, controller) => TextField(
        controller: controller,
        obscureText: obscureText,
        onTapOutside: (_) => f.onBlur(),
        decoration: InputDecoration(
          labelText: label,
          errorText: f.errorText,
        ),
      ),
    );
  }
}''';
}
