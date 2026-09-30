---
title: Cascading dropdowns
description: Reset dependent selections when a source field changes, while keeping option fetching in application code.
---

When a country changes, clear dependent state and city selections before loading options for the new country. Register a relation once and retain its unsubscribe callback with the owning screen:

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

@override
void dispose() {
  unsubscribe();
  form.dispose();
  super.dispose();
}
```

Relation registration does not call the change callback immediately, so initialize the derived value explicitly if the initial draft needs one. A readonly destination may require `force: true` for a derived write. See [Relations](docs/form-state/relations) for lifecycle and write behavior.

Fetching state and city options is application-owned asynchronous work, not part of the relation mechanism. Fetch based on the selected parent and guard against stale responses if users change the parent before a request completes. Keep network failures distinct from validation errors. See [Form State](docs/form-state) for the underlying controller.
