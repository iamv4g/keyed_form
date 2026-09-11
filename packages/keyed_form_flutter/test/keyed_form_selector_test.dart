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

void main() {
  testWidgets('KeyedFormSelector rebuilds on its slice, not on a sibling', (
    tester,
  ) async {
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(a: 'x', b: 'y'),
      mode: KeyedFormMode.onChange,
      resolver: _resolve,
    );
    var selectorBuilds = 0;
    var wholeBuilds = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyedForm<Pair>(
            controller: form,
            child: Column(
              children: [
                KeyedFormSelector<Pair, String?>(
                  selector: (f) => f.field(_a).value,
                  builder: (context, value, _) {
                    selectorBuilds++;
                    return Text('a=$value');
                  },
                ),
                KeyedFormBuilder<Pair>(
                  builder: (context, f) {
                    wholeBuilds++;
                    return Text('dirty=${f.isDirty}');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final s0 = selectorBuilds;
    final w0 = wholeBuilds;

    // write to b — selector on `a` must not rebuild; KeyedFormBuilder does
    form.field(_b).set('yy');
    await tester.pump();
    expect(selectorBuilds, s0, reason: 'selector slice (a) unchanged');
    expect(wholeBuilds, greaterThan(w0), reason: 'whole-form builder rebuilds');

    // write to a — selector rebuilds
    form.field(_a).set('xx');
    await tester.pump();
    expect(selectorBuilds, s0 + 1);
    expect(find.text('a=xx'), findsOneWidget);

    // idempotent write — no rebuild
    final s1 = selectorBuilds;
    form.field(_a).set('xx');
    await tester.pump();
    expect(selectorBuilds, s1);
  });

  testWidgets('child is passed through un-rebuilt', (tester) async {
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(a: 'x', b: 'y'),
      mode: KeyedFormMode.onChange,
      resolver: _resolve,
    );
    var childBuilds = 0;
    final child = Builder(
      builder: (_) {
        childBuilds++;
        return const SizedBox();
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: KeyedForm<Pair>(
          controller: form,
          child: KeyedFormSelector<Pair, String?>(
            selector: (f) => f.field(_a).value,
            child: child,
            builder: (context, value, c) => Column(children: [Text('$value'), c!]),
          ),
        ),
      ),
    );

    final c0 = childBuilds;
    form.field(_a).set('xx');
    await tester.pump();
    expect(childBuilds, c0, reason: 'child not rebuilt when the slice changes');
  });
}
