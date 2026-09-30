---
title: Errors and localization
description: Understand schema issue types, message precedence, lazy localization, and keyed validation errors.
---

Schema validation returns `FieldErrors<String>` keyed by `FieldKey`. Keys preserve field and row identity; a nested collection error can target a path instead of an array index. `KSIssue` values distinguish invalid type, size/boundary, format, and custom-rule failures, including the relevant input and rule metadata.

## Message resolution

`KSError.text('...')` supplies a fixed message and `KSError.builder(...)` computes a message from issue context and locale when validation resolves it. Resolution considers a rule-specific error first, then the validator's configured error, then the built-in issue message. A lazy builder that returns null falls through rather than erasing the issue message.

```dart
final schema = ks.object({
  'email': ks.string(error: .text('Enter an email')).email(
    error: .builder((issue, locale) => locale == 'fr'
        ? 'Adresse e-mail invalide'
        : null),
  ),
});
```

Locale lookup is lazy, so a localized message can use the locale available at validation time rather than capturing one at schema construction. Custom refinement `params` are available as issue data for application-specific message resolution.

## Keyed errors and rule placement

Use object refinement `path` / `key` to select where a cross-field issue appears; `key` overrides `path`, and neither supplied means the object root. Scalar validators stop at their first failed rule, so an error list is not a promise to report all scalar issues at once. See [refinements](docs/schema/refinements) for sync/async execution and targeting, and [objects and collections](docs/schema/composition) for map and nested traversal limits.

A backend rejection is not the same as a schema issue: keep transport failures separate from invalid-value messages. Controller-facing server errors are covered in [Form State server errors](docs/form-state/server-errors).