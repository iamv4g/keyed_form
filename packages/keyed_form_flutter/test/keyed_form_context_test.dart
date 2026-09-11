import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

class Pair {
  const Pair({this.a = '', this.b = ''});
  final String a;
  final String b;
  Pair copyWith({String? a, String? b}) => Pair(a: a ?? this.a, b: b ?? this.b);
  @override
  bool operator ==(Object other) =>
      other is Pair && other.a == a && other.b == b;
  @override
  int get hashCode => Object.hash(a, b);
}

final _a = StrictFieldRef<Pair, String>.of(
  key: FieldKey.name('a'),
  get: (p) => p.a,
  set: (p, v) => p.copyWith(a: v),
);
final _b = StrictFieldRef<Pair, String>.of(
  key: FieldKey.name('b'),
  get: (p) => p.b,
  set: (p, v) => p.copyWith(b: v),
);

FieldErrors<String> _resolve(Pair p, FieldKey? scope) =>
    FieldErrors({if (p.a.isEmpty) _a.key: 'a required'});

KeyedFormController<Pair> _make([Pair initial = const Pair(a: 'x', b: 'y')]) =>
    KeyedFormController<Pair>(
      initialValue: initial,
      mode: KeyedFormMode.onChange,
      resolver: _resolve,
    );

Widget _host(KeyedFormController<Pair> form, Widget child) => MaterialApp(
  home: Scaffold(
    body: KeyedForm<Pair>(controller: form, child: child),
  ),
);

/// A probe whose build calls [read] and counts rebuilds.
class _Probe extends StatelessWidget {
  const _Probe(this.count, this.read);
  final List<int> count; // single-element mutable counter
  final void Function(BuildContext context) read;
  @override
  Widget build(BuildContext context) {
    count[0]++;
    read(context);
    return const SizedBox();
  }
}

void main() {
  testWidgets('watchField rebuilds on its field, not on a sibling', (
    tester,
  ) async {
    final form = _make();
    String? seen;
    final n = [0];
    await tester.pumpWidget(
      _host(form, _Probe(n, (c) => seen = c.watchField(_a))),
    );
    final base = n[0];
    expect(seen, 'x');

    form.field(_b).set('yy');
    await tester.pump();
    expect(n[0], base, reason: 'b write does not rebuild an `a` watcher');

    form.field(_a).set('xx');
    await tester.pump();
    expect(n[0], base + 1);
    expect(seen, 'xx');

    form.field(_a).set('xx'); // idempotent
    await tester.pump();
    expect(n[0], base + 1);
  });

  testWidgets('selectForm rebuilds only on the derived value transition', (
    tester,
  ) async {
    final form = _make();
    final n = [0];
    bool? dirty;
    await tester.pumpWidget(
      _host(
        form,
        _Probe(
          n,
          (c) => dirty = c.selectForm((KeyedFormController<Pair> f) => f.isDirty),
        ),
      ),
    );
    final base = n[0];
    expect(dirty, isFalse);

    form.field(_a).set('x1'); // not-dirty -> dirty
    await tester.pump();
    expect(n[0], base + 1);
    expect(dirty, isTrue);

    form.field(_a).set('x2'); // still dirty
    await tester.pump();
    expect(n[0], base + 1, reason: 'isDirty unchanged');

    form.field(_a).set('x'); // back to original -> not dirty
    await tester.pump();
    expect(n[0], base + 2);
    expect(dirty, isFalse);
  });

  testWidgets('watchForm rebuilds on any field write', (tester) async {
    final form = _make();
    final n = [0];
    await tester.pumpWidget(
      _host(form, _Probe(n, (c) => c.watchForm<Pair>())),
    );
    final base = n[0];
    form.field(_b).set('b1');
    await tester.pump();
    expect(n[0], base + 1);
    form.field(_a).set('a1');
    await tester.pump();
    expect(n[0], base + 2);
  });

  testWidgets('stale slices are dropped when the selection set changes', (
    tester,
  ) async {
    final form = _make();
    final n = [0];
    var watchA = true;
    late StateSetter setOuter;

    await tester.pumpWidget(
      _host(
        form,
        StatefulBuilder(
          builder: (context, setState) {
            setOuter = setState;
            return _Probe(n, (c) {
              if (watchA) {
                c.watchField(_a);
              } else {
                c.watchField(_b);
              }
            });
          },
        ),
      ),
    );

    // flip to watching b
    setOuter(() => watchA = false);
    await tester.pump();
    await tester.pump(); // let the microtask latch settle
    final base = n[0];

    form.field(_a).set('x9'); // was watched, now stale
    await tester.pump();
    expect(n[0], base, reason: 'the `a` slice is no longer registered');

    form.field(_b).set('y9');
    await tester.pump();
    expect(n[0], base + 1);
  });

  testWidgets('controller swap re-subscribes', (tester) async {
    final form1 = _make(const Pair(a: 'one', b: '_'));
    final form2 = _make(const Pair(a: 'two', b: '_'));
    final n = [0];
    String? seen;
    var useFirst = true;
    late StateSetter setOuter;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              setOuter = setState;
              return KeyedForm<Pair>(
                controller: useFirst ? form1 : form2,
                child: _Probe(n, (c) => seen = c.watchField(_a)),
              );
            },
          ),
        ),
      ),
    );
    expect(seen, 'one');

    setOuter(() => useFirst = false);
    await tester.pump();
    expect(seen, 'two');

    final base = n[0];
    form2.field(_a).set('two!');
    await tester.pump();
    expect(n[0], base + 1);
    expect(seen, 'two!');

    form1.field(_a).set('one!'); // old controller — must not rebuild
    await tester.pump();
    expect(n[0], base + 1);
  });

  testWidgets('unmounting a watcher leaves no dangling subscription', (
    tester,
  ) async {
    final form = _make();
    final n = [0];
    await tester.pumpWidget(
      _host(form, _Probe(n, (c) => c.watchField(_a))),
    );
    await tester.pumpWidget(_host(form, const SizedBox()));
    expect(() => form.field(_a).set('gone'), returnsNormally);
  });

  testWidgets('calling watchField outside build asserts', (tester) async {
    final form = _make();
    late BuildContext ctx;
    await tester.pumpWidget(
      _host(
        form,
        Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(() => ctx.watchField(_a), throwsAssertionError);
  });
}
