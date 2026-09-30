---
title: Server errors
description: Merge backend field errors into normal keyed form state using FieldKey identities.
---

A backend validation response is different from a transport failure. For a validation response such as HTTP 422, translate its field paths into keyed errors so ordinary field bindings can render them:

```dart
try {
  await api.save(form.value.toMap());
} on ApiException catch (error) {
  if (error.statusCode == 422) {
    form.setServerErrorPaths(
      Map<String, String>.from(error.responseBody['errors']),
    );
  } else {
    showTransportError(error);
  }
}
```

`setServerErrors(Map<FieldKey, String>)` merges messages into the current error map, force-reveals those keys, sets `submitted`, and notifies listeners. Existing errors not replaced by the response remain. A transport exception should be shown as a request-level problem, not attached to a field unless the server supplied a field validation verdict.

`setServerErrorPaths(Map<String, String>)` parses the wire representation of `FieldKey.toPath`. Invalid path syntax throws `FormatException`; catch or reject malformed backend data at the API boundary rather than assuming every string is usable.

## Dynamic list row paths

Address a list row by its stable `clientId`, never by its current index. For example, a city field path has the form `stops.['row-42'].city`. The row id must be the actual `clientId` used by the model and generated row reference. Positional paths such as `stops.0.city` do not identify a stable row and do not map to that row's field. If the backend returns row-specific errors, include a correlation/client identifier in the request so the response can refer to the same row identity.

```dart
form.setServerErrorPaths({
  "stops.['${stop.clientId}'].city": 'City is not recognised',
});
```

The errors are merged and revealed like other server errors. A later local resolver run only replaces the scope it validates; use the appropriate validation/error lifecycle when reconciling a server verdict with edits. For pre-submit availability checks see [Async validation](docs/form-state/async-validation).
