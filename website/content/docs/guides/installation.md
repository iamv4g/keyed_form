---
title: Installation
description: Add only the pure-Dart schema and controller layers you need, with Flutter bindings as an optional UI dependency.
---

`keyed_form_schema` provides schema validation and `keyed_form` provides the pure-Dart controller. For a Flutter UI, add `keyed_form_flutter`, which depends on and re-exports the controller API. The generator and `build_runner` are development dependencies because generated source is committed and used at runtime without a generator dependency.

## Pure-Dart setup

```sh
dart pub add keyed_form_schema keyed_form
dart pub add -d keyed_form_gen build_runner
```

You can use the schema package for raw-map validation without code generation. Add `keyed_form_gen` when you want generated immutable models and typed references. See [Schema](docs/schema) and its [Code generation](docs/schema/code-generation) workflow.

## Flutter setup

```sh
flutter pub add keyed_form_flutter keyed_form_schema
flutter pub add -d keyed_form_gen build_runner
```

Import `package:keyed_form_flutter/keyed_form_flutter.dart` for the Flutter bindings and controller API. The pure-Dart packages do not require Flutter; see the [Flutter guide](docs/flutter).

## SDK requirement and build

The current package manifests require Dart 3.10 or newer (`sdk: ^3.10.0`). Flutter projects also need a Flutter SDK compatible with that Dart constraint.

After adding a schema file, generate its `.kfg.dart` part:

```sh
dart run build_runner build -d
```

Keep generation running during schema development with `dart run build_runner watch -d`. See the complete [Code generation](docs/schema/code-generation) guide for annotation, part naming, output shape, and troubleshooting. Generated files should be committed; generation is a development-time step, not runtime work.
