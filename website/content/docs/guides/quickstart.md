---
title: Quickstart
description: Define a login schema, generate typed fields, and connect the model to a Flutter form.
---

This walkthrough follows the working login example: schema source, generated part, controller, descendant-context submission, and controller disposal. The full app also extracts its text field widget into a separate source file.

## Define and generate the schema

```dart
@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'login_schema.kfg.dart';

final _loginSchema = ks.object({
  'email': ks.string(error: .text('Enter your email'))
      .email(error: .text('That does not look like an email')),
  'password': ks.string(error: .text('Enter your password'))
      .min(8, error: .text('At least 8 characters')),
});
```

Add the schema/runtime dependencies and generator as described in [Installation](docs/guides/installation), then run `dart run build_runner build -d`. The `@keyedSchema` library annotation and matching part declaration are required for the generated file.

## Connect the controller and widgets

```dart
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
```

Place the fields beneath `KeyedForm<LoginSchema>(controller: form, ...)` and bind them to `LoginFields.email` and `LoginFields.password`. `handleSubmit` needs a `BuildContext` below that `KeyedForm`; use a `Builder` when the button is declared alongside the scope:

```dart
Builder(
  builder: (context) => FilledButton(
    onPressed: () => form.handleSubmit(
      context,
      (value) => onSignedIn(value),
    ),
    child: const Text('Sign in'),
  ),
)
```

The submission callback runs only for a valid form. The owner disposes the controller when its state is removed. `KeyedFormMode.onTouched` matches the embedded example: an error becomes visible after interaction rather than immediately on initial render.

<ExampleCode id="quickstart-login" files="login/login_schema.dart login/login_form.dart login/login_text_field.dart" />

Continue with [Form State](docs/form-state) for controller behavior and [Flutter](docs/flutter) for binding details.
