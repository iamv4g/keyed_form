// AOT microbench for the `keyed_form_flutter` listener fan-out (#3): every
// `KeyedFormField` adds a listener to the whole controller, so one write fires
// N callbacks, each re-reading its field + visible error and diffing.
//
//   dart compile exe bin/fanout.dart -o /tmp/fanout && /tmp/fanout
//
// Pure Dart (keyed_form only) — measures exactly what a Flutter profile run
// can't isolate. The resolver is a no-op here so the number is *only* the
// fan-out; the real widget also pays validation (see attribution.dart).
// ignore_for_file: avoid_print
import 'package:keyed_form/keyed_form.dart';
import 'package:keyed_form_benchmark/kf_form.dart';
import 'package:keyed_form_benchmark/scenario.dart';

double _time(void Function() body, {int warmup = 3000, int iters = 20000}) {
  for (var i = 0; i < warmup; i++) {
    body();
  }
  final sw = Stopwatch()..start();
  for (var i = 0; i < iters; i++) {
    body();
  }
  return sw.elapsedMicroseconds / iters;
}

void main() {
  print('listener fan-out per keystroke — no-op resolver (AOT)\n');
  print('  ${'fields'.padLeft(6)}  ${'µs/write'.padLeft(9)}  '
      '${'ns/listener'.padLeft(11)}  ${'vs bare notify'.padLeft(14)}');

  for (final n in const [50, 100, 250, 500, 1000, 2000]) {
    final scenario = Scenario(fieldCount: n);

    // A: the real KeyedFormField._onFormChange work, one listener per field.
    final formA = KeyedFormController<KfDraft>(
      initialValue: kfSeed(scenario),
      mode: KeyedFormMode.onChange,
      resolver: (_, _) => const FieldErrors.empty(),
    );
    final refs = [for (var i = 0; i < n; i++) kfFieldRef(i)];
    var touched = 0;
    for (final ref in refs) {
      Object? lastValue;
      String? lastError;
      formA.addListener(() {
        final value = ref.getOrNull(formA.value);
        final error = formA.visibleError(ref.key);
        if (value != lastValue || error != lastError) {
          lastValue = value;
          lastError = error;
          touched++;
        }
      });
    }

    // B: same N listeners, but each does nothing — bare ChangeNotifier cost.
    final formB = KeyedFormController<KfDraft>(
      initialValue: kfSeed(scenario),
      mode: KeyedFormMode.onChange,
      resolver: (_, _) => const FieldErrors.empty(),
    );
    for (var i = 0; i < n; i++) {
      formB.addListener(() {});
    }

    final mid = kfFieldRef(n ~/ 2);
    var k = 0;
    final a = _time(() => formA.field(mid).set('x${k++ & 1023}'));
    final b = _time(() => formB.field(mid).set('x${k++ & 1023}'));

    print('  ${n.toString().padLeft(6)}  ${a.toStringAsFixed(2).padLeft(9)}  '
        '${(a / n * 1000).toStringAsFixed(1).padLeft(11)}  '
        '${'${(a / b).toStringAsFixed(1)}x'.padLeft(14)}');

    formA.dispose();
    formB.dispose();
    if (touched < 0) print(touched); // keep the closure work observable
  }
}
