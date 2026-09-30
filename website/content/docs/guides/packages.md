---
title: Packages
description: Understand the user-facing layers, from pure-Dart validation and form state to optional Flutter bindings.
---

The package layers let an app use validation and controller behavior without depending on Flutter, then add Flutter widgets only when a Flutter UI is needed.

<PackageTopology />

## User-facing layers

- **Schema:** `keyed_form_schema` composes validators and validates maps or typed values. `keyed_form_gen` plus `build_runner` optionally generates immutable models and typed field references. Start at [Schema](docs/schema).
- **Form state:** `keyed_form` owns an immutable draft, field state, list operations, and submission behavior independently of widgets. Read [Form State](docs/form-state).
- **Flutter:** `keyed_form_flutter` supplies the scope, field bindings, text integration, and list widgets. Read [Flutter](docs/flutter).

The generator is a development-time dependency; generated `.kfg.dart` source is consumed by the application. Flutter is not required for a pure-Dart schema/controller workflow. For dependency commands and the SDK constraint, see [Installation](docs/guides/installation).
