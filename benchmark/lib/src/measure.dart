import 'dart:convert';
import 'dart:io';

/// Result of timing one operation many times.
class Sample {
  Sample(this.name, this.timingsUs);

  final String name;
  final List<double> timingsUs;

  double get median => _percentile(0.50);
  double get p90 => _percentile(0.90);
  double get min => (timingsUs.toList()..sort()).first;

  double _percentile(double q) {
    final sorted = timingsUs.toList()..sort();
    final pos = (q * (sorted.length - 1)).round();
    return sorted[pos];
  }

  Map<String, Object> toJson() => {
    'name': name,
    'iterations': timingsUs.length,
    'median_us': double.parse(median.toStringAsFixed(3)),
    'p90_us': double.parse(p90.toStringAsFixed(3)),
    'min_us': double.parse(min.toStringAsFixed(3)),
  };
}

/// Warm up, then time [body]. [setup] runs before each timed call and is
/// **not** counted (use it to reset mutable state). For sub-microsecond ops
/// raise [batch]: [body] runs [batch] times per sample and the time is
/// divided back down — but then [setup] cannot be used.
Sample measure(
  String name,
  void Function() body, {
  void Function()? setup,
  int warmup = 200,
  int iterations = 400,
  int batch = 1,
}) {
  assert(batch == 1 || setup == null, 'batch and setup are mutually exclusive');
  for (var i = 0; i < warmup; i++) {
    setup?.call();
    body();
  }
  final timings = <double>[];
  final sw = Stopwatch();
  for (var i = 0; i < iterations; i++) {
    setup?.call();
    sw
      ..reset()
      ..start();
    for (var b = 0; b < batch; b++) {
      body();
    }
    sw.stop();
    timings.add(sw.elapsedMicroseconds / batch);
  }
  return Sample(name, timings);
}

/// Collects samples and can render them as a table and a JSON file.
class Report {
  Report(this.title);
  final String title;
  final List<Sample> samples = [];

  void add(Sample s) => samples.add(s);

  String table() {
    final b = StringBuffer('\n$title\n');
    b.writeln(
      '${'operation'.padRight(46)}  ${'median µs'.padLeft(11)}'
      '  ${'p90 µs'.padLeft(11)}  ${'min µs'.padLeft(11)}',
    );
    b.writeln('-' * 84);
    for (final s in samples) {
      b.writeln(
        '${s.name.padRight(46)}  '
        '${s.median.toStringAsFixed(2).padLeft(11)}  '
        '${s.p90.toStringAsFixed(2).padLeft(11)}  '
        '${s.min.toStringAsFixed(2).padLeft(11)}',
      );
    }
    return b.toString();
  }

  void writeJson(String path) {
    final file = File(path)..parent.createSync(recursive: true);
    file.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'title': title,
        'generatedAt': DateTime.now().toUtc().toIso8601String(),
        'samples': [for (final s in samples) s.toJson()],
      }),
    );
  }
}
