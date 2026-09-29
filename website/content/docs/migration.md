---
title: Migration
description: Map familiar Flutter form patterns to generated fields and a controller-owned draft.
---

| Existing pattern | keyed_form approach | Benefit |
|---|---|---|
| `GlobalKey<FormState>` | `KeyedFormController<Root>` | Form logic works outside the widget tree. |
| Per-field `TextEditingController` | `KeyedFormField.text<Root>` | Managed two-way binding and caret stability. |
| String field name | Generated `UserFields.age` | Compile-time field and value type checks. |
| List position as identity | `clientId` on a keyed row | Reordering does not swap values or errors. |
| `validate()` then `save()` | `handleSubmit(context, onValid)` | Submit validates and reveals the first invalid field. |

## Migrate incrementally

Start by defining a schema for one form and generating its model and field refs. Move the draft into a controller, then replace text inputs with `KeyedFormField.text`. Keep unrelated screens and forms unchanged until ready.

See [Quickstart](docs/quickstart) for the smallest complete setup and [dynamic lists](docs/dynamic-lists) for keyed row migration.
