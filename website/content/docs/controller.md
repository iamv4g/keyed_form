---
title: Controller
description: KeyedFormController owns the draft, baseline, validation state, and submit lifecycle.
---

`KeyedFormController<Root>` is a pure Dart `ChangeNotifier`. It owns the immutable draft independently of Flutter widgets.

```dart
final form = KeyedFormController<LoginSchema>(
  initialValue: LoginSchema.create(),
  mode: KeyedFormMode.onChange,
  resolver: LoginSchema.validateData,
);

form.seed(userFromApi); // establish a clean baseline
form.field(LoginFields.email).set('alice@example.com');
print(form.isDirty); // true
form.reset(); // restore the baseline
```

## Load data and track edits

Call `seed(value)` when loading an existing record. It sets the current value and the comparison baseline together. `isDirty` tracks whether the draft differs from that baseline; `differs(ref)` checks one field.

`submit(onValid, ...)` performs fresh sync and async validation before calling
`onValid`. Value errors go to `onInvalid`; blocking technical failures go to
`onValidationUnavailable`. `validate()` returns a structured result and does
not mark the form submitted. See [Validation](docs/validation) for trigger
timing and [Async validation](docs/async-validation) for submit policy.
In Flutter, `handleSubmit(context, onValid)` also reveals the relevant mounted
fields. Dispose the controller with its owning state.

## Read state reactively

Use `context.watchField` for one value and `context.selectForm` for a derived
slice. `KeyedFormSelector` scopes the rebuild to a subtree. `watchForm` and
`KeyedFormBuilder` observe the whole draft, so prefer narrower reads when
possible.
