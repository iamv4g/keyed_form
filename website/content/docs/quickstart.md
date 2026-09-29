---
title: Quickstart
description: Define a schema, generate typed fields, then connect them to a Flutter form.
---

This short path creates a validated login form. The [complete example](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form_flutter/example/lib/login) includes the extracted field widget and submit handling.

## 1. Install

```sh
flutter pub add keyed_form_flutter keyed_form_schema
flutter pub add -d keyed_form_gen build_runner
```

## 2. Define the schema

```dart
@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'login_schema.kfg.dart';

final _loginSchema = ks.object({
  'email': ks.string().email(error: .text('Enter a valid email')),
  'password': ks.string().min(8, error: .text('Use at least 8 characters')),
});
```

## 3. Generate the typed model

```sh
dart run build_runner build -d
```

Commit the generated `*.kfg.dart` file. Generation happens during development, never at runtime.

## 4. Connect the form

```dart
final form = KeyedFormController<LoginSchema>(
  initialValue: LoginSchema.create(),
  mode: KeyedFormMode.onChange,
  resolver: LoginSchema.validateData,
);
```

Wrap the fields in `KeyedForm<LoginSchema>` and use `KeyedFormField.text` with `LoginFields.email` and `LoginFields.password`. Dispose the controller with the owning state, and submit through `form.handleSubmit(context, onValid)`.

<ExampleCode id="quickstart-login" files="login/login_schema.dart login/login_form.dart login/login_text_field.dart" />

See [installation](docs/installation) for requirements and generator watch mode.
