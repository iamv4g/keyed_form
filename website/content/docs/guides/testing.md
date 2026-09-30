---
title: Testing
description: Test schema and controller behavior with plain Dart, and use Flutter widget tests for UI interactions.
---

The controller and schema do not need a mounted widget tree. Use `package:test` for validation, draft changes, dirty state, list operations, relations, and submission. Reserve Flutter widget tests for rendered behavior and interaction such as focus, keyboard handling, and field binding.

## Test shared behavior with package:test

A plain-Dart controller test can assert that invalid data blocks the callback and makes the relevant error visible:

```dart
test('invalid email prevents submit', () async {
  final form = KeyedFormController<LoginSchema>(
    initialValue: LoginSchema.create(),
    mode: KeyedFormMode.onTouched,
    resolver: LoginSchema.validateData,
  );

  form.field(LoginFields.email).set('not-an-email');
  final success = await form.submit((draft) async => save(draft));

  expect(success, isFalse);
  expect(form.visibleErrorFor(LoginFields.email), isNotNull);
});
```

Keep these tests focused on observable state transitions and outcomes: valid versus invalid values, edits against a baseline, row identity after list changes, relation updates, and whether a submit callback runs. The same schema validator can be used by a Flutter form.

## Test widgets at the UI boundary

Use `testWidgets` for rendering, focus, keyboard behavior, and actual user interaction. The repository's runnable Flutter example tests are in [`packages/keyed_form_flutter/example/test`](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form_flutter/example/test); its tests exercise the login, packing-list, and other example screens. For framework-independent behavior, run package tests such as [`packages/keyed_form/test`](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form/test).

The controller supports disposal and snapshots as pure-Dart APIs; widget tests are not required simply to exercise those state behaviors. See [Form State](docs/form-state) and the [Flutter guide](docs/flutter) for the two layers.
