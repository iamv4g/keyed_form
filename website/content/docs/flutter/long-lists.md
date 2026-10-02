---
title: Lists and virtualization
description: Render stable keyed rows in lazy Flutter lists while the controller retains off-screen form state.
---

Flutter may dispose widgets outside a lazy viewport. Form values, errors, and row identity live in the controller, so a row's state does not disappear just because its widget unmounts. `KeyedFieldList<Root, Item>` observes the list's row set and order; edits within each row are handled by the nested field bindings.

Build each row with its stable `clientId`, not its current index, both for the widget key and generated nested field refs:

```dart
KeyedFieldList<TourSchema, StopSchema>(
  field: TourFields.stops,
  builder: (context, stops, list) => ListView.builder(
    itemCount: stops.length,
    itemBuilder: (context, index) {
      final stop = stops[index];
      final fields = TourFields.stop(stopClientId: stop.clientId);
      return Card(
        key: ValueKey(stop.clientId),
        child: KeyedFormField.text<TourSchema>(
          field: fields.city,
          builder: (context, field, text) => TextField(
            controller: text,
            decoration: InputDecoration(errorText: field.errorText),
          ),
        ),
      );
    },
  ),
)
```

A `KeyedFieldList` rebuilds when rows are added, removed, or reordered; it does not rebuild just because a field inside a row changed. The provided `KeyedFormList` supports collection operations while generated field references address nested data by row identity. See the [packing-list walkthrough](docs/guides/dynamic-lists) and the [packing example source](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form_flutter/example/lib/packing_list).

A mounted field can be revealed precisely on submit. An unbuilt lazy row has no anchor yet, so long-list error navigation needs the application's coarse section scroll before registry reveal; see [submit and scroll to error](docs/flutter/scroll-to-first-error).
