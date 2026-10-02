---
title: Validation and visibility
description: Configure a synchronous resolver, scoped revalidation, modes, and error reveal behavior.
---

A resolver has the synchronous shape `(Root draft, FieldKey? scope) ->
FieldErrors<String>`. `null` scope means validate the full draft; a non-null
scope replaces errors under that key and preserves unrelated scopes.
Generated schemas provide `validateData` and `scopeOf`:

```dart
final form = KeyedFormController<InvoiceSchema>(
  initialValue: InvoiceSchema.create(),
  mode: KeyedFormMode.onTouched,
  resolver: InvoiceSchema.validateData,
  scopeOf: InvoiceSchema.scopeOf,
);
```

If `scopeOf` is omitted, an automatic write validates the full draft. If the
mapper returns `null`, that automatic write is skipped. For generated
positional models, use the scope mapper exposed by the generated API (for
example `InvoiceSchema.scopeOf`), not a handwritten tuple-position guess.

## Validation and reveal are separate

`validate()` validates the full draft, awaits configured async rules, and
returns a `KeyedFormValidationResult` with `status`, `errors`, and
`failures`. It reveals the result but does not set `submitted`.
`validateScopes(scopes)` validates those subtrees and returns the same
structured result; inspect `result.errors` or `result.isValid`, not a list of
failing scope keys. `reveal(scopes)` only changes visibility and does not run
validation.

## Trigger modes

The constructor mode determines which user events run validation. Initial
values, `seed`, and `reset` do not eagerly validate.

| Mode | Before first submit | After submit |
|---|---|---|
| `onSubmit` | No automatic validation | `reValidateMode` (`onChange` by default) |
| `onChange` | Validate after writes | `reValidateMode` (`onChange` by default) |
| `onBlur` | Validate on blur | `reValidateMode` (`onChange` by default) |
| `onTouched` | Validate on first blur, then after writes to touched fields | `reValidateMode` (`onChange` by default) |
| `all` | Validate after writes and blur | Continue both triggers |

`onBlur` and `onTouched` require the UI to report actual focus loss.
`touch()` is that blur signal: it records interaction and runs blur validation
when the configured mode calls for it; it is not an independent force-reveal.
Flutter's `KeyedFormField` reports focus leaving its widget subtree by
default. Set `autoDetectBlur: false` when a control owns a wider logical focus
boundary, then call `KeyedFieldState.onBlur` at that boundary. Do not wire
`onTapOutside` or Enter directly to blur.

`reValidateMode` is independently configurable as `onChange`, `onBlur`, or
`onSubmit`. `onSubmit` means no automatic revalidation after submit; `all`
continues both event triggers.

## Selected scopes

`validateScopes(scopes)` is useful for wizard steps or dirty-row checks:

```dart
final result = await form.validateScopes([
  InvoiceFields.billingAddress.key,
]);
if (result.isValid) advance();
```

Use full `validate()` on final submission so cross-step rules are included.
Scoped resolver output can contain ancestor errors; the result filters to
errors related to the requested scopes.

Async rules and the submit decision are described in
[Async validation](docs/form-state/async-validation).
