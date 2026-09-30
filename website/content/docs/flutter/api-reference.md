---
title: Flutter API
description: Find the Flutter bindings, context helpers, selectors, list widgets, and submit APIs.
---

The Flutter package re-exports the shared `keyed_form` API, so most applications need one import: `package:keyed_form_flutter/keyed_form_flutter.dart`. This is a compact map of widget-layer entry points; follow the topic pages for examples and behavioral boundaries.

| API | Purpose | Guide |
|---|---|---|
| `KeyedForm<Root>` | Publishes a controller, registry, translator, and reactive scope to descendants. | [Form scope and context](docs/flutter/form-context) |
| `KeyedForm.controllerOf`, `registryOf`, `translateErrorOf` | Look up ambient form resources from a descendant `BuildContext`. | [Form scope and context](docs/flutter/form-context) |
| `KeyedFormField<Root, Value>`, `KeyedFieldState` | Bind typed values, errors, readonly and async-status state for custom controls; automatic anchor unless `anchor: false`. | [Field bindings](docs/flutter/field-bindings) |
| `KeyedFormField.text<Root>` | Bind text with managed editing-controller lifecycle. | [Text fields and bindings](docs/flutter/text-binding) |
| `KeyedTextBinding` | Standalone externally controlled text/controller synchronization. | [Text fields and bindings](docs/flutter/text-binding) |
| `context.watchField(ref)`, `watchForm()`, `selectForm(selector, equals:)` | Subscribe to a field, whole form, or selected derived value. | [Selective rebuilds](docs/flutter/reactivity) |
| `KeyedFormSelector<Root, T>`, `KeyedFormBuilder<Root>` | Scope a selected dependency to a subtree, or observe every controller change. | [Selective rebuilds](docs/flutter/reactivity) |
| `KeyedFieldList<Root, Item>` | Render keyed rows and obtain `KeyedFormList` collection operations. | [Lists and virtualization](docs/flutter/long-lists) |
| `KeyedFieldRegistry.revealFirst(keys, ...)` | Reveal/focus the first mounted matching field anchor. | [Submit and scroll to error](docs/flutter/scroll-to-first-error) |
| `KeyedFormController.handleSubmit(context, onValid, onInvalid:, duration:, alignment:)` | Submit with descendant context; default invalid handling reveals first visible error. | [Submit and scroll to error](docs/flutter/scroll-to-first-error) |

For shared controller lifecycle, validation, and relation APIs, see [Form State API](docs/form-state/api-reference). For generated field references and schema builders, see [Schema](docs/schema).
