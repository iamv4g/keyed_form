import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool autoDetectBlur = true,
}) => KeyedFormField<Pair, String>(
  field: field,
  autoDetectBlur: autoDetectBlur,
  builder: (context, f) {
    builds[label] = (builds[label] ?? 0) + 1;
    return TextField(
      key: Key(label),
      focusNode: focusNode,
      onChanged: f.onChanged,
      decoration: InputDecoration(errorText: f.errorText),
    );
  },
);

Widget _host(KeyedFormController<Pair> form, Map<String, int> builds) =>
    MaterialApp(
      home: Scaffold(
        body: KeyedForm<Pair>(
          controller: form,
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

  testWidgets('configured async validation rebuilds only its field', (
    tester,
  ) async {
    final gate = Completer<String?>();
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(a: 'x', b: 'y'),
      mode: KeyedFormMode.onChange,
      resolver: _resolve,
      asyncValidators: [.field(field: _a, validate: (_, _) => gate.future)],
    );
    final builds = <String, int>{};
    await tester.pumpWidget(_host(form, builds));

    final aBuilds = builds['a']!;
    final bBuilds = builds['b']!;
    final pending = form.field(_a).validate();
    await tester.pump();
    expect(builds['a'], greaterThan(aBuilds));
    expect(builds['b'], bBuilds);

    final aBuildsWhileValidating = builds['a']!;
    gate.complete(null);
    await pending;
    await tester.pump();
    expect(builds['a'], greaterThan(aBuildsWhileValidating));
    expect(builds['b'], bBuilds);
  });

  testWidgets('focus leaving a field marks it touched and validates once', (
    tester,
  ) async {
    var validations = 0;
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(a: 'x', b: 'y'),
      mode: KeyedFormMode.onBlur,
      resolver: (value, scope) {
        validations++;
        return _resolve(value, scope);
      },
    );
    final node = FocusNode();
    addTearDown(node.dispose);
    final builds = <String, int>{};
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyedForm<Pair>(
            controller: form,
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

    form.field(_a).set('');
    await tester.pump();
    expect(find.text('a required'), findsNothing, reason: 'not blurred yet');

    node.requestFocus();
    await tester.pump();
    node.unfocus();
    await tester.pump();

    expect(form.touched, contains(_a.key));
    expect(form.touched, isNot(contains(_b.key)));
    expect(find.text('a required'), findsOneWidget);
    expect(validations, 1);
  });

  testWidgets('pointer focus change between fields blurs the field it leaves', (
    tester,
  ) async {
    var validations = 0;
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(),
      mode: KeyedFormMode.onBlur,
      resolver: (value, scope) {
        validations++;
        return _resolve(value, scope);
      },
    );
    final builds = <String, int>{};
    await tester.pumpWidget(_host(form, builds));

    await tester.tap(find.byKey(const Key('a')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('b')));
    await tester.pump();

    expect(form.touched, contains(_a.key));
    expect(form.touched, isNot(contains(_b.key)));
    expect(validations, 1);
  });

  testWidgets('Tab traverses between inputs and blurs the input it leaves', (
    tester,
  ) async {
    var validations = 0;
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(),
      mode: KeyedFormMode.onBlur,
      resolver: (value, scope) {
        validations++;
        return _resolve(value, scope);
      },
    );
    final builds = <String, int>{};
    final aNode = FocusNode(debugLabel: 'a input');
    final bNode = FocusNode(debugLabel: 'b input');
    addTearDown(aNode.dispose);
    addTearDown(bNode.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyedForm<Pair>(
            controller: form,
            child: Column(
              children: [
                _field('a', _a, builds, focusNode: aNode),
                _field('b', _b, builds, focusNode: bNode),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('a')));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    expect(FocusManager.instance.primaryFocus, same(bNode));
    expect(form.touched, contains(_a.key));
    expect(form.touched, isNot(contains(_b.key)));
    expect(validations, 1);
  });

  testWidgets('focus within an anchor:false compound field is not blur', (
    tester,
  ) async {
    var validations = 0;
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(),
      mode: KeyedFormMode.onBlur,
      resolver: (value, scope) {
        validations++;
        return _resolve(value, scope);
      },
    );
    final textNode = FocusNode();
    final actionNode = FocusNode();
    final outsideNode = FocusNode();
    addTearDown(textNode.dispose);
    addTearDown(actionNode.dispose);
    addTearDown(outsideNode.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyedForm<Pair>(
            controller: form,
            child: Column(
              children: [
                KeyedFormField<Pair, String>(
                  field: _a,
                  anchor: false,
                  builder: (context, f) => Column(
                    children: [
                      TextField(focusNode: textNode, onChanged: f.onChanged),
                      ElevatedButton(
                        focusNode: actionNode,
                        onPressed: () {},
                        child: const Text('inside'),
                      ),
                    ],
                  ),
                ),
                TextField(focusNode: outsideNode),
              ],
            ),
          ),
        ),
      ),
    );

    textNode.requestFocus();
    await tester.pump();
    actionNode.requestFocus();
    await tester.pump();
    expect(form.touched, isNot(contains(_a.key)));
    expect(validations, 0);

    outsideNode.requestFocus();
    await tester.pump();
    expect(form.touched, contains(_a.key));
    expect(validations, 1);
  });

  testWidgets('FocusScope nextFocus and previousFocus blur the old input', (
    tester,
  ) async {
    var validations = 0;
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(),
      mode: KeyedFormMode.onBlur,
      resolver: (value, scope) {
        validations++;
        return _resolve(value, scope);
      },
    );
    final aNode = FocusNode();
    final bNode = FocusNode();
    addTearDown(aNode.dispose);
    addTearDown(bNode.dispose);
    late BuildContext scopeContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyedForm<Pair>(
            controller: form,
            child: Builder(
              builder: (context) {
                scopeContext = context;
                return Column(
                  children: [
                    _field('a', _a, {}, focusNode: aNode),
                    _field('b', _b, {}, focusNode: bNode),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    aNode.requestFocus();
    await tester.pump();
    FocusScope.of(scopeContext).nextFocus();
    await tester.pump();
    expect(FocusManager.instance.primaryFocus, same(bNode));
    FocusScope.of(scopeContext).previousFocus();
    await tester.pump();

    expect(FocusManager.instance.primaryFocus, same(aNode));
    expect(form.touched, containsAll([_a.key, _b.key]));
    expect(validations, 2);
  });

  testWidgets('focus boundary cannot receive focus or stop traversal', (
    tester,
  ) async {
    var validations = 0;
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(),
      mode: KeyedFormMode.onBlur,
      resolver: (value, scope) {
        validations++;
        return _resolve(value, scope);
      },
    );
    final inputNode = FocusNode();
    final outsideNode = FocusNode();
    addTearDown(inputNode.dispose);
    addTearDown(outsideNode.dispose);
    FocusNode? boundaryNode;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyedForm<Pair>(
            controller: form,
            child: Column(
              children: [
                KeyedFormField<Pair, String>(
                  field: _a,
                  builder: (context, field) => Builder(
                    builder: (context) {
                      boundaryNode = Focus.of(context);
                      return TextField(
                        focusNode: inputNode,
                        onChanged: field.onChanged,
                      );
                    },
                  ),
                ),
                TextField(focusNode: outsideNode),
              ],
            ),
          ),
        ),
      ),
    );

    boundaryNode!.requestFocus();
    await tester.pump();
    expect(FocusManager.instance.primaryFocus, isNot(same(boundaryNode)));
    expect(validations, 0);

    inputNode.requestFocus();
    await tester.pump();
    boundaryNode!.requestFocus();
    await tester.pump();
    expect(FocusManager.instance.primaryFocus, same(inputNode));
    expect(validations, 0);

    outsideNode.requestFocus();
    await tester.pump();
    expect(form.touched, contains(_a.key));
    expect(validations, 1);
  });

  testWidgets('automatic focus loss into a root overlay is a blur', (
    tester,
  ) async {
    var validations = 0;
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(),
      mode: KeyedFormMode.onBlur,
      resolver: (value, scope) {
        validations++;
        return _resolve(value, scope);
      },
    );
    final triggerNode = FocusNode();
    final optionNode = FocusNode();
    addTearDown(triggerNode.dispose);
    addTearDown(optionNode.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyedForm<Pair>(
            controller: form,
            child: KeyedFormField<Pair, String>(
              field: _a,
              builder: (context, f) => TextField(focusNode: triggerNode),
            ),
          ),
        ),
      ),
    );
    final overlay = tester.state<OverlayState>(find.byType(Overlay).first);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 100,
        left: 20,
        child: TextButton(
          focusNode: optionNode,
          onPressed: () {},
          child: const Text('overlay option'),
        ),
      ),
    );
    overlay.insert(entry);
    addTearDown(() {
      entry.remove();
      entry.dispose();
    });
    await tester.pump();

    triggerNode.requestFocus();
    await tester.pump();
    optionNode.requestFocus();
    await tester.pump();

    expect(form.touched, contains(_a.key));
    expect(validations, 1);
  });

  testWidgets('toggling automatic blur preserves focus and selection', (
    tester,
  ) async {
    var validations = 0;
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(),
      mode: KeyedFormMode.onBlur,
      resolver: (value, scope) {
        validations++;
        return _resolve(value, scope);
      },
    );
    final node = FocusNode();
    final outsideNode = FocusNode();
    addTearDown(node.dispose);
    addTearDown(outsideNode.dispose);
    late StateSetter rebuild;
    var enabled = true;
    TextEditingController? editingController;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyedForm<Pair>(
            controller: form,
            child: StatefulBuilder(
              builder: (context, setState) {
                rebuild = setState;
                return Column(
                  children: [
                    KeyedFormField.text<Pair>(
                      key: const Key('toggle-field'),
                      field: _a,
                      autoDetectBlur: enabled,
                      builder: (context, f, controller) {
                        editingController = controller;
                        return TextField(
                          focusNode: node,
                          controller: controller,
                        );
                      },
                    ),
                    TextField(focusNode: outsideNode),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
    editingController!.value = const TextEditingValue(
      text: 'abc',
      selection: TextSelection.collapsed(offset: 2),
    );
    await tester.pump();
    node.requestFocus();
    await tester.pump();

    rebuild(() => enabled = false);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus, same(node));
    expect(
      editingController!.selection,
      const TextSelection.collapsed(offset: 2),
    );

    outsideNode.requestFocus();
    await tester.pump();
    expect(form.touched, isNot(contains(_a.key)));
    expect(validations, 0);

    node.requestFocus();
    await tester.pump();
    rebuild(() => enabled = true);
    await tester.pump();
    outsideNode.requestFocus();
    await tester.pump();
    expect(form.touched, contains(_a.key));
    expect(validations, 1);
  });

  testWidgets('.text can disable automatic blur but keep manual callback', (
    tester,
  ) async {
    var validations = 0;
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(),
      mode: KeyedFormMode.onBlur,
      resolver: (value, scope) {
        validations++;
        return _resolve(value, scope);
      },
    );
    final node = FocusNode();
    final outsideNode = FocusNode();
    addTearDown(node.dispose);
    addTearDown(outsideNode.dispose);
    VoidCallback? manualBlur;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyedForm<Pair>(
            controller: form,
            child: Column(
              children: [
                KeyedFormField.text<Pair>(
                  field: _a,
                  autoDetectBlur: false,
                  builder: (context, f, controller) {
                    manualBlur = f.onBlur;
                    return TextField(focusNode: node, controller: controller);
                  },
                ),
                TextField(focusNode: outsideNode),
              ],
            ),
          ),
        ),
      ),
    );

    final capturedBlur = manualBlur!;
    form.field(_a).set('changed');
    await tester.pump();
    expect(identical(capturedBlur, manualBlur), isTrue);
    node.requestFocus();
    await tester.pump();
    outsideNode.requestFocus();
    await tester.pump();
    expect(form.touched, isNot(contains(_a.key)));
    expect(validations, 0);

    manualBlur!();
    await tester.pump();
    expect(form.touched, contains(_a.key));
    expect(validations, 1);
  });

  testWidgets('manual overlay focus stays logical until callback is invoked', (
    tester,
  ) async {
    var validations = 0;
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(),
      mode: KeyedFormMode.onBlur,
      resolver: (value, scope) {
        validations++;
        return _resolve(value, scope);
      },
    );
    final triggerNode = FocusNode();
    final optionNode = FocusNode();
    addTearDown(triggerNode.dispose);
    addTearDown(optionNode.dispose);
    VoidCallback? manualBlur;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyedForm<Pair>(
            controller: form,
            child: KeyedFormField<Pair, String>(
              field: _a,
              autoDetectBlur: false,
              builder: (context, f) {
                manualBlur = f.onBlur;
                return TextField(focusNode: triggerNode);
              },
            ),
          ),
        ),
      ),
    );
    final overlay = tester.state<OverlayState>(find.byType(Overlay).first);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 100,
        left: 20,
        child: TextButton(
          focusNode: optionNode,
          onPressed: () {},
          child: const Text('option'),
        ),
      ),
    );
    overlay.insert(entry);
    addTearDown(() {
      entry.remove();
      entry.dispose();
    });
    await tester.pump();

    triggerNode.requestFocus();
    await tester.pump();
    optionNode.requestFocus();
    await tester.pump();
    triggerNode.requestFocus();
    await tester.pump();
    expect(form.touched, isNot(contains(_a.key)));
    expect(validations, 0);

    optionNode.requestFocus();
    await tester.pump();
    manualBlur!();
    await tester.pump();
    expect(form.touched, contains(_a.key));
    expect(validations, 1);
  });

  testWidgets('a retained blur callback is inert after field disposal', (
    tester,
  ) async {
    var validations = 0;
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(),
      mode: KeyedFormMode.onBlur,
      resolver: (value, scope) {
        validations++;
        return _resolve(value, scope);
      },
    );
    VoidCallback? retainedBlur;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyedForm<Pair>(
            controller: form,
            child: KeyedFormField<Pair, String>(
              field: _a,
              builder: (context, f) {
                retainedBlur = f.onBlur;
                return const TextField();
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));

    retainedBlur!();
    expect(form.touched, isEmpty);
    expect(validations, 0);
  });

  testWidgets('the builder output is anchored under the field key', (
    tester,
  ) async {
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(a: 'x', b: 'y'),
      resolver: _resolve,
    );
    late KeyedFieldRegistry registry;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyedForm<Pair>(
            controller: form,
            child: Builder(
              builder: (context) {
                registry = KeyedForm.registryOf<Pair>(context);
                return SingleChildScrollView(
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
                );
              },
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
    late KeyedFieldRegistry registry;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyedForm<Pair>(
            controller: form,
            child: Builder(
              builder: (context) {
                registry = KeyedForm.registryOf<Pair>(context);
                return KeyedFormField<Pair, String>(
                  field: _a,
                  anchor: false,
                  builder: (context, f) => const Text('a field'),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(registry.reveal(_a.key), isFalse);
  });

  testWidgets('a retained blur callback uses the current controller', (
    tester,
  ) async {
    var firstValidations = 0;
    var secondValidations = 0;
    final first = KeyedFormController<Pair>(
      initialValue: const Pair(),
      mode: KeyedFormMode.onBlur,
      resolver: (value, scope) {
        firstValidations++;
        return _resolve(value, scope);
      },
    );
    final second = KeyedFormController<Pair>(
      initialValue: const Pair(),
      mode: KeyedFormMode.onBlur,
      resolver: (value, scope) {
        secondValidations++;
        return _resolve(value, scope);
      },
    );
    var current = first;
    late StateSetter rebuild;
    VoidCallback? retainedBlur;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return KeyedForm<Pair>(
                controller: current,
                child: KeyedFormField<Pair, String>(
                  field: _a,
                  builder: (context, f) {
                    retainedBlur = f.onBlur;
                    return const TextField();
                  },
                ),
              );
            },
          ),
        ),
      ),
    );

    final callback = retainedBlur!;
    rebuild(() => current = second);
    await tester.pump();
    expect(identical(callback, retainedBlur), isTrue);
    callback();

    expect(first.touched, isEmpty);
    expect(firstValidations, 0);
    expect(second.touched, contains(_a.key));
    expect(secondValidations, 1);
  });

  testWidgets('blur callback after a row disappears does not touch it', (
    tester,
  ) async {
    final rows = StrictFieldRef<List<_Row>, List<_Row>>.of(
      key: FieldKey.name('rows'),
      get: (value) => value,
      set: (_, next) => next,
    );
    final label = rows
        .at('row', (row) => row.clientId == 'row')
        .then(
          StrictFieldRef<_Row, String>.of(
            key: FieldKey.name('label'),
            get: (row) => row.label,
            set: (row, value) => _Row(row.clientId, value),
          ),
        );
    var validations = 0;
    final form = KeyedFormController<List<_Row>>(
      initialValue: [const _Row('row', '')],
      mode: KeyedFormMode.onBlur,
      resolver: (_, _) {
        validations++;
        return const FieldErrors.empty();
      },
    );
    final node = FocusNode();
    addTearDown(node.dispose);
    VoidCallback? retainedBlur;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyedForm<List<_Row>>(
            controller: form,
            child: KeyedFormField<List<_Row>, String>(
              field: label,
              builder: (context, f) {
                retainedBlur = f.onBlur;
                return TextField(focusNode: node, onChanged: f.onChanged);
              },
            ),
          ),
        ),
      ),
    );

    node.requestFocus();
    await tester.pump();
    form.field(rows).set(const []);
    await tester.pump();
    retainedBlur!();

    expect(find.byType(TextField), findsNothing);
    expect(form.touched, isEmpty);
    expect(validations, 0);
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
        home: KeyedForm<Pair>(
          controller: form,
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
