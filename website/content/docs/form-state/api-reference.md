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
| `validate()`, `validateScopes(scopes)` | Return `Future<KeyedFormValidationResult>` with status, value errors, and technical failures. |
| `submit(onValid, {onInvalid, onValidationUnavailable})` | Fresh sync/async validation, then route to the matching callback; returns `Future<bool>`. |
| `resolver`, `KeyedFormResolver<Root>` | `(draft, FieldKey? scope) -> FieldErrors<String>`; synchronous. |
| `scopeOf`, `KeyedFormScopeOf` | Map an automatic write to a validation subtree; `null` skips that write. |
| `reveal(scopes)` | Change visibility without running validation. |
| `errors`, `visibleError(key)`, `visibleErrorFor(ref)`, `visibleErrorKeys`, `visibleErrorUnder(root)` | Raw errors or mode-gated visible errors. |
| `KeyedFormMode`, `KeyedFormReValidateMode` | Configure user-event triggers before and after submit. |
| `snapshot` / `KeyedFormSnapshot<Root>` | Coarse immutable state; omits visibility, readonly, and async state. |

## Fields, lists, and asynchronous checks

| API | Purpose |
|---|---|
| `form.field(ref)` / `FieldHandle<Root, Value>` | Typed value, key, visible error, dirty/readonly and validation state; set/update/touch. |
| `FieldRef<Root, Value>` / `StrictFieldRef<Root, Value>` | Typed field identity; nested references may be unresolved. |
| `KeyedFormAsyncValidator.field(...)`, `.forEach(...)` | Declare typed async rules, including rules scoped to keyed rows. |
| `FieldHandle.validate()` | Explicitly rerun configured async rules for this field. |
| `KeyedFormAsyncFailureMode`, `KeyedFormValidationResult` | Distinguish technical failures from value errors and configure submit policy. |
| `KeyedFormList<Root, Item>` | List editor with append/prepend/insert/remove/move/swap/update methods. |
| `markReadOnly(key)`, `unmarkReadOnly(key)` / `force` | Freeze a field/subtree; explicit `force` bypasses only the write guard. |
| `setServerErrors(errors)`, `setServerErrorPaths(paths)` | Merge backend field errors. |

## Relations and framework bindings

| API | Purpose |
|---|---|
| `addRelation(source, select, onChange)` | Observe a source and react to changed selected values; returns an unsubscribe callback. See [Relations](docs/form-state/relations). |
| `handleSubmit(context, onValid, {onInvalid, onValidationUnavailable, ...})` | Flutter-aware submission; reveals blocking fields by default. See [Flutter submit](docs/flutter/scroll-to-first-error). |
| `KeyedForm`, `KeyedFormField`, `KeyedFieldList` | Flutter bindings; see [Flutter API](docs/flutter/api-reference). |

For schema declaration and generated refs, start at [Schema](docs/schema).
