---
title: Async validation
description: Run asynchronous field checks with progress, latest-request protection, timeout, and failure state.
---

Declare asynchronous checks on the controller. Each rule is bound to a typed
field reference, so the callback receives the draft and its correctly typed
field value:

```dart
final form = KeyedFormController<EmailSchema>(
  initialValue: EmailSchema.create(),
  resolver: EmailSchema.validateData,
  asyncValidators: [
    .field(
      field: EmailFields.email,
      validate: (_, email) => api.checkEmailTaken(email),
      timeout: const Duration(seconds: 5),
      onFailure: (error, stack) => reportConnectivityProblem(error),
    ),
  ],
);
```

`validate()` and `validateScopes()` await the configured rules and return a
`KeyedFormValidationResult`. Rules start in parallel after synchronous
validation. A sync error on a rule's field or its ancestor/descendant scope
gates that rule; an unrelated sibling error does not. Use nested
`KeyedFormAsyncValidator.forEach` rules to validate keyed rows with row-local
references; the controller adds each stable `clientId` to the concrete error
key.

Rules can be nested under each keyed collection; callbacks then receive the
local row value and the controller builds keys from the row's stable ID:

```dart
asyncValidators: [
  .forEach(
    collection: ItineraryFields.days,
    rules: [
      .forEach(
        collection: DayFields.activities,
        rules: [
          .field(
            field: VariantRef<ActivitySchema, SightseeingActivitySchema>.type()
                .then(SightseeingActivityFields.place),
            validate: (_, place) => api.checkPlace(place),
          ),
        ],
      ),
    ],
  ),
],
```

## Value errors and technical failures

A returned message is a value error stored in the regular error map; returning
`null` clears only that async rule's previous message. A thrown exception or
timeout is a technical failure, recorded separately in `result.failures` and
`validationFailures`, not as an error string. The failure is retained as
`isFailedValidation` until a later run or lifecycle reset. `onFailure` is an
optional observer; exceptions from the check itself are represented in the
result.

When multiple sources have a message for one key, displayed error ownership is
sync validation first, then server, then async validation. Clearing an async
verdict never clears a sync or server error.

The default `KeyedFormAsyncFailureMode.blockSubmit` prevents `onValid` when a
technical check fails. A rule may opt into `allowSubmit`. The submit decision
is:

| Validation outcome | Submit behavior |
|---|---|
| Any sync or async value error | Never call `onValid`; call `onInvalid` |
| All checks succeed | Call `onValid` |
| Blocking technical failure and no value errors | Call `onValidationUnavailable`; never call `onValid` |
| Only `allowSubmit` technical failures and no value errors | Call `onValid`; the backend may still reject the value |
| Superseded run | Never authorize `onValid`; run validation again |

An explicit validation result remains `unavailable` (and `isValid` is false)
when a technical failure occurred, even when that rule uses `allowSubmit`.
Submit evaluates `failureMode` separately and may still invoke `onValid` for
an otherwise error-free draft.

`submit()` always starts a fresh validation; it does not reuse a previous
manual or automatic result. A draft edit, reset, seed, or disposal fences the
attempt from saving stale data. A new validation run supersedes pending work
for the same concrete field. No automatic debounce, cache, or retry is applied.

`FieldHandle.validate()` explicitly reruns configured rules for that field.
It is useful for an explicit retry affordance after a technical failure.
