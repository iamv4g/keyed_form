---
title: Async validation
description: Run asynchronous field checks with progress, latest-request protection, timeout, and failure state.
---

The controller resolver is synchronous. Use `FieldHandle.validateAsync` for an app-owned asynchronous check such as asking a service whether an email is already taken; this is not the schema's asynchronous predicate API. Keep deterministic required/format rules in the schema so they can run locally. See [Schema refinements](docs/schema/refinements) for schema validation entrypoints.

```dart
final email = form.field(EmailCheckFields.email);
await email.validateAsync(
  () => api.checkEmailTaken(email.value ?? ''),
  timeout: const Duration(seconds: 5),
  onFailure: (error, stack) => reportConnectivityProblem(error),
);
```

While pending, `email.isValidating` is true. A non-null check result is merged as a server error on that field, revealed and marked submitted. A `null` result means this check supplied no new verdict; importantly it does **not** clear an existing server error. Clear/replace errors through the controller's explicit error-management flow if needed.

## Technical failure and overlap

A thrown exception or timeout is a technical failure, not a verdict that the value is invalid. It does not become a field error. Instead `isFailedValidation` becomes true and optional `onFailure` receives the error and stack trace; the future completes normally. A subsequent check clears the previous technical-failure marker whether it succeeds or fails.

Overlapping checks for the same field are generation-guarded: only the latest invocation may settle state, so a slow older response cannot overwrite a newer result. This does not cancel the underlying network request. Checks on different fields have independent state. Display progress/failure separately from the normal validation message.

For errors returned by a failed form submission, map backend paths with [Server errors](docs/form-state/server-errors). The [email-check source example](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form_flutter/example/lib/email_check) demonstrates an application-level availability check.
