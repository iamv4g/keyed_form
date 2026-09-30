---
title: Flutter
description: Bind pure-Dart keyed form state to Flutter controls, rebuilds, lists, and submission.
---

The Flutter package binds a `KeyedFormController` to widgets; it does not replace the shared schema or controller. Start with [form scope and context](docs/flutter/form-context), choose a [field binding](docs/flutter/field-bindings) or [text binding](docs/flutter/text-binding), then use [selective rebuilds](docs/flutter/reactivity), [virtualized lists](docs/flutter/long-lists), and [submit/error reveal](docs/flutter/scroll-to-first-error) as needed. Schema definitions and pure-Dart state remain usable without Flutter.

```dart
KeyedForm<LoginSchema>(
  controller: form,
  child: KeyedFormField.text<LoginSchema>(
    field: LoginFields.email,
    builder: (context, field, text) => TextField(
      controller: text,
      decoration: InputDecoration(errorText: field.errorText),
    ),
  ),
)
```

See [installation](docs/guides/installation) and [quickstart](docs/guides/quickstart). For variant-specific controls, see [rendering union fields](docs/flutter/unions).
