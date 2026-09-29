---
title: API reference
description: The main controller, field handle, list, and Flutter binding APIs.
---

## Controller

| Member | Purpose |
|---|---|
| `value`, `original` | Current draft and clean baseline. |
| `isDirty`, `differs(ref)`, `dirtyRows(list)` | Compare form, field, or list rows with the baseline. |
| `field(ref)` | Return a typed `FieldHandle<Root, Value>`. |
| `seed(value)`, `reset()` | Set a clean baseline and restore it later. |
| `submit(onValid, onInvalid)` | Validate and run the submit callback. |
| `handleSubmit(context, onValid)` | Flutter submit helper that reveals the first mounted invalid field. |
| `setServerErrorPaths(paths)` | Map backend paths to field errors. |
| `addRelation(source, select, onChange)` | Register a derived update; returns an unsubscribe callback. |
| `markReadOnly(key)` | Prevent edits to a field or subtree. |

## Field handle

| Member | Purpose |
|---|---|
| `value`, `error`, `dirty`, `isReadOnly`, `isValidating` | Read typed value and field state. |
| `set(value)`, `update(transform)` | Write or transform the value. |
| `touch()` | Mark the field visited. |
| `validateAsync(check, timeout)` | Run an async validation check. |
| `list()` | Get a `KeyedFormList` for a list field. |

## Flutter bindings

`KeyedForm<Root>` publishes the controller and field registry. `KeyedFormField<Root, Value>` binds a custom control, while `KeyedFormField.text<Root>` manages text synchronization. `KeyedFieldList<Root, Item>` builds keyed dynamic rows.

Use the package API reference for full signatures: [keyed_form_flutter](https://pub.dev/documentation/keyed_form_flutter/latest/) and [keyed_form](https://pub.dev/documentation/keyed_form/latest/).
