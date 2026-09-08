# keyed_form_benchmark

A DX + performance comparison harness:
**`keyed_form` vs `reactive_forms` vs `flutter_form_builder`**.

Not published, not a workspace dependency of anything — it only *consumes* the
three libraries so they can be driven through one interface against one form
shape.

```
tool/run.sh                       # parity gate + every suite, JSON -> benchmark_results/
flutter test test/parity_test.dart
flutter test test/model_benchmark_test.dart  --tags benchmark
flutter test test/rebuild_benchmark_test.dart --tags benchmark
```

## What is measured against what

One form shape (`lib/scenario.dart`), swept by size:

* `fieldCount` flat text fields, each **required + minLength(3)**;
* `rowCount` rows in one dynamic list — `{ city required, nights int }`;
* one cross-field rule: `sum(nights) <= maxNights`.

The rules are deliberately trivial so the numbers reflect each **library's
bookkeeping** (copy / diff / validate-dispatch / notify / rebuild), not
validator cost.

| library | version | field value type | write dispatch | dirty | validity |
|---|---|---|---|---|---|
| `keyed_form` | 0.1.0 (this repo) | immutable draft, `FieldRef` lens | resolver re-run (whole draft, or scoped subtree) | whole-draft `==` | `errors.isEmpty` |
| `reactive_forms` | ^18.2 | `FormControl<T>` + streams | that control's validators + parent status bubble | per-control flag | cached status |
| `flutter_form_builder` | 10.3.x¹ | `FormBuilderField` widget state | `didChange` on the field's `State` | `any(field.isDirty)` | `every(field.isValid)` |

¹ pinned `<11.0.0`: 11.x moved off `package:flutter/material` onto
`package:material_ui`, which most apps have not adopted.

Two `keyed_form` variants are run: **whole** (the simplest wiring — resolver
re-checks everything on every write) and **scoped** (`scopeOf`, so a flat-field
write only re-validates that field — the apples-to-apples match for
reactive_forms' per-control model).

`flutter_form_builder` has **no model layer** — it does nothing without a
widget tree — so it appears only in the widget benchmark.

`test/parity_test.dart` is the fairness gate: it asserts all harnesses model
the same form and agree on validity/dirty/row-count through a scripted edit
sequence. Run it before trusting any number.

## Results snapshot

> Debug `flutter test` on an M-series laptop, 2026-09. **Rebuild counts are
> deterministic**; µs figures are directional only — for real latency run in
> profile mode on a device.

### Model layer — `flutter test test/model_benchmark_test.dart` (median µs)

| op | lib | 10f | 50f | 100f | 250f |
|---|---|--:|--:|--:|--:|
| **build** | keyed_form | 7 | 4 | 8 | 20 |
| | reactive_forms | 201 | 390 | 719 | 1757 |
| **setField** (1 write + revalidate) | keyed_form (whole) | 14 | 5 | 7 | 17 |
| | keyed_form (scoped) | 13 | 5 | 8 | 17 |
| | reactive_forms | 22 | 18 | 22 | 35 |
| **isDirty** | keyed_form (`==` whole draft) | 0.02 | 0.03 | 0.02 | 0.02 |
| | reactive_forms (flag) | ~0 | ~0 | ~0 | ~0 |
| **isValid** | either | ~0 | ~0 | ~0 | ~0 |

Row churn (`addRow + removeRow`, 20f+20r): keyed_form ~17–23 µs,
reactive_forms ~65 µs.

Takeaways: `keyed_form` builds a form ~50–100× cheaper (no per-field
control/stream objects) and writes ~2–4× cheaper. The "immutability tax" on
`isDirty` — a full-draft `==` every check — is **not** measurable at these
sizes. `scoped` vs `whole` barely differ here because the ruleset is tiny; the
gap widens with expensive validators.

### Widget layer — one keystroke, `test/rebuild_benchmark_test.dart`

Widget rebuilds triggered in the whole tree by typing into **one** field
(focus already settled), by form size:

| library | 10f | 50f | 100f | 250f |
|---|--:|--:|--:|--:|
| `keyed_form_flutter` | 43 | 43 | 43 | 43 |
| `reactive_forms` | 45 | 45 | 45 | 45 |
| `flutter_form_builder` | 261 | 1221 | 2421 | 6021 |

`keyed_form` and `reactive_forms` are **O(1)** — only the edited field's
subtree rebuilds (the ~44 constant is `EditableText` + overlay/gesture
framework internals for that one field). `flutter_form_builder` is **O(N)**:
every `FormBuilderField` (`AnimatedBuilder` / `Actions` / `_ActionsScope` …)
rebuilds on every keystroke because they all listen to the shared
`FormBuilderState`.

The `keyed_form` design point to keep watching: **every** `KeyedFormField`
adds a listener to the whole controller, so a write fires N listener callbacks
(each reads its value + diffs, then almost always no-ops). That is not a
rebuild, so it does not show above — it shows in the post-keystroke `pump`
time. Through 250 fields it stayed even with reactive_forms (~8–10 ms in
debug); probe higher N in profile mode if you target very large forms.

## DX comparison

Build the same "tour builder" (nested object + dynamic list + cross-field rule
+ async server errors + dirty tracking + scroll-to-first-error) in each and
score:

| dimension | keyed_form | reactive_forms | flutter_form_builder |
|---|---|---|---|
| source of truth | one immutable aggregate | tree of `FormControl`s | field widgets' `State` |
| field addressing | typed `FieldRef` (generated) | `String` name | `String` name |
| `field.set(wrongType)` | **compile error** | not checked (dynamic) | not checked (dynamic) |
| rename a model field | compile breaks at every use | silent runtime break | silent runtime break |
| test without widgets | yes (pure Dart) | yes (model layer) | **no** |
| codegen (build_runner) | yes (`keyed_form_gen`) | no | no |
| dynamic list | `field(ref).list()` by id | `FormArray` by index | `FormBuilder` + manual list |
| server errors by path | `setServerErrorPaths` | manual | manual |
| selective rebuild | yes (O(1)) | yes (O(1)) | no (O(N)) |
| Flutter-free core | yes | no | no |

Fill the qualitative half by having 2–3 devs unfamiliar with each library
implement one task, timed, with friction notes.

## Files

```
lib/scenario.dart            the one form shape + size sweep
lib/kf_form.dart             the keyed_form model/refs/resolver (shared)
lib/src/measure.dart         warmup + percentile timing helper + JSON report
lib/model/*_harness.dart     ModelHarness: build / setField / addRow / isValid / isDirty
lib/widget/*_harness.dart    WidgetHarness: the form as real widgets, findable fields
test/parity_test.dart        fairness gate
test/model_benchmark_test.dart
test/rebuild_benchmark_test.dart
```

## Caveats

* The `keyed_form` model here is `Map`-backed; a generated model is a class
  with N typed fields whose `copyWith` also rebuilds the whole object, so the
  per-write allocation is representative but not identical.
* `reactive_forms` `updateValue` leaves a control pristine; the harness calls
  `markAsDirty()` after, mirroring what its widgets do.
* Debug-mode `flutter test` timings carry fake-async and assertion overhead —
  treat µs columns as ratios, not latencies. Rebuild counts are exact.
* Adding this package to the workspace pulls `reactive_forms` +
  `flutter_form_builder` into the shared lockfile. Drop it from the root
  `workspace:` list if that is unwanted.
