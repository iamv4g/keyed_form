---
title: Async validation
description: Run server-backed field checks with timeout and validating state.
---

Use `validateAsync` for checks that need a network request, such as checking whether an email address is already registered. The field exposes validation state while the future is pending.

```dart
final email = form.field(EmailCheckFields.email);
await email.validateAsync(
  () => api.checkEmailTaken(email.value ?? ''),
  timeout: const Duration(seconds: 5),
);
```

In a text field, trigger the check on blur and display `isValidating` while the request runs. Keep local format and required rules in the schema so they can fail without a network round trip.

`isFailedValidation` distinguishes a technical failure (the check threw or timed out) from a server verdict that the value is invalid. A failed request is not added as a field validation error; surface a retry or connectivity message separately. Overlapping checks for the same field are guarded so only the latest result is applied.

## Map backend errors

When submit returns a validation response, map paths to matching fields with `setServerErrorPaths`. See [server errors](docs/server-errors) for a full recipe.

## Example

The [email check example](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form_flutter/example/lib/email_check) shows the complete async validation flow.
