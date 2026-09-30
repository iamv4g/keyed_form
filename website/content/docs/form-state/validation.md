---
title: Validation and visibility
description: Configure a synchronous resolver, scoped revalidation, modes, and error reveal behavior.
---

A controller resolver has the synchronous shape `(Root draft, FieldKey? scope) -> FieldErrors<String>`. A `null` scope means validate the whole draft; a non-null scope means return only errors at or below that key. When scoped, the controller replaces errors under that scope and preserves other scopes' errors. A resolver returning keys outside the requested scope violates the contract (asserted in debug builds).

Generated schemas provide `validateData` and `scopeOf`. Configure them together:

```dart
final form = KeyedFormController<InvoiceSchema>(
  initialValue: InvoiceSchema.create(),
  mode: KeyedFormMode.onTouched,
  resolver: (draft, scope) => InvoiceSchema.validateData(draft, scope: scope),
  scopeOf: InvoiceSchema.scopeOf,
);
```

If `scopeOf` is omitted, a write revalidates the full draft. With it, the controller asks for the subtree containing the written key. `scopeOf` returning `null` for a write means skip scoped revalidation for that write. See [Schema refinements](docs/schema/refinements) for rule declaration and [Code generation](docs/schema/code-generation) for generated resolver APIs.

## Error visibility modes

`KeyedFormMode` is chosen in the constructor and is final:

| Mode | Visibility behavior |
|---|---|
| `onChange` | A write touches its field, so errors show as soon as the changed field has an error. |
| `onBlur` | Errors show after touch; Flutter bindings mark touch on blur. |
| `onTouched` | Same controller visibility rule as `onBlur`; Flutter keeps a blurred field's errors current while typing. |
| `onSubmit` | Errors show after a submit attempt, unless explicitly revealed earlier. |
| `all` | Every existing error is visible immediately. |

`errors` is the full raw error map independent of display mode. `visibleError(key)`, `visibleErrorFor(ref)`, `visibleErrorKeys`, and `visibleErrorUnder(root)` apply visibility policy. `validate()` performs whole-draft validation and sets `submitted`, so all errors become visible. `reveal(scopes)` reveals existing errors without re-running the resolver.

## Validate selected scopes

`validateScopes(scopes)` revalidates each specified subtree, force-reveals each it inspects, and returns the scopes that still contain errors. This return value is useful for step-by-step forms even in `onSubmit` mode: gate advancing on an empty failing-scope list, rather than testing whether errors happen to be visible. At final submission, validate the entire draft so cross-step rules are included.

```dart
final failingSteps = form.validateScopes([InvoiceFields.billingAddress.key]);
if (failingSteps.isEmpty) advance();
```

The resolver stays synchronous; do not pass `validateDataAsync` as the controller resolver. For a server/network check on one field use [Async validation](docs/form-state/async-validation), which is a distinct lifecycle.
