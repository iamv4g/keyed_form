# keyed_form_flutter

The Flutter binding for [`keyed_form`](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form). Wrap an editor
subtree in a `KeyedForm` to publish its `KeyedFormController`, then bind
each field with `KeyedFormField`. Re-exports all of `keyed_form` (and thus
`keyed_form_core`), so a screen needs one import:
`package:keyed_form_flutter/keyed_form_flutter.dart`.

## Installation

```yaml
dependencies:
  keyed_form_flutter: ^0.1.0
  keyed_form_schema: ^0.1.0

dev_dependencies:
  build_runner: ^2.15.0
  keyed_form_gen: ^0.1.0
```

## Quick start

Declare the form's shape as a schema, generate a data class and typed
field references from it, then build the controller and widgets against
those generated names.

```dart
// signup_schema.dart
@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'signup_schema.kfg.dart';

final _signupSchema = ks.object({
  'email': ks.string(error: .text('Email is required'))
      .email(error: .text('Enter a valid email')),
  'password': ks.string(error: .text('Password is required'))
      .min(8, error: .text('At least 8 characters')),
});
```

```bash
dart run build_runner build
```

This writes `signup_schema.kfg.dart` next to the schema file (commit it —
it's real source) with `class SignupSchema` (`email`, `password`,
`.create()`, `.validate()`, `static .validateData`) and
`abstract final class SignupFields` (`.email`, `.password`).

```dart
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

final form = KeyedFormController<SignupSchema>(
  initialValue: SignupSchema.create(),
  mode: KeyedFormMode.onTouched,
  resolver: SignupSchema.validateData,
);

// build():
KeyedForm<SignupSchema>(
  controller: form,
  child: Column(
    children: [
      KeyedFormField.text<SignupSchema>(
        field: SignupFields.email,
        builder: (context, state, controller) => TextField(
          controller: controller,
          onTapOutside: (_) => state.onBlur(),
          decoration: InputDecoration(labelText: 'Email', errorText: state.errorText),
        ),
      ),
      KeyedFormField.text<SignupSchema>(
        field: SignupFields.password,
        builder: (context, state, controller) => TextField(
          controller: controller,
          obscureText: true,
          onTapOutside: (_) => state.onBlur(),
          decoration: InputDecoration(labelText: 'Password', errorText: state.errorText),
        ),
      ),
      // handleSubmit needs a context from *inside* the tree KeyedForm builds
      // (see "context and handleSubmit" below) — Builder is the cheapest way
      // to get one when nothing else in the subtree already provides it.
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => form.handleSubmit(context, (value) async {
            // value.email, value.password — already validated.
          }),
          child: const Text('Sign up'),
        ),
      ),
    ],
  ),
)

// dispose():
form.dispose();
```

Nothing is shown as invalid until a field is touched (in `onTouched` mode,
that means blurred) — a submit attempt always makes every error visible,
regardless of mode.

### Context and `handleSubmit`

`context` for `handleSubmit` (and for `KeyedForm.controllerOf` /
`registryOf` / `translateErrorOf`) must come from inside the `KeyedForm`
subtree — the `context` a builder callback hands you (a `Builder`'s, a
`KeyedFormField`'s, a `KeyedFormSelector`'s), not the `context` of the
widget that *created* the `KeyedForm` (that one sits above it in the tree,
so an ancestor lookup from it fails).

## Binding a dynamic list

```dart
KeyedFieldList<InvoiceForm, LineItem>(
  field: InvoiceFields.lineItems,
  builder: (context, items, list) => Column(children: [
    for (final item in items)
      LineItemCard(key: ValueKey(item.clientId), id: item.clientId),
    AddButton(onPressed: () => list.append(LineItem.create())),
  ]),
)
```

`InvoiceForm`/`InvoiceFields`/`LineItem` here are the generated class and
field references from your own schema, the same way `SignupSchema` /
`SignupFields` are above. `KeyedFieldList` rebuilds only when the row set
changes (add/remove/reorder); `LineItemCard` — one `KeyedFormField` per
field inside it — handles edits within a row.

## More

- [`skills/keyed_form/SKILL.md`](https://github.com/iamv4g/keyed_form/blob/main/skills/keyed_form/SKILL.md) — the
  full API reference: cross-field and async validation, read-only fields,
  derived fields, scroll-to-first-error in a lazy list, and more.
- [`example/`](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form_flutter/example) — a runnable app, one screen per
  pattern; see [`example.md`](https://github.com/iamv4g/keyed_form/blob/main/packages/keyed_form_flutter/example/example.md)
  for the guide.

## Pieces

| Piece | What it is |
|---|---|
| `KeyedForm<Root>` | Publishes a `KeyedFormController<Root>` down the widget tree and owns a `KeyedFieldRegistry` internally — apps never construct one. `controllerOf` / `registryOf` / `translateErrorOf` read it back from a descendant context (see the context rule above) |
| `KeyedFormField<Root, V>` | Binds one `FieldRef` to the ambient controller — see below |
| `KeyedFieldList<Root, Item>` | Binds one list field and rebuilds only when the row set changes (add/remove/reorder); edits *within* a row are the job of the `KeyedFormField`s inside it |
| `context.watchField(ref)` / `context.watchForm<Root>()` / `context.selectForm((f) => slice)` | Read a form slice in a widget's `build()` and rebuild that widget only when the slice changes. Non-reactive reads (`form.field(x).value`, `form.isDirty` in an event handler) are plain getters, no subscription |
| `KeyedFormSelector<Root, T>` | The `context.selectForm` above wrapped in a widget, to scope the rebuild to a subtree, with a non-rebuilt `child` |
| `KeyedFormBuilder<Root>` | Rebuilds on *every* controller change — the escape hatch for a widget that genuinely needs the whole state (a live inspector) |
| `KeyedTextBinding` | A `TextEditingController` two-way bound to an external string value, keeping the caret and IME composing region stable as the value round-trips through the form controller. Design-system agnostic |
| `form.handleSubmit(context, onValid, {onInvalid})` | Validates, and on success runs `onValid` with the draft while toggling `submitting` — see below |
| `KeyedFieldRegistry` / `KeyedFieldAnchor` | Maps `FieldKey`s to live field positions so a form can scroll to (and focus) a field it only knows by identity; `handleSubmit` uses this for you — reach for it directly only for a custom `onInvalid` |

**`KeyedFormField`** rebuilds only when that field's value, visible error,
`isValidating`, `isFailedValidation`, or `isReadOnly` changes.
`KeyedFormField.text` bundles a `KeyedTextBinding` for a `String` field.
Wraps its builder output in a `KeyedFieldAnchor` automatically
(`anchor: false` to opt out) so it participates in scroll-to-first-error
without extra wiring. `KeyedFieldState.isValidating` mirrors
`form.field(ref).isValidating` — render a spinner from it while a field's
own async check (`form.field(ref).validateAsync(...)`) is running;
`isFailedValidation` mirrors a check that threw or timed out (distinct from
`errorText`); `isReadOnly` mirrors a frozen field — pair it with
`enabled: !state.isReadOnly` on the wrapped widget (`onChanged` stays safe
to wire unconditionally, since the controller already no-ops a frozen
write).

**`handleSubmit`** — on failure its default `onInvalid` reveals the first
visible error via the ambient `KeyedFieldRegistry`. Pass `onInvalid` to
override for custom invalid-handling (e.g. scrolling a lazily-built section
list first).

## Scope

Deliberately out of scope: any specific design system (buttons, inputs,
layout) — this package binds *state*, not presentation.
