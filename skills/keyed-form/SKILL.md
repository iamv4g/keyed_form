---
name: keyed-form
description: Builds Flutter forms with the keyed_form packages — the keyed_form_schema `ks.*` schema and validation DSL, keyed_form_gen codegen (@keyedSchema), KeyedFormController, and keyed_form_flutter widgets (KeyedForm, KeyedFormField, KeyedFieldList). Use when defining a form's data shape, adding or editing fields or validation rules (sync, async, cross-field), building a dynamic list of rows, freezing or deriving a field, wiring submit or scroll-to-first-error, or working in a project that depends on keyed_form, keyed_form_schema or keyed_form_flutter, even if the user never says "form".
compatibility: Requires Dart 3.10+ (examples use dot shorthands) and build_runner. Written against keyed_form_* 0.2.x.
---

# keyed-form

The state of a whole form is **one immutable value** (the *draft*) owned by **one controller** (`KeyedFormController<Root>`). Fields are not separate controllers. Each field is addressed inside the draft by a `FieldRef<Root, V>` generated from a schema.

Workflow: declare the shape and rules once as a schema, generate the data class and field refs, then build the controller and widgets against the generated names.

A Flutter app needs one import: `package:keyed_form_flutter/keyed_form_flutter.dart` (it re-exports `keyed_form` and `keyed_form_core`), plus `keyed_form_schema` in schema files. `keyed_form_gen` runs only at build time and is never imported.

## Reference files

Read the file for the task at hand. Each is one level deep and has a contents list.

| Task | Read |
|---|---|
| Define or change a schema, a validation rule, an error message, a row list or a union; understand generated classes | [references/schema.md](references/schema.md) |
| Configure the controller: validation mode, scoped or async validation, submit, read-only, derived fields, dispose | [references/controller.md](references/controller.md) |
| Bind widgets: fields, lists, selectors, blur, localized errors, scroll-to-first-error | [references/widgets.md](references/widgets.md) |

## Quick start

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

Name the schema variable with a **leading underscore**. The generator strips it, so `_signupSchema` generates `SignupSchema` and `SignupFields`, and the schema variable stays out of the library's public names.

Run `dart run build_runner build` (or `watch` while editing). It writes `signup_schema.kfg.dart` next to the schema. Commit it, since it is real source. It defines:

- `class SignupSchema` — fields, `copyWith`, `toMap()`, `==`/`hashCode`, `.create({...})`, `.validate([scope])`, `static .validateData(...)`, `static .scopeOf(...)`.
- `abstract final class SignupFields` — `static StrictFieldRef<SignupSchema, String> get email` and `.password`.

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
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: state.errorText,
          ),
        ),
      ),
      KeyedFormField.text<SignupSchema>(
        field: SignupFields.password,
        builder: (context, state, controller) => TextField(
          controller: controller,
          obscureText: true,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          decoration: InputDecoration(
            labelText: 'Password',
            errorText: state.errorText,
          ),
        ),
      ),
      // handleSubmit needs a context from inside the tree KeyedForm builds.
      // Builder is the cheapest way to get one. To react to `submitting`
      // (disable, spinner), use KeyedFormSelector<SignupSchema, bool> instead;
      // see references/widgets.md.
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

The default mode is `onSubmit`: initial values, `seed` and `reset` do not validate. `onTouched` validates at the first blur and after later writes to that field. Submit always validates a fresh draft and reveals the result. Full mode table: [references/controller.md](references/controller.md).

## Rules that prevent most bugs

1. **Write through `form.field(ref)`** (`.set(value)`, `.update(fn)`, `.list()`), never `form.setField` / `updateField` / `list` / `mutateList`. A `FieldRef<Root, V>` is covariant in `V`, so the direct calls let a wrongly typed value compile and fail with a `TypeError` at runtime. `form.field(ref)` pins `V` from `ref`, so the mistake is a compile error.
2. **Bind every text field with `KeyedFormField.text`**, never a hand-rolled `TextEditingController` + `onChanged`. It tells the user's typing apart from an external overwrite (server patch, derived write). Also wiring the `TextField`'s own `onChanged`, or resetting `.text` on every build, causes caret jumps and breaks IME input.
3. **Build new list rows with `.create(...)`**, never the plain constructor. `.create` fills the row's `clientId`; row identity is `clientId`, not index.
4. **Use a `context` from inside the `KeyedForm` subtree** for `KeyedForm.controllerOf`, `registryOf` and `handleSubmit` (a `Builder`, `KeyedFormField`, `KeyedFormSelector` or `KeyedFormBuilder` context). The `build` parameter of the widget that creates `KeyedForm` sits above it and fails.
5. **Dispose once.** Call `form.dispose()` where the controller is owned, and invoke any `addRelation` unsubscribe callback from the same place. It is not tracked for you.

## Workflows

### Add a field with a rule

Copy and track:

```
- [ ] 1. Add the key to the `ks.object({...})` schema (rules: references/schema.md)
- [ ] 2. Run build_runner; confirm `<Schema>Fields.<key>` exists
- [ ] 3. Bind it with KeyedFormField.text (or KeyedFormField for non-text)
- [ ] 4. Required int/double/number/enum? Add .defaultTo(...) for a non-nullable field
- [ ] 5. Submit once with the field empty and check errorText shows
```

### Migrate a hand-rolled form

1. Move each field's shape and rules into one `ks.object` schema; run build_runner.
2. Replace the `TextEditingController` + `onChanged` pair with `KeyedFormField.text` and its `controller`.
3. Replace manual error state with `state.errorText`.
4. Replace the submit handler's manual checks with `form.handleSubmit(context, ...)`.
5. Delete the old controllers and their `dispose()` calls.

### Add a list of rows

1. Add `ks.list(ks.object(className: 'RowSchema', {...}))` to the schema; run build_runner.
2. Render with `KeyedFieldList`, giving each row's subtree a `ValueKey` on its `clientId`.
3. Edit rows through `form.field(ref).list()`; create them with `.create(...)`.
4. Reach a row's fields with the generated `<Fields>.<row>((<row>: clientId)).<field>`.

Details: [references/schema.md](references/schema.md) and [references/widgets.md](references/widgets.md).

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `TypeError` at runtime on a field write | Called `form.setField` / `updateField` directly | Use `form.field(ref).set(...)` |
| Caret jumps; composed (IME) text breaks | Hand-rolled controller, or `onChanged` wired next to `KeyedFormField.text` | Remove it; use the `controller` the builder hands you |
| Ancestor lookup fails in `controllerOf` / `handleSubmit` | `context` is from above `KeyedForm` | Use a `Builder` (or field/selector) context |
| Generated field is nullable though the rule is required | `int` / `double` / `number` / `enums` have no implicit default | Add `.defaultTo(...)` |
| Async-validation error thrown | Sync `validate` called while an async `.refine()` exists | Use `validateAsync` / `validateMapAsync` everywhere in that chain |
| A write does not revalidate | `scopeOf` returned `null` for that key | Return a scope, or validate explicitly |
| Debug assertion about out-of-scope keys | Resolver returned error keys outside the given scope | Return only keys inside the scope |
| Submit does not scroll to an error | Field is in a lazily built region (`ListView.builder`) | Pass a custom `onInvalid` ([references/widgets.md](references/widgets.md)) |
| Dirty tracking or no-op writes misbehave | Model or row class lacks structural `==` / `hashCode` | Use generated classes, or add them |
| Cascade on `ks.*` has no effect | `ks.string()..min(3)` discards the new instance | Chain or assign: `ks.string().min(3)` |
| A frozen leaf stays frozen after `unmarkReadOnly` | An ancestor key was frozen | Unmark the ancestor's key |
| A field is still frozen after `reset()` / `seed()` | Read-only is configuration and survives both (touched, revealed, validating and failed state clear) | Call `unmarkReadOnly` explicitly |
