---
title: Async validation
description: Run server-backed field checks with timeout and validating state.
---

Configure asynchronous validation as typed controller rules; there is no
per-call check callback. A field rule receives the draft and typed field
value, returns `String?`, and may set a timeout, failure policy, and technical
failure observer:

```dart
asyncValidators: [
  .field(
    field: EmailFields.email,
    validate: (_, email) => api.checkEmailTaken(email),
    timeout: const Duration(seconds: 5),
    onFailure: (error, stack) => reportConnectivityProblem(error),
  ),
],
```

`validate()` and `validateScopes()` await all applicable rules after sync
validation. Rules run in parallel, but a sync error at that rule's field or
ancestor/descendant scope gates the remote check. Unrelated sibling errors do
not. Nested `forEach` rules validate keyed row-local fields using stable
`clientId` keys.

A returned message is an ordinary value error; `null` clears only the prior
async message. Exceptions and timeouts are technical failures, not field
errors. They appear in `KeyedFormValidationResult.failures` and
`validationFailures`, with the error and stack trace; `onFailure` is an
observer. `FieldHandle.isValidating` and `isFailedValidation` expose progress
and failure to Flutter controls.

By default technical failures block submit. Set
`failureMode: KeyedFormAsyncFailureMode.allowSubmit` for a rule allowed to
fail open. Value errors always block `onValid`; blocking failures route to
`onValidationUnavailable`; when only allowed failures remain, `onValid` may
run even though the service did not give a verdict. Explicit validation still
reports `unavailable` (`isValid == false`) for any technical failure;
`submit()` separately applies each rule's failure policy. Superseded runs
never authorize submit.

Every submit performs a fresh check. Editing the draft, reset, seed, or
disposal fences a pending submit from saving stale data. No automatic
debounce, caching, or retry occurs. For value-only validation timing, see
[Validation and visibility](docs/form-state/validation).
