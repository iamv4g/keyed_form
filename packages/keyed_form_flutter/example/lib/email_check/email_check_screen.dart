import 'package:flutter/material.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

import '../widgets/demo_note.dart';
import '../widgets/demo_scaffold.dart';
import 'email_check_schema.dart';

class EmailCheckScreen extends StatefulWidget {
  const EmailCheckScreen({super.key});

  @override
  State<EmailCheckScreen> createState() => _EmailCheckScreenState();
}

class _EmailCheckScreenState extends State<EmailCheckScreen> {
  final form = KeyedFormController<EmailCheckSchema>(
    initialValue: EmailCheckSchema.create(),
    mode: KeyedFormMode.onTouched,
    resolver: EmailCheckSchema.validateData,
  );

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  // Stands in for a server round-trip. 'error@example.com' stands in for the
  // check itself failing — `isFailedValidation`, distinct from an invalid value.
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

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Email check',
      maxWidth: 380,
      child: KeyedForm<EmailCheckSchema>(
        controller: form,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const DemoNote(
              'Leave the field to run a server check. Try taken@example.com '
              '(already registered) and error@example.com (the check itself '
              'fails).',
            ),
            const SizedBox(height: 24),
            KeyedFormField.text<EmailCheckSchema>(
              field: EmailCheckFields.email,
              builder: (context, f, controller) {
                void checkEmail() {
                  f.onBlur();
                  form
                      .field(EmailCheckFields.email)
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
          ],
        ),
      ),
    );
  }
}
