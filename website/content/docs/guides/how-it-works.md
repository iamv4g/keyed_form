---
title: How it works
description: Follow an immutable draft from schema and generated references through the controller to framework bindings.
---

A form is an immutable model draft owned by a `KeyedFormController`; widgets are bindings to that shared state, not the place where the draft lives.

## The path through a form

1. A schema describes validation rules. See [Schema](docs/schema) for raw validation and optional generation.
2. Code generation can produce an immutable model, typed field references, and validation methods. See [Code generation](docs/schema/code-generation).
3. A controller owns the current draft, baseline, errors, and interaction state. See [Controller and lifecycle](docs/form-state/controller).
4. A field handle or framework binding reads and updates a typed reference. See [Field handles](docs/form-state/field-handles) and [Flutter bindings](docs/flutter).

Generated references avoid string-based field lookup. A field nested beneath an object or list row composes from typed members; deleted or otherwise unresolved locations do not become writes to a stale index.

## Stable rows, independent UI

List rows have a stable `clientId`, distinct from their current array position. Inserting or moving rows changes indexes, while references continue to identify the same row. Widgets may be replaced or lazily unmounted without moving the draft out of the controller. Learn the list API in [Form State lists](docs/form-state/lists) and Flutter virtualization in [Long lists](docs/flutter/long-lists).

The shared state and schema layers are pure Dart. Flutter adds widgets, context lookup, focus, and mounted-field reveal; it does not change where form data is owned. For package boundaries, see [Packages](docs/guides/packages).
