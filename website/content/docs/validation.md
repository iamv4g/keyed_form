---
title: Validation
description: Declare field rules in the schema and add cross-field rules with refine.
---

Synchronous rules live alongside the field's schema. The generated validator reports errors against typed field keys.

```dart
final _loginSchema = ks.object({
  'email': ks.string(error: .text('Email is required')).email(),
  'password': ks.string().min(8),
});
```

## Compose rules

Rules such as `.required()`, `.email()`, `.min(...)`, and `.max(...)` can be chained on a field schema. Provide `.text(...)` messages where the default is not right for your app.

## Validate related fields

Use `.refine(...)` when validity depends on more than one field, such as matching password and confirmation values. Keep the predicate synchronous and attach the result to the field that should display the error.

`KeyedFormMode` controls validation triggers before submit: `onSubmit` runs
no automatic checks, `onChange` validates writes, `onBlur` validates on real
focus loss, and `onTouched` validates on first blur and later writes to that
field. `all` validates writes and blur. After submit, `reValidateMode`
(default `onChange`) controls subsequent triggers; `all` keeps both.

Initial values, seeding, and reset do not eagerly validate. `touch()` reports
a blur and runs blur validation when the mode requires it; it is not an
independent reveal. Manual `validate()` returns a structured result and does
not mark the form submitted. See [validation and visibility](docs/form-state/validation)
for scoped validation and the full trigger table, and
[async validation](docs/form-state/async-validation) for remote rules.
