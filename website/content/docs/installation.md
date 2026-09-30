---
title: Installation
description: Two runtime packages, one generator, and you're ready to write a schema.
---

Add the runtime packages to your Flutter app, and the generator as a dev dependency:

```sh
flutter pub add keyed_form_flutter keyed_form_schema
flutter pub add -d keyed_form_gen build_runner
```

`keyed_form_flutter` re-exports the controller, so a Flutter app needs a single import:

```dart
import 'package:keyed_form_flutter/keyed_form_flutter.dart';
```

## Generate once, then on every schema change

Schemas live in files annotated with `@keyedSchema`. The generator turns each one into an immutable model, typed field refs and a validator:

```sh
dart run build_runner build -d
```

<Note>

Commit the generated `*.kfg.dart` files. **Nothing is generated at runtime**, so a fresh checkout builds without running the generator.

</Note>

Keep it running while you work with `dart run build_runner watch -d`.

## Requirements

- Dart 3.10 or newer
- Flutter, only for `keyed_form_flutter` — the schema, generator and controller are pure Dart
