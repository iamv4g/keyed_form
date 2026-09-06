# keyed_form_core

Shared vocabulary for the `keyed_form` family. It sits on
[`keyed_lens`](../keyed_lens) and below
[`keyed_form_schema`](../keyed_form_schema) / [`keyed_form`](../keyed_form) —
you normally reach it transitively, not by importing it directly.

## What it gives the form layers

| Name | Is | For |
| --- | --- | --- |
| `FieldRef<R, V>` | alias of `AffineLens<R, V>` | a typed handle to a field that may not resolve (removed row, null sub-struct, wrong union variant) |
| `StrictFieldRef<R, V>` | alias of `Lens<R, V>` | a field that always resolves — `get` is non-null |
| `VariantRef<S, V>` | alias of `Prism<S, V>` | narrowing to one variant of a sum type |
| `DelegatingFieldRef<R, V>` | `extends AffineLens` | base the generated `<X>FieldRefs` wrappers extend — holds an `inner` ref and forwards `key`/`find`/`set` |
| `.whenPresent()` / `.narrow()` / `.at()` | extensions on `FieldRef` | refine a nullable field · narrow a union · descend into a list row by id |
| `FieldErrors<E>` | `FieldKey`-keyed sidecar map | validation messages (or any per-field `E`) |
| `@keyedSchema` / `KeyedSchema` | annotation | marks a library for `keyed_form_gen` |

The raw optic names (`Lens` / `AffineLens` / `Prism` / `ListItemLens`) are
**not** re-exported here — the aliases are complete substitutes. Import
`package:keyed_lens/keyed_lens.dart` directly only for standalone optics work.
