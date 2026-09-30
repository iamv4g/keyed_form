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

## Choose when errors appear

`KeyedFormMode` controls visibility while users edit. Submit through the controller to validate the full draft and reveal invalid fields. For asynchronous checks, see [async validation](docs/async-validation).
