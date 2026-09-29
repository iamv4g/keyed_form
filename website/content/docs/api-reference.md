---
title: API reference
description: The main controller, field handle, list, and Flutter binding APIs.
---

## Controller

| Member | Purpose |
|---|---|
| `value`, `original` | Current draft and clean baseline. |
| `isDirty`, `differs(ref)`, `dirtyRows(listRef)` | Compare the form, one field, or keyed list rows with the seeded baseline. |
| `field(ref)` | Return a typed `FieldHandle<Root, Value>`. |
| `seed(value, {force})`, `reset()` | Set a clean baseline and restore it later. `seed` skips a dirty draft unless forced. |
| `submit(onValid, {onInvalid})` | Validate and run the submit callback. |
| `handleSubmit(context, onValid)` | Flutter submit helper that reveals the first mounted invalid field. |
| `setServerErrorPaths(paths)` | Map backend paths to field errors. |
| `setServerErrors(errors)`, `isFailedValidation(key)` | Set errors by `FieldKey` or inspect async validation failures. |
| `addRelation(source, select, onChange)` | Register a derived update; returns an unsubscribe callback. |
| `markReadOnly(key)`, `unmarkReadOnly(key)` | Freeze or unfreeze edits to a field or subtree. |

## Field handle

| Member | Purpose |
|---|---|
| `value`, `error`, `dirty`, `isReadOnly`, `isValidating`, `isFailedValidation` | Read typed value and field state. |
| `set(value, {force})`, `update(transform, {force})` | Write or transform the value. `force` writes through a read-only freeze. |
| `touch()` | Mark the field visited. |
| `validateAsync(check, timeout)` | Run an async validation check. |
| `list()`, `dirtyRows()` | Get a `KeyedFormList` or inspect changed rows for a list field. |

## Flutter bindings

`KeyedForm<Root>` publishes the controller and field registry. `KeyedFormField<Root, Value>` binds a custom control through `KeyedFieldState` (`value`, `errorText`, `isReadOnly`, `isValidating`, `isFailedValidation`, `onChanged`, and `onBlur`), while `KeyedFormField.text<Root>` manages text synchronization and caret stability. `KeyedFieldList<Root, Item>` builds keyed dynamic rows.

Use the package API reference for full signatures: [keyed_form_flutter](https://pub.dev/documentation/keyed_form_flutter/latest/) and [keyed_form](https://pub.dev/documentation/keyed_form/latest/).
