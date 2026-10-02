---
title: Discriminated unions
description: Model variant-specific form fields and access them through narrowed variant references.
---

Use a discriminated union when a form section has mutually exclusive shapes, such as a personal or business account. A variant reference is valid only while the value has that variant.

## Render the active variant

Inside a row widget, `fields` is that row's generated `ActivityFieldRefs`. Read its current discriminator with a selector, then render the matching generated variant reference. A `VariantFieldRef` resolves only while the row contains that variant; after a switch, the old branch's fields stop resolving instead of reading stale data.

```dart
KeyedFormSelector<ItinerarySchema, String?>(
  selector: (form) => fields.getOrNull(form.value)?.kind,
  builder: (context, kind, _) => switch (kind) {
    'sightseeing' => KeyedFormField.text<ItinerarySchema>(
      field: fields.asSightseeing.place,
      builder: (context, field, controller) => TextField(
        controller: controller,
        decoration: InputDecoration(errorText: field.errorText),
      ),
    ),
    'meal' => KeyedFormField.text<ItinerarySchema>(
      field: fields.asMeal.restaurant,
      builder: (context, field, controller) => TextField(
        controller: controller,
        decoration: InputDecoration(errorText: field.errorText),
      ),
    ),
    _ => const SizedBox.shrink(),
  },
);

activityList.updateById(
  activity.clientId,
  (current) => kind == 'sightseeing'
      ? SightseeingActivitySchema.create(clientId: current.clientId)
      : MealActivitySchema.create(clientId: current.clientId),
);
```

The selector reads the row's current discriminator because switching variants keeps the same `clientId`; the outer list's row snapshot may therefore stay unchanged. `updateById` replaces the row with the selected generated shape while preserving its identity. The schema uses `ks.discriminatedUnion('kind', ...)` and the generator creates variant accessors such as `fields.asSightseeing` and `fields.asMeal`.

Keep shared fields outside the union and validate each branch in its own schema. See [how it works](docs/how-it-works) for the role of `VariantFieldRef`.
