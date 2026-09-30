---
title: Form State API
description: Compact index of controller, field, list, resolver, scope, and relation APIs.
---

This page is an index to the pure-Dart `keyed_form` API. For usage and edge behavior, follow the linked topic pages; complete signatures are in the [keyed_form API reference](https://pub.dev/documentation/keyed_form/latest/).

## Controller and validation

| API | Purpose |
|---|---|
| `KeyedFormController<Root>` | Owns draft, baseline, errors, visibility, and lifecycle; see [Controller and lifecycle](docs/form-state/controller). |
| `value`, `original`, `isDirty`, `differs(ref)`, `dirtyRows(ref)` | Draft and comparison with baseline. |
| `seed(value, {force})`, `reset()` | Replace baseline or restore it; seed skips a dirty draft unless forced. |
| `validate()`, `submit(onValid, {onInvalid})` | Synchronous whole-draft validation; submit returns `Future<bool>` and awaits the valid callback. |
| `resolver`, `KeyedFormResolver<Root>` | `(draft, FieldKey? scope) -> FieldErrors<String>`; synchronous. |
| `scopeOf`, `KeyedFormScopeOf` | Map a written key to the validation subtree. |
| `validateScopes(scopes)`, `reveal(scopes)` | Revalidate/reveal selected scopes; the former returns failing scopes. |
| `errors`, `visibleError(key)`, `visibleErrorFor(ref)`, `visibleErrorKeys`, `visibleErrorUnder(root)` | Raw errors or mode-gated visible errors. See [Validation and visibility](docs/form-state/validation). |
| `KeyedFormMode` | `onChange`, `onBlur`, `onTouched`, `onSubmit`, or `all`; selected at construction. |
| `snapshot` / `KeyedFormSnapshot<Root>` | Coarse immutable state; omits visibility, mode, readonly, and async state. |

## Fields, lists, and asynchronous checks

| API | Purpose |
|---|---|
| `form.field(ref)` / `FieldHandle<Root, Value>` | Typed value, key, visible error, dirty/readonly state, set/update/touch; see [Field handles](docs/form-state/field-handles). |
| `FieldRef<Root, Value>` / `StrictFieldRef<Root, Value>` | Core field identity; refs may be unresolved when a nested path is absent or a variant differs. |
| `FieldHandle.validateAsync(check, {timeout, onFailure})` | App-owned async field check; see [Async validation](docs/form-state/async-validation). |
| `KeyedFormList<Root, Item>` | List editor with append/prepend/insert/remove/move/swap/update methods; see [List operations](docs/form-state/lists). |
| `markReadOnly(key)`, `unmarkReadOnly(key)` / `force` | Freeze a field/subtree; explicit `force` bypasses only the write guard. |
| `setServerErrors(errors)`, `setServerErrorPaths(paths)` | Merge and reveal backend field errors; invalid wire path throws `FormatException`. See [Server errors](docs/form-state/server-errors). |

## Relations and framework bindings

| API | Purpose |
|---|---|
| `addRelation(source, select, onChange)` | Observe a source and react to changed selected values; returns an unsubscribe callback. See [Relations](docs/form-state/relations). |
| `handleSubmit(context, onValid)` | Flutter-aware submission and mounted-field reveal; see [Flutter submit](docs/flutter/scroll-to-first-error). |
| `KeyedForm`, `KeyedFormField`, `KeyedFieldList` | Flutter bindings; see [Flutter API](docs/flutter/api-reference). |

For schema declaration and generated refs, start at [Schema](docs/schema).
