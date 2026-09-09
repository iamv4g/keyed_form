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

Three `keyed_form` wirings are run:

* **whole** — hand-written resolver re-checks everything on every write;
* **scoped** — hand-written resolver + `scopeOf`, so a flat-field write only
  re-validates that field (the apples-to-apples match for reactive_forms'
  per-control model);
* **keyed_form_gen** — a real generated `Bench100Schema` whose `validateData`
  round-trips through `toMap()` + the `ks.*` schema (calibration test only,
  fixed at 100 flat fields; a generated model cannot scope its validation).

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

`keyed_form` here is the list-backed stand-in with a **hand-written resolver**.

| op | lib | 10f | 50f | 100f | 250f |
|---|---|--:|--:|--:|--:|
| **build** | keyed_form | ~1 | ~1 | ~1 | 3 |
| | reactive_forms | 200 | 390 | 750 | 1750 |
| **setField** (1 write + revalidate) | keyed_form (whole) | 11 | 5 | 8 | 21 |
| | keyed_form (scoped) | 10 | 5 | 8 | 22 |
| | reactive_forms | 22 | 18 | 23 | 35 |
| **isDirty** | keyed_form (`==` whole draft) | 0.02 | 0.03 | 0.02 | 0.02 |
| | reactive_forms (flag) | ~0 | ~0 | ~0 | ~0 |
| **isValid** | either | ~0 | ~0 | ~0 | ~0 |

Row churn (`addRow + removeRow`, 20f+20r): keyed_form ~17–23 µs,
reactive_forms ~65 µs.

Takeaways: `keyed_form` builds a form ~100–500× cheaper (no per-field
control/stream objects). With a hand-written resolver it also writes ~2–3×
cheaper. The "immutability tax" on `isDirty` — a full-draft `==` every check —
is **not** measurable at these sizes. `scoped` vs `whole` barely differ here
because the ruleset is tiny.

### Codegen calibration — `test/codegen_calibration_test.dart` (100 flat fields, median µs)

The list-backed stand-in above uses a hand-written resolver. A real
`keyed_form_gen` model validates by round-tripping the whole object through
`toMap()` and the `ks.*` schema on **every** write — there is no scoped
variant, a generated model cannot re-validate one subtree.

Controlled before/after (same machine, back-to-back, only the two perf files
reverted for "before"; reactive_forms is the drift check):

| lib | build | setField median | setField min | before: median / min |
|---|--:|--:|--:|--:|
| keyed_form — list-backed + hand resolver (whole) | 4 | **9** | 9 | 9 / 9 |
| keyed_form — list-backed + hand resolver (scoped) | 1 | 11 | 11 | 11 / 11 |
| **keyed_form_gen — real `Bench100Schema` + `validateData`** | 3 | **18** | **14** | 28–30 / 27 |
| reactive_forms | 800 | 23 | 22 | 23–25 / 23 |

`keyed_form`'s per-write cost still depends on the validation strategy, but the
gap has closed:

* hand-written resolver → ~9 µs, ~2.5× faster than reactive_forms;
* idiomatic `keyed_form_gen` `validateData` → **~18 µs median / ~14 µs min**
  (was ~28 / ~27), now a touch *faster* than reactive_forms.

The `perf/fieldkey-hash-and-codegen-validate` branch cut the schema engine's
per-validation work ~5× (`KSObject.validateMap` 15 µs → 3 µs at 100 fields, JIT)
by caching the per-field `FieldKey`s in the validator and caching
`FieldKey.hashCode`.

#### AOT attribution of the keyed_form write path

`bin/attribution.dart` (`dart compile exe`, no asserts ≈ release) breaks down
one `form.field(ref).set(v)` at 100 flat fields — total **~8.6 µs** (JIT
`flutter test` inflates this ~2×):

| bucket | µs | share |
|---|--:|--:|
| `obj.toMap()` — N-entry map allocation | **4.0** | ~46 % |
| `schema.validateMap(map)` — the field walk | **4.4** | ~52 % |
| `ref.set` → `copyWith` (construct the 100-field object) | 0.25 | 3 % |
| `next == _value` guard (100-field compare) | 0.06 | <1 % |
| `form.field(ref)` — `FieldHandle` allocation | 0.005 | ~0 % |

So in AOT the whole cost is `validateData`; the immutable copy and the
`==` guard are free. `toMap()` is the single biggest slice — the next target
(`perf/codegen-validate-nocopy`) is a zero-copy accessor so `validateData`
reads the object directly. A generated model also still cannot **scope** its
validation: `scopeOf` needs generator support, or wire a hand-written
`resolver` and keep the generated class as the data class.

`build` stays cheap either way (generated `create()` ~3 µs vs reactive_forms
~800 µs).

> The µs tables here are **JIT `flutter test`** except where marked AOT. A
> uniform AOT comparison of all three libraries needs a Flutter **profile-mode**
> run on a device/emulator (`reactive_forms` imports `package:flutter/
> foundation`, `flutter_form_builder` is widget-only — neither can
> `dart compile exe`). See `integration_test/`.

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
lib/kf_form.dart             the list-backed keyed_form model/refs/resolver (any N)
lib/codegen/bench_schema.dart  100-field @keyedSchema; .kfg.dart is generated & committed
lib/codegen/bench_refs.dart    the 100 generated refs, indexable  (+ tool/gen_bench_schema.py)
lib/src/measure.dart         warmup + percentile timing helper + JSON report
lib/model/*_harness.dart     ModelHarness: build / setField / addRow / isValid / isDirty
lib/widget/*_harness.dart    WidgetHarness: the form as real widgets, findable fields
bin/attribution.dart         AOT breakdown of the keyed_form write path (dart compile exe)
test/parity_test.dart          fairness gate
test/model_benchmark_test.dart          JIT, the size sweep
test/codegen_calibration_test.dart      JIT, list-backed vs a real generated model
test/rebuild_benchmark_test.dart        JIT, widget rebuilds per keystroke
integration_test/aot_benchmark_test.dart  the 3-way comparison in --profile (needs a device)
```

To change the codegen schema size: `python3 tool/gen_bench_schema.py <N>` then
`dart run build_runner build`.

## Caveats

* The parameterised `keyed_form` model is an indexed `List<String>` with a
  hand-written resolver — read O(1), write one list copy, close to a generated
  class. The **real** codegen path (class + `toMap()`-based `validateData`) is
  measured separately in the calibration test and is ~3× slower per write; see
  that section.
* `reactive_forms` `updateValue` leaves a control pristine; the harness calls
  `markAsDirty()` after, mirroring what its widgets do.
* Debug-mode `flutter test` timings carry fake-async and assertion overhead —
  treat µs columns as ratios, not latencies. Rebuild counts are exact.
* Adding this package to the workspace pulls `reactive_forms` +
  `flutter_form_builder` into the shared lockfile. Drop it from the root
  `workspace:` list if that is unwanted.
