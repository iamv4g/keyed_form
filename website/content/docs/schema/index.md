---
title: Schema
description: Validate untyped data with composable pure-Dart rules, then optionally generate typed models and field references.
---

Keyed Form Schema is a pure-Dart validation layer. You can use it on its own; code generation is an optional workflow for typed immutable models and references.

```dart
import 'package:keyed_form_schema/keyed_form_schema.dart';

final schema = ks.object({
  'email': ks.string().email(),
  'age': ks.int().min(18),
});

final errors = schema.validateMap({'email': 'person@example.com', 'age': 17});
```

`validateMap` returns keyed errors for invalid fields; it does not require generated classes or Flutter. Start with the [builder and rule catalog](docs/schema/builders), then see [objects and collections](docs/schema/composition), [refinements and async validation](docs/schema/refinements), and [code generation](docs/schema/code-generation). For variant-shaped data, see [discriminated unions](docs/schema/unions).