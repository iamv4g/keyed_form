import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

class Pair {
  const Pair({this.a = '', this.b = ''});
  final String a;
  final String b;
}

final _aKey = FieldKey.name('a');
final _bKey = FieldKey.name('b');

FieldErrors<String> _resolve(Pair p, FieldKey? scope) => FieldErrors({
  if (p.a.isEmpty) _aKey: 'a required',
  if (p.b.isEmpty) _bKey: 'b required',
});

/// Wraps the field anchors in a real [KeyedForm], and hands [captureContext]
/// a context from inside it (the `Builder` below) — the same descendant
/// context a submit button would get from its own `builder`.
Widget _form({
  required KeyedFormController<Pair> form,
  required FocusNode bFocus,
  required void Function(BuildContext context) captureContext,
}) {
  return MaterialApp(
    home: Scaffold(
      body: KeyedForm<Pair>(
        controller: form,
        child: Builder(
          builder: (context) {
            final registry = KeyedForm.registryOf<Pair>(context);
            captureContext(context);
            return SingleChildScrollView(
              child: Column(
                children: [
                  KeyedFieldAnchor(
                    registry: registry,
                    fieldKey: _aKey,
                    child: const SizedBox(height: 40, child: Text('a field')),
                  ),
                  const SizedBox(height: 2000),
                  KeyedFieldAnchor(
                    registry: registry,
                    fieldKey: _bKey,
                    focusNode: bFocus,
                    child: SizedBox(
                      height: 40,
                      child: TextField(focusNode: bFocus),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('handleSubmit runs onValid and reveals nothing when valid', (
    tester,
  ) async {
    final bFocus = FocusNode();
    addTearDown(bFocus.dispose);
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(a: 'x', b: 'y'),
      mode: KeyedFormMode.onSubmit,
      resolver: _resolve,
    );

    var called = false;
    late BuildContext submitContext;
    await tester.pumpWidget(
      _form(
        form: form,
        bFocus: bFocus,
        captureContext: (context) => submitContext = context,
      ),
    );

    final ok = await form.handleSubmit(submitContext, (value) {
      called = true;
    });
    await tester.pumpAndSettle();

    expect(ok, isTrue);
    expect(called, isTrue);
    expect(bFocus.hasFocus, isFalse);
  });

  testWidgets(
    'handleSubmit skips onValid and reveals the first error by default',
    (tester) async {
      final bFocus = FocusNode();
      addTearDown(bFocus.dispose);
      final form = KeyedFormController<Pair>(
        initialValue: const Pair(a: 'x'),
        mode: KeyedFormMode.onSubmit,
        resolver: _resolve,
      );

      var called = false;
      late BuildContext submitContext;
      await tester.pumpWidget(
        _form(
          form: form,
          bFocus: bFocus,
          captureContext: (context) => submitContext = context,
        ),
      );

      final ok = await form.handleSubmit(submitContext, (value) {
        called = true;
      });
      await tester.pumpAndSettle();

      expect(ok, isFalse);
      expect(called, isFalse);
      expect(bFocus.hasFocus, isTrue);
    },
  );

  testWidgets('an explicit onInvalid overrides the default reveal', (
    tester,
  ) async {
    final bFocus = FocusNode();
    addTearDown(bFocus.dispose);
    final form = KeyedFormController<Pair>(
      initialValue: const Pair(a: 'x'),
      mode: KeyedFormMode.onSubmit,
      resolver: _resolve,
    );

    Iterable<FieldKey>? seenKeys;
    late BuildContext submitContext;
    await tester.pumpWidget(
      _form(
        form: form,
        bFocus: bFocus,
        captureContext: (context) => submitContext = context,
      ),
    );

    final ok = await form.handleSubmit(
      submitContext,
      (value) {},
      onInvalid: (keys) {
        seenKeys = keys;
      },
    );
    await tester.pumpAndSettle();

    expect(ok, isFalse);
    expect(seenKeys?.map((k) => k.toPath()), ['b']);
    expect(bFocus.hasFocus, isFalse, reason: 'default reveal did not run');
  });
}
