# keyed_form

A react-hook-form + zod analogue for Flutter, built on keyed optics.

A Dart pub workspace of five packages:

```
keyed_lens          (pure Dart, no deps on the others)
 ├── keyed_schema    (depends on keyed_lens)
 │     └── keyed_form_gen   (depends on keyed_lens + keyed_schema; dev-time code generator)
 └── keyed_form      (depends on keyed_lens + package:listen + meta; pure Dart)
       └── keyed_form_flutter   (depends on keyed_form + flutter sdk; the Flutter binding)
```

| Package | Role |
|---|---|
| [`keyed_lens`](packages/keyed_lens) | Keyed optics (`Lens`/`AffineLens`/`FieldKey`) — the foundation |
| [`keyed_schema`](packages/keyed_schema) | Declarative schema/validation DSL built on `keyed_lens` |
| [`keyed_form_gen`](packages/keyed_form_gen) | `build_runner` codegen: schema → data class + lenses + validation |
| [`keyed_form`](packages/keyed_form) | Pure-Dart form controller (`KeyedFormController`, react-hook-form analogue) |
| [`keyed_form_flutter`](packages/keyed_form_flutter) | Flutter binding (`KeyedFormScope`, `KeyedFormField`, `KeyedFieldList`) |

## Development

This is a native [Dart pub workspace](https://dart.dev/tools/pub/workspaces)
(Dart 3.6+) — no `melos` required for local dev + CI.

```bash
dart pub get                 # resolves all 5 packages at once, from the root
dart analyze                 # or flutter analyze, for keyed_form_flutter
dart test                    # per package; keyed_form_flutter needs flutter test
```

## License

MIT — see [LICENSE](LICENSE).
