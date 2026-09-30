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

`validate()` invokes the resolver for the whole draft, sets `submitted`, makes errors visible, and returns whether the errors are empty. `submit` returns `Future<bool>`: it validates synchronously before invoking the callback, awaits a `FutureOr<void>` success callback while `submitting` is true, then returns `true`; invalid data returns `false` and does not invoke it. An optional `onInvalid` callback receives visible error keys. Callback exceptions propagate, while `submitting` is reset in `finally`.

```dart
final saved = await form.submit(
  (draft) => api.save(draft.toMap()),
  onInvalid: (keys) => logInvalidFields(keys),
);
```

The controller's resolver itself is never awaited. Server-backed checks use [Async validation](docs/form-state/async-validation); Flutter's descendant-context helper is covered under [Flutter submit](docs/flutter/scroll-to-first-error).

## Disposal and snapshots

Dispose the controller when its owner is finished with it. `snapshot` returns an immutable point-in-time `KeyedFormSnapshot<Root>` useful when an outer state system wants value semantics. It contains `value`, `original`, `errors`, `isDirty`, `submitted`, and `submitting` only. It is intentionally coarse: it does not serialize mode, touched/revealed visibility, readonly configuration, or per-field async validation state. Do not use it as a complete restoration format.
