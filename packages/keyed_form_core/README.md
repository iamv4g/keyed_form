# keyed_form_core

Shared vocabulary for the `keyed_form` family. It sits on
[`keyed_lens`](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_lens) and below
[`keyed_form_schema`](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form_schema) / [`keyed_form`](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form) —
you normally reach it transitively, not by importing it directly.

For the full documentation, guides, and examples, visit
[keyed-form.v4g.space](https://keyed-form.v4g.space).

## What it gives the form layers

| Name | Is | For |
| --- | --- | --- |
| `FieldRef<R, V>` | extension type wrapping `AffineLens<R, V>` | a typed handle to a field that may not resolve (removed row, null sub-struct, wrong union variant) |
| `StrictFieldRef<R, V>` | extension type wrapping `Lens<R, V>` | a field that always resolves — `get` is non-null |
| `VariantFieldRef<S, V>` | extension type wrapping `Prism<S, V>` | narrowing to one variant of a sum type |
| `DelegatingFieldRef<R, V>` | `extends AffineLens` | base the generated `<X>FieldRefs` wrappers extend — holds an `inner` ref and forwards `key`/`find`/`set` |
| `.whenPresent()` / `.narrow()` / `.at()` | extensions on `FieldRef` | refine a nullable field · narrow a union · descend into a list row by id |
| `FieldErrors<E>` | `FieldKey`-keyed sidecar map | validation messages (or any per-field `E`) |
| `@keyedSchema` / `KeyedSchema` | annotation | marks a library for `keyed_form_gen` |

The raw optic names (`Lens` / `AffineLens` / `Prism` / `ListItemLens`) are
**not** re-exported here — these extension types are form-layer wrappers, not
typedef aliases. Import `package:keyed_lens/keyed_lens.dart` directly only for
standalone optics work.
