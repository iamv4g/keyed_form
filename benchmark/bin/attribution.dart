// AOT attribution of the keyed_form_gen per-keystroke write cost — **not** a
// cross-library comparison (reactive_forms / flutter_form_builder need Flutter
// and cannot `dart compile exe`).
//
//   dart compile exe bin/attribution.dart -o /tmp/attr && /tmp/attr
//
// AOT + no asserts ≈ release/profile perf. Pure Dart (keyed_form +
// keyed_form_schema only).
// ignore_for_file: avoid_print
import 'package:keyed_form/keyed_form.dart';
import 'package:keyed_form_benchmark/codegen/bench_refs.dart';
import 'package:keyed_form_benchmark/codegen/bench_schema.dart';

double bench(
  String name,
  void Function() body, {
  int warmup = 20000,
  int iters = 200000,
}) {
  for (var i = 0; i < warmup; i++) {
    body();
  }
  final sw = Stopwatch()..start();
  for (var i = 0; i < iters; i++) {
    body();
  }
  sw.stop();
  final us = sw.elapsedMicroseconds / iters;
  print('  ${name.padRight(44)} ${us.toStringAsFixed(3)} us');
  return us;
}

void main() {
  final ref = bench100Refs[50];
  final seed = benchSeed();
  var n = 0;

  print('keyed_form_gen — one form.field(ref).set(v), 100 flat fields (AOT)\n');

  final form = KeyedFormController<Bench100Schema>(
    initialValue: benchSeed(),
    mode: KeyedFormMode.onChange,
    resolver: (d, _) => Bench100Schema.validateData(d),
  );
  final whole = bench(
    'form.field(ref).set(v)   [full write path]',
    () => form.field(ref).set('v${n++ & 1023}'),
  );

  print('\n  attribution:');
  bench('form.field(ref)          [FieldHandle alloc]', () => form.field(ref));

  var cur = seed;
  bench(
    'ref.set(obj, v)          [copyWith, 100 fields]',
    () => cur = ref.set(cur, 'x${n++ & 1023}'),
  );

  final changed = ref.set(seed, 'different');
  bench('changed == seed          [== guard, differs]', () {
    changed == seed;
  });

  final toMap = bench('obj.toMap()              [N-entry map alloc]',
      () => seed.toMap());
  final m = seed.toMap();
  final vmap = bench('schema.validateMap(map)  [field walk]',
      () => benchSchema.validateMap(m));
  final vdata = bench('Bench100Schema.validateData(obj)',
      () => Bench100Schema.validateData(seed));

  print(
    '\n  validateData ${vdata.toStringAsFixed(2)} = toMap ${toMap.toStringAsFixed(2)}'
    ' + validateMap ${vmap.toStringAsFixed(2)}   (${(100 * vdata / whole).round()}% of the full write)',
  );
}
