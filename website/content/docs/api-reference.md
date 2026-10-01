---
title: API reference
description: The main controller, field handle, list, and Flutter binding APIs.
---

## Controller

| Member | Purpose |
|---|---|
| `value`, `original` | Current draft and clean baseline. |
| `isDirty`, `differs(ref)`, `dirtyRows(listRef)` | Compare form, field, or keyed rows with baseline. |
| `field(ref)` | Return a typed `FieldHandle<Root, Value>`. |
| `seed(value, {force})`, `reset()` | Set a baseline and restore it later. |
| `validate()`, `validateScopes(scopes)` | Async structured validation result with value errors and technical failures. |
| `submit(onValid, {onInvalid, onValidationUnavailable})` | Fresh validation and outcome-specific callbacks. |
| `handleSubmit(context, onValid, ...)` | Flutter submit helper; reveals blocking fields by default. |
| `asyncValidators` | Typed declarative async rules; supports nested keyed rows. |
| `mode`, `reValidateMode` | Configure automatic validation events before and after submit. |
| `setServerErrorPaths(paths)` | Map backend paths to field errors. |
| `setServerErrors(errors)` | Set errors by `FieldKey`. |
| `addRelation(source, select, onChange)` | Register a derived update; returns an unsubscribe callback. |
| `markReadOnly(key)`, `unmarkReadOnly(key)` | Freeze or unfreeze edits to a field or subtree. |

## Field handle

| Member | Purpose |
|---|---|
| `value`, `error`, `dirty`, `isReadOnly`, `isValidating`, `isFailedValidation` | Read typed value and field state. |
| `set(value, {force})`, `update(transform, {force})` | Write or transform the value. |
| `touch()` | Record that the field was visited. |
| `validate()` | Explicitly rerun configured async rules for this field. |
| `list()`, `dirtyRows()` | Get a `KeyedFormList` or inspect changed rows. |

## Flutter bindings

`KeyedForm<Root>` publishes the controller and field registry.
`KeyedFormField<Root, Value>` binds a custom control through `KeyedFieldState`
(`value`, `errorText`, `isReadOnly`, `isValidating`, `isFailedValidation`,
`onChanged`, and `onBlur`). `KeyedFormField.text<Root>` manages text
synchronization and caret stability. `KeyedFieldList<Root, Item>` builds
keyed dynamic rows.

Use the package API reference for full signatures:
[keyed_form_flutter](https://pub.dev/documentation/keyed_form_flutter/latest/)
and [keyed_form](https://pub.dev/documentation/keyed_form/latest/).
