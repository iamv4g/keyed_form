---
title: Testing
description: Exercise schema validation, dirty state, and submission with plain Dart tests.
---

The controller is independent of the widget tree, so schema and form behavior can be tested with `package:test`. Reserve widget tests for Flutter presentation and interaction.

```dart
test('invalid email prevents submit', () async {
  final form = KeyedFormController<LoginSchema>(
    initialValue: LoginSchema.create(),
    mode: KeyedFormMode.onChange,
    resolver: LoginSchema.validateData,
  );

  form.field(LoginFields.email).set('not-an-email');
  expect(form.isDirty, isTrue);

  final success = await form.submit((draft) async => save(draft));
  expect(success, isFalse);
  expect(form.visibleErrorFor(LoginFields.email), isNotNull);
});
```

## Cover behavior without widgets

Test initial values, validation, field edits, `differs`, list operations, relations, and submit callbacks in fast unit tests. The same generated schema validator is used by the Flutter form.

## Add widget tests when needed

Use `testWidgets` to verify rendering, focus, keyboard behavior, and user interaction. See the [complete test example](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form_flutter/example/test).
