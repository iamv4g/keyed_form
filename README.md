# keyed_form

A react-hook-form + zod analogue for Flutter, built on keyed optics.

A Dart pub workspace of six packages:

```
keyed_lens              (pure Dart, zero deps) — general-purpose keyed optics
 └── keyed_form_core     (depends on keyed_lens) — shared form vocabulary
       ├── keyed_form_schema   (+ uuid) — schema / validation DSL
       │     └── keyed_form_gen   (dev-time codegen; runtime-deps keyed_form_core)
       └── keyed_form      (+ package:listen + meta; pure Dart) — form controller
             └── keyed_form_flutter   (+ flutter sdk) — the Flutter binding
```

| Package | Role |
|---|---|
| [`keyed_lens`](packages/keyed_lens) | Composable keyed optics (`Lens`/`AffineLens`/`Prism`/`FieldKey`) — reusable beyond forms |
| [`keyed_form_core`](packages/keyed_form_core) | Shared form vocabulary: `FieldRef` / `StrictFieldRef` / `VariantRef`, `FieldErrors`, `@keyedSchema` |
| [`keyed_form_schema`](packages/keyed_form_schema) | Declarative schema / validation DSL (`ks.*`); re-exports `keyed_form_core` |
| [`keyed_form_gen`](packages/keyed_form_gen) | `build_runner` codegen: schema → data class + field references + validation |
| [`keyed_form`](packages/keyed_form) | Pure-Dart form controller (`KeyedFormController`, react-hook-form analogue) |
| [`keyed_form_flutter`](packages/keyed_form_flutter) | Flutter binding (`KeyedFormScope`, `KeyedFormField`, `KeyedFieldList`) |

## Development

This is a native [Dart pub workspace](https://dart.dev/tools/pub/workspaces)
(Dart 3.6+) — no `melos` required for local dev + CI.

```bash
dart pub get                 # resolves all 6 packages at once, from the root
dart analyze                 # or flutter analyze, for keyed_form_flutter
dart test                    # per package; keyed_form_flutter needs flutter test
```

## Examples

The same "Kyoto tour" runs through every package, bottom to top:

| Package | Example | Run |
|---|---|---|
| `keyed_lens` | [`example/`](packages/keyed_lens/example/keyed_lens_example.dart) — raw keyed optics | `dart run example/keyed_lens_example.dart` |
| `keyed_form_core` | [`example/`](packages/keyed_form_core/example/keyed_form_core_example.dart) — the `FieldRef` vocabulary + `FieldErrors` | `dart run example/keyed_form_core_example.dart` |
| `keyed_form_schema` | [`example/`](packages/keyed_form_schema/example/keyed_form_schema_example.dart) — the `ks.*` DSL + `validateMap` | `dart run example/keyed_form_schema_example.dart` |
| `keyed_form_gen` | [`example/`](packages/keyed_form_gen/example/) — schema → generated models / refs / validators | `dart run build_runner build && dart run lib/main.dart` |
| `keyed_form` | [`example/`](packages/keyed_form/example/keyed_form_example.dart) — the `KeyedFormController` | `dart run example/keyed_form_example.dart` |
| `keyed_form_flutter` | [`examples/showcase/`](packages/keyed_form_flutter/examples/showcase/) — a sign-in form that pushes a full web/desktop tour builder | `dart run build_runner build && flutter run -d chrome` |

## License

MIT — see [LICENSE](LICENSE).
