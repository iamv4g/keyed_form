---
title: Rendering union fields
description: Select the active generated variant and update union rows without changing their stable identity.
---

A discriminated-union reference resolves only when the current value has its matching variant. Observe the discriminator, then render that variant's generated fields; after switching, controls for the old branch no longer resolve. The schema and generated variant model are described in [Schema unions](docs/schema/unions).

```dart
KeyedFormSelector<ItinerarySchema, String?>(
  selector: (form) => fields.getOrNull(form.value)?.kind,
  builder: (context, kind, _) => switch (kind) {
    'sightseeing' => KeyedFormField.text<ItinerarySchema>(
      field: fields.asSightseeing.place,
      builder: (context, field, text) => TextField(controller: text),
    ),
    'meal' => KeyedFormField.text<ItinerarySchema>(
      field: fields.asMeal.restaurant,
      builder: (context, field, text) => TextField(controller: text),
    ),
    _ => const SizedBox.shrink(),
  },
)
```

When a union is inside a keyed list, update the row by `clientId` and preserve that ID while replacing its variant shape. The selector is important: the row identity remains stable across the variant change, while the selected discriminator changes the rendered branch. Generated APIs such as `asSightseeing` and `asMeal` depend on the declared variant names; use the refs emitted for your schema rather than inventing a variant accessor. See [virtualized lists](docs/flutter/long-lists) and [selective rebuilds](docs/flutter/reactivity). For a complete repository example, browse the [tour builder source](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form_flutter/example/lib/tour_builder).
