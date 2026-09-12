import 'package:flutter/material.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

import '../tour_builder/tour_builder_screen.dart';
import '../widgets/demo_scaffold.dart';
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

  // Stands in for a server round-trip ("is this email already registered?")
  // — the case `isValidating` exists for: a field's own async validation,
  // outside the synchronous `resolver`. 'error@example.com' stands in for the
  // check itself failing (a dropped connection, a 500) — the case
  // `isFailedValidation` exists for, distinct from the value being invalid.
  Future<String?> _checkEmailTaken(String email) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final trimmed = email.trim().toLowerCase();
    if (trimmed == 'error@example.com') {
      throw Exception('email lookup failed');
    }
    return trimmed == 'taken@example.com'
        ? 'This email is already registered'
        : null;
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
    return DemoScaffold(
      title: 'Sign in',
      maxWidth: 380,
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
            KeyedFormField.text<LoginSchema>(
              field: LoginFields.email,
              builder: (context, f, controller) {
                void checkEmail() {
                  f.onBlur();
                  form
                      .field(LoginFields.email)
                      .validateAsync(
                        () => _checkEmailTaken(f.value ?? ''),
                        timeout: const Duration(seconds: 5),
                      );
                }

                return TextField(
                  controller: controller,
                  onTapOutside: (_) => checkEmail(),
                  onSubmitted: (_) => checkEmail(),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: f.errorText,
                    helperText: f.isFailedValidation
                        ? "Couldn't verify this email — try again."
                        : null,
                    border: const OutlineInputBorder(),
                    suffixIcon: f.isValidating
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : f.isFailedValidation
                        ? const Icon(Icons.warning_amber_rounded)
                        : null,
                  ),
                );
              },
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
    );
  }
}
