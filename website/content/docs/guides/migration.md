---
title: Migration
description: Move incrementally from widget-owned form patterns to generated references and a controller-owned draft.
---

| Existing pattern | keyed_form approach | Benefit |
|---|---|---|
| `GlobalKey<FormState>` | `KeyedFormController<Root>` | Form logic works outside the widget tree. |
| Per-field `TextEditingController` | `KeyedFormField.text<Root>` | Managed two-way binding and caret stability. |
| String field name | Generated `UserFields.age` | Compile-time field and value type checks. |
| List position as identity | `clientId` on a keyed row | Reordering does not swap values or errors. |
| `validate()` then `save()` | `handleSubmit(context, onValid)` | Submit validates and reveals the first invalid mounted field. |


## Move to 0.2 async validation

Async checks are now configured once through `asyncValidators` using typed
`KeyedFormAsyncValidator.field` / `.forEach` rules. Remove direct
`FieldHandle.validateAsync`, `validateFieldAsync`, and
`setFieldValidating` calls. Use `form.field(ref).validate()` for an explicit
retry of the configured rule.

Await `validate()` and `validateScopes()` and inspect their
`KeyedFormValidationResult`. `submit()` always runs a fresh check: value
errors use `onInvalid`; blocking technical failures use
`onValidationUnavailable`. Set a rule's failure mode to `allowSubmit` only
when a missing remote verdict may safely proceed.

## Migrate incrementally

Start by defining a schema for one form and generating its model and field references. Move that form's draft into a controller, then replace its text inputs with `KeyedFormField.text`. Unrelated screens and forms can remain unchanged while you migrate one slice at a time.

For installation and the smallest complete setup, see the [Quickstart](docs/guides/quickstart). Learn about [dynamic lists](docs/guides/dynamic-lists), [controller state](docs/form-state/controller), and [text bindings](docs/flutter/text-binding) as you replace each pattern.

`handleSubmit` can reveal and focus the first invalid field that is currently mounted. It cannot reveal an anchor for an off-screen row that a lazy list has not built yet. For that case, first scroll to the relevant section and then reveal the mounted field; see [Submit and scroll to error](docs/flutter/scroll-to-first-error).
