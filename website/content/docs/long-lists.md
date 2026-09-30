---
title: Long lists
description: Virtualized lists can dispose off-screen widgets while the controller keeps values and row state.
---

Flutter lazily disposes off-screen item widgets. With `keyed_form`, the draft, validation state, and row identity live in the controller, so scrolling a row out of view does not erase its data.

## Use the stable row id

Use `KeyedFieldList` to build list rows and key each row widget by `clientId`. Build field references from that same id:

```dart
KeyedFieldList<TourSchema, StopSchema>(
  field: TourFields.stops,
  builder: (context, stops, list) => ListView.builder(
    itemCount: stops.length,
    itemBuilder: (context, index) {
      final stop = stops[index];
      return Card(
        key: ValueKey(stop.clientId),
        child: KeyedFormField.text<TourSchema>(
          field: TourFields.stop(stopClientId: stop.clientId).city,
          builder: (context, field, controller) => TextField(
            controller: controller,
            decoration: InputDecoration(errorText: field.errorText),
          ),
        ),
      );
    },
  ),
)
```

The list handle supports `move`, `removeById`, `append`, and `insertAfter`. See [dynamic lists](docs/dynamic-lists) for the live example.

## When the first invalid row is off screen

`handleSubmit` can reveal a mounted field. A row that has not been built by `ListView.builder` has no anchor yet, so a long list needs a coarse scroll to its section first. Then call `KeyedFieldRegistry.revealFirst` to bring the mounted field into view and focus it. See [scroll to first error](docs/scroll-to-first-error).
