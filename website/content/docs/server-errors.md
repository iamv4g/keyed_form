---
title: Server errors
description: Map backend validation paths onto the matching typed fields after a failed request.
---

For a validation response such as HTTP 422, pass its path-to-message map to `setServerErrorPaths`:

```dart
try {
  await api.submitTour(form.value);
} on ApiException catch (error) {
  if (error.statusCode == 422) {
    form.setServerErrorPaths(
      Map<String, String>.from(error.responseBody['errors']),
    );
  }
}
```

The controller resolves matching paths onto the corresponding fields so their normal error UI can display the message.

## Dynamic list paths

Address a row with its real `clientId`, for example `stops.['$clientId'].city`. Array paths such as `stops.0.city` do not identify a stable row and will not map to the row field. Include the client id in the submitted data if the server needs to return row-specific errors.

For server-backed checks before submit, see [async validation](docs/async-validation).
