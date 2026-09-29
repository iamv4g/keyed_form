---
title: Discriminated unions
description: Model variant-specific form fields and access them through narrowed variant references.
---

Use a discriminated union when a form section has mutually exclusive shapes, such as a personal or business account. A variant reference is valid only while the value has that variant.

## Narrow before reading

Use the generated union discriminator and `.narrow()` to access variant-specific fields. If the user switches variants, references into the previous shape stop resolving instead of reading stale data.

```dart
final business = AccountFields.details.narrow<BusinessDetails>();
final taxId = form.field(business.taxId);
if (taxId.value case final value?) {
  print(value);
}
```

Keep shared fields outside the union and validate each branch in its own schema. See [how it works](docs/how-it-works) for the role of `VariantRef`.
