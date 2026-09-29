---
title: Cascading dropdowns
description: Use relations to clear dependent selections when a parent selection changes.
---

When a country changes, clear the selected state and city, then load the new options. Register the relationship once and keep its unsubscribe callback with the owning screen:

```dart
late final VoidCallback unsubscribe;

void initRelations() {
  unsubscribe = form.addRelation(
    LocationFields.country,
    (country) => country,
    (_) {
      form.field(LocationFields.state).set(null, force: true);
      form.field(LocationFields.city).set(null, force: true);
    },
  );
}
```

Load option lists from the selected parent and guard against stale requests if users change the parent quickly. Dispose the relation callback with the screen. See [relations](docs/relations) for derived values.
