---
title: Forms that stay predictable as they grow
description: Typed fields, stable list rows, and isolated updates from one schema.
---

`keyed_form` keeps form state in a typed data model, outside the widget tree. Fields subscribe to their own value, while stable row ids keep dynamic lists correct through edits, inserts, and reordering.

Start with one of these guides:

- [Install the packages](docs/installation)
- [Build a login form](docs/quickstart)
- [Understand the data model](docs/how-it-works)
- [Build a reorderable list](docs/dynamic-lists)

## What you get

- Generated, typed field references that follow your schema.
- Validation that can be tested as plain Dart.
- Stable identity for dynamic rows.
- Field-level notifications, so editing one value does not rebuild every field.

## Supported packages

The schema, controller, and generator are pure Dart. Flutter widgets are provided by `keyed_form_flutter`.
