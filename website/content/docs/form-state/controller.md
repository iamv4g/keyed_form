---
title: Controller and lifecycle
description: Own immutable drafts, baselines, validation state, asynchronous submission, and snapshots.
---

`KeyedFormController<Root>` is a pure-Dart `ChangeNotifier`. It owns the current immutable draft, its comparison baseline, field-keyed errors, touched/revealed state, submission flags, async-check state, and readonly configuration. It has no Flutter dependency.

```dart
final form = KeyedFormController<InvoiceSchema>(
  initialValue: InvoiceSchema.create(),
  mode: KeyedFormMode.onTouched,
  resolver: (draft, scope) => InvoiceSchema.validateData(draft, scope: scope),
  scopeOf: InvoiceSchema.scopeOf,
);
```

`resolver` is synchronous and receives the draft plus an optional `FieldKey` scope. The generated `scopeOf` maps writes to a validation subtree; details are in [Validation and visibility](docs/form-state/validation). Constructor configuration such as `mode`, `resolver`, and `scopeOf` is final for that controller instance.

## Draft and baseline

`value` is the current draft; `original` is the baseline used by `isDirty`, `differs(ref)`, and dirty-row comparisons. The initial value serves as both. `seed(value)` replaces both and clears bookkeeping when the draft is clean. If it is dirty, seed is ignored unless called with `force: true`, which deliberately discards those edits. `reset()` restores `original` and clears validation/touch/reveal/submission bookkeeping.

Readonly configuration is not draft bookkeeping: fields marked read-only remain so across `seed` and `reset`. Use `unmarkReadOnly` to remove the freeze. See [Field handles](docs/form-state/field-handles).

## Validate and submit

`validate()` runs full sync and configured async validation, force-reveals its
result, and returns `KeyedFormValidationResult`. It does not mark the form
submitted. `submit` always validates a fresh snapshot and returns
`Future<bool>`: value errors go to `onInvalid`, blocking technical failures
go to `onValidationUnavailable`, and only a valid result runs `onValid`.
`submitting` remains true through validation and the callback. If the draft
changes, the form resets/seeds, or the controller is disposed before the
attempt settles, `onValid` is not called for that stale snapshot.

```dart
final saved = await form.submit(
  (draft) => api.save(draft.toMap()),
  onInvalid: (keys) => logInvalidFields(keys),
  onValidationUnavailable: (result) =>
      showCheckUnavailable(result.failures.keys),
);
```

`onInvalid` receives value-error keys. Technical failures are not errors;
`onValidationUnavailable` receives the structured result. A rule configured
with `KeyedFormAsyncFailureMode.allowSubmit` does not block an otherwise
error-free draft, but its remote check had no verdict. Callback exceptions
propagate; `submitting` is reset in `finally`. See [Validation and
visibility](docs/form-state/validation) for trigger timing and [Async
validation](docs/form-state/async-validation) for the complete submit policy.

## Disposal and snapshots

Dispose the controller when its owner is finished with it. `snapshot` returns an immutable point-in-time `KeyedFormSnapshot<Root>` useful when an outer state system wants value semantics. It contains `value`, `original`, `errors`, `isDirty`, `submitted`, and `submitting` only. It is intentionally coarse: it does not serialize mode, touched/revealed visibility, readonly configuration, or per-field async validation state. Do not use it as a complete restoration format.
