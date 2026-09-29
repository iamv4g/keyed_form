import 'package:flutter/material.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

import 'login_schema.dart';

part 'login_text_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key, this.onSignedIn});

  final void Function(LoginSchema value)? onSignedIn;

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
          const SizedBox(height: 16),
          _LoginTextField(
            field: LoginFields.password,
            label: 'Password',
            obscureText: true,
          ),
          const SizedBox(height: 16),
          // handleSubmit needs a context below KeyedForm.
          Builder(
            builder: (context) => FilledButton(
              onPressed: () => form.handleSubmit(
                context,
                (value) => widget.onSignedIn?.call(value),
              ),
              child: const Text('Sign in'),
            ),
          ),
        ],
      ),
    );
  }
}
