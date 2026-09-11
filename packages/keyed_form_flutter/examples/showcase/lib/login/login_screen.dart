import 'package:flutter/material.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

import '../fields.dart';
import '../tour_builder/tour_builder_screen.dart';
import 'login_schema.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  // `context` must come from inside the `KeyedForm` subtree (a builder's own
  // context, e.g. `KeyedFormSelector`'s or `KeyedFormField`'s) — not this
  // State's own `context`, which sits above `KeyedForm` in the tree built
  // below. Same rule as Flutter's own `Form.of(context)`.
  Future<void> _signIn(BuildContext context) async {
    await form.handleSubmit(context, (value) async {
      await Future.delayed(const Duration(milliseconds: 600)); // simulate auth
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TourBuilderScreen(email: value.email),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: KeyedForm<LoginSchema>(
            controller: form,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'keyed_form_flutter',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Sign in, then build a tour.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                KeyedText<LoginSchema>(
                  field: LoginFields.email,
                  label: 'Email',
                ),
                const SizedBox(height: 16),
                KeyedFormField.text<LoginSchema>(
                  field: LoginFields.password,
                  builder: (context, f, controller) => TextField(
                    controller: controller,
                    obscureText: true,
                    onTapOutside: (_) => f.onBlur(),
                    onSubmitted: (_) => _signIn(context),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: f.errorText,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                KeyedFormField<LoginSchema, bool>(
                  field: LoginFields.remember,
                  anchor: false,
                  builder: (context, f) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('Remember me'),
                    value: f.value ?? false,
                    onChanged: (value) => f.onChanged(value ?? false),
                  ),
                ),
                const SizedBox(height: 16),
                KeyedFormSelector<LoginSchema, bool>(
                  selector: (f) => f.submitting,
                  builder: (context, submitting, _) => FilledButton(
                    onPressed: submitting ? null : () => _signIn(context),
                    child: submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign in'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
