import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

final _topKey = FieldKey.name('top');
final _bottomKey = FieldKey.name('bottom');

Widget _form(
  KeyedFieldRegistry registry, {
  bool includeBottom = true,
  FocusNode? bottomFocus,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            KeyedFieldAnchor(
              registry: registry,
              fieldKey: _topKey,
              child: const SizedBox(height: 40, child: Text('top field')),
            ),
            const SizedBox(height: 2000),
            if (includeBottom)
              KeyedFieldAnchor(
                registry: registry,
                fieldKey: _bottomKey,
                focusNode: bottomFocus,
                child: SizedBox(
                  height: 40,
                  child: TextField(focusNode: bottomFocus),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('reveal scrolls an off-screen anchor into view and focuses', (
    tester,
  ) async {
    final registry = KeyedFieldRegistry();
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(_form(registry, bottomFocus: focus));

    expect(find.byType(TextField).hitTestable(), findsNothing);

    expect(registry.reveal(_bottomKey), isTrue);
    await tester.pumpAndSettle();

    expect(find.byType(TextField).hitTestable(), findsOneWidget);
    final rect = tester.getRect(find.byType(TextField));
    expect(rect.top, greaterThanOrEqualTo(0));
    expect(rect.bottom, lessThanOrEqualTo(600));
    expect(focus.hasFocus, isTrue);
  });

  testWidgets('revealFirst takes the first key with a live anchor', (
    tester,
  ) async {
    final registry = KeyedFieldRegistry();
    await tester.pumpWidget(_form(registry));

    final unknown = FieldKey.name('gone');
    expect(registry.revealFirst([unknown, _bottomKey]), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('top field').hitTestable(), findsNothing);
  });

  testWidgets('unknown or disposed anchors report false', (tester) async {
    final registry = KeyedFieldRegistry();
    await tester.pumpWidget(_form(registry));
    expect(registry.reveal(FieldKey.name('gone')), isFalse);

    await tester.pumpWidget(_form(registry, includeBottom: false));
    expect(registry.reveal(_bottomKey), isFalse);
    expect(registry.revealFirst([_bottomKey]), isFalse);
  });
}
