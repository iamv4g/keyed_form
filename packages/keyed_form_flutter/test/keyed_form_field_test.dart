import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

// --- fixture -------------------------------------------------------------

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

FieldErrors<String> _resolve(Pair p, FieldKey? scope) => FieldErrors({
  if (p.a.isEmpty) _a.key: 'a required',
  if (p.b.isEmpty) _b.key: 'b required',
});

Widget _field(
  String label,
  FieldRef<Pair, String> field,
  Map<String, int> builds, {
  FocusNode? focusNode,
}) => KeyedFormField<Pair, String>(
  field: field,
  builder: (context, f) {
    builds[label] = (builds[label] ?? 0) + 1;
    return Focus(
      focusNode: focusNode,
      onFocusChange: (has) {
        if (!has) f.onBlur();
      },
      child: TextField(
        key: Key(label),
        onChanged: f.onChanged,
        decoration: InputDecoration(errorText: f.errorText),
      ),
    );
  },
);

Widget _host(KeyedFormController<Pair> form, Map<String, int> builds) =>
    MaterialApp(
      home: Scaffold(
        body: KeyedFormScope<Pair>(
          controller: form,
          registry: KeyedFieldRegistry(),
          child: Column(
            children: [_field('a', _a, builds), _field('b', _b, builds)],
          ),
        ),
      ),
    );

void main() {
  testWidgets('a write to one field does not rebuild the sibling', (
    tester,
  ) async {
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(a: 'x', b: 'y'),
      mode: KeyedFormMode.onChange,
      resolver: _resolve,
    );
    final builds = <String, int>{};
    await tester.pumpWidget(_host(form, builds));

    final aBuilds = builds['a']!;
    final bBuilds = builds['b']!;

    await tester.enterText(find.byKey(const Key('a')), 'xx');
    await tester.pump();

    expect(builds['a'], greaterThan(aBuilds), reason: 'edited field rebuilds');
    expect(builds['b'], bBuilds, reason: 'sibling field does not');
  });

  testWidgets('blur wires KeyedFieldState.onBlur → controller.touch', (
    tester,
  ) async {
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(a: 'x', b: 'y'),
      mode: KeyedFormMode.onTouched,
      resolver: _resolve,
    );
    final node = FocusNode();
    addTearDown(node.dispose);
    final builds = <String, int>{};
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyedFormScope<Pair>(
            controller: form,
            registry: KeyedFieldRegistry(),
            child: Column(
              children: [
                _field('a', _a, builds, focusNode: node),
                _field('b', _b, builds),
              ],
            ),
          ),
        ),
      ),
    );

    form.setField(_a, '');
    await tester.pump();
    expect(find.text('a required'), findsNothing, reason: 'not touched yet');

    node.requestFocus();
    await tester.pump();
    node.unfocus();
    await tester.pump();

    expect(find.text('a required'), findsOneWidget);
  });

  testWidgets('the builder output is anchored under the field key', (
    tester,
  ) async {
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(a: 'x', b: 'y'),
      resolver: _resolve,
    );
    final registry = KeyedFieldRegistry();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyedFormScope<Pair>(
            controller: form,
            registry: registry,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 1200),
                  KeyedFormField<Pair, String>(
                    field: _a,
                    builder: (context, f) =>
                        const SizedBox(height: 40, child: Text('a field')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('a field').hitTestable(), findsNothing);
    expect(registry.reveal(_a.key), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('a field').hitTestable(), findsOneWidget);
  });

  testWidgets('anchor: false opts the field out of the registry', (
    tester,
  ) async {
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(a: 'x', b: 'y'),
      resolver: _resolve,
    );
    final registry = KeyedFieldRegistry();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyedFormScope<Pair>(
            controller: form,
            registry: registry,
            child: KeyedFormField<Pair, String>(
              field: _a,
              anchor: false,
              builder: (context, f) => const Text('a field'),
            ),
          ),
        ),
      ),
    );

    expect(registry.reveal(_a.key), isFalse);
  });

  testWidgets('a field whose path stops resolving renders nothing', (
    tester,
  ) async {
    final rows = StrictFieldRef<Pair, List<_Row>>.of(
      key: FieldKey.name('rows'),
      get: (_) => const [],
      set: (p, _) => p,
    );
    final ghost = rows
        .at('gone', (r) => r.clientId == 'gone')
        .then(
          StrictFieldRef<_Row, String>.of(
            key: FieldKey.name('label'),
            get: (r) => r.label,
            set: (r, v) => r,
          ),
        );

    final form = KeyedFormController<Pair>(
      initialValue: const Pair(),
      resolver: (_, _) => const FieldErrors.empty(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: KeyedFormScope<Pair>(
          controller: form,
          registry: KeyedFieldRegistry(),
          child: KeyedFormField<Pair, String>(
            field: ghost,
            builder: (context, f) => const Text('should not show'),
          ),
        ),
      ),
    );

    expect(find.text('should not show'), findsNothing);
  });
}

class _Row implements KeyedRow {
  const _Row(this.clientId, this.label);
  @override
  final String clientId;
  final String label;
}
