---
title: Discriminated unions
description: Validate alternative object shapes using a discriminator and model generated variant types.
---

`ks.discriminatedUnion<T>(discriminator, variants, {className, error})` selects one `KSObject` schema from a map keyed by discriminator value. Every variant is an object schema; a missing or unknown discriminator is an error. The builder supports `optional()` and `nullable()`, plus `validateMap` and `validateMapAsync` for runtime maps.

```dart
enum PaymentKind { card, invoice }

final paymentSchema = ks.discriminatedUnion<Object?>(
  'kind',
  {
    'card': ks.object({'kind': ks.string(), 'lastFour': ks.string().length(4)}),
    'invoice': ks.object({'kind': ks.string(), 'purchaseOrder': ks.string()}),
  },
);
```

The discriminator is used to select a branch; ensure each variant schema describes the fields of that branch. Union optional/nullable behavior handles missing values at runtime, while generated variant nullability follows the parsed schema shape and generator rules.

## Generated variants and references

When the generator sees a union in a supported static schema expression, it emits a base model and sealed variant model classes, together with variant-specific field references. Narrow to the active discriminator before reading a variant reference; a reference for another branch does not resolve as a valid field for the current value. For list rows, replace the variant with `updateById` while preserving the row's `clientId`.

The union schema defines data validation, not widgets or variant switching UI. See [code generation](docs/schema/code-generation) for generated types and [Flutter union rendering](docs/flutter/unions) for conditional controls.