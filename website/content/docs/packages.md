---
title: Packages
description: The form stack is split into small layers, from pure Dart schema tools to Flutter widgets.
---

The core packages do not depend on Flutter. Use only the layers your app needs; the Flutter package provides the widget bindings.

<PackageTopology />

## Dependency flow

Schema types and generated references sit above the shared core. The controller owns form state, and the Flutter layer connects it to widgets. This keeps validation and state logic testable without mounting a widget tree.

## Install the Flutter binding

```sh
flutter pub add keyed_form_flutter keyed_form_schema
flutter pub add -d keyed_form_gen build_runner
```

See [installation](docs/installation) for runtime requirements and code generation.
