# keyed_form_gen example

One declarative schema → immutable data classes, keyed field references and
validators.

| File | What it is |
| --- | --- |
| [`lib/tour_schema.dart`](lib/tour_schema.dart) | the hand-written schema (`@keyedSchema library;` + one `ks.object({...})`) |
| [`lib/tour_schema.kfg.dart`](lib/tour_schema.kfg.dart) | **generated** — `TourSchema` / `StopSchema` data classes, `TourFields` / `StopFieldRefs` references, `StopRef`, `validate()` |
| [`lib/main.dart`](lib/main.dart) | uses the generated code |

```bash
dart run build_runner build   # (re)generate lib/tour_schema.kfg.dart
dart run lib/main.dart
```

`build_extensions` maps `foo.dart` → `foo.kfg.dart` and the builder writes
`build_to: source`, so the generated file lands next to the schema and is
committed.
