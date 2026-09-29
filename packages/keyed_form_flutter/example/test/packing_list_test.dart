import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyed_form_flutter_example/packing_list/packing_list_screen.dart';

Widget _app() => const MaterialApp(home: PackingListScreen());

List<String> _itemLabels(WidgetTester tester) => tester
    .widgetList<TextField>(find.widgetWithText(TextField, 'Item'))
    .map((w) => w.controller!.text)
    .toList();

void main() {
  testWidgets('seeded items render and Add item appends a new row', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(_itemLabels(tester), ['Passport', 'Charger', 'Rain jacket']);

    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Item'), findsNWidgets(4));
  });

  for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
    testWidgets('dragging a row by its handle reorders it (${kind.name})', (
      tester,
    ) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Item').at(2),
        'Umbrella',
      );
      await tester.pump();

      final from = tester.getCenter(find.byIcon(Icons.drag_indicator).at(2));
      final to = tester.getCenter(find.widgetWithText(TextField, 'Item').at(0));
      final gesture = await tester.startGesture(from, kind: kind);
      for (var i = 1; i <= 12; i++) {
        await gesture.moveTo(
          Offset(from.dx, from.dy + (to.dy - from.dy) * i / 12),
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      // The dragged row floats in the overlay while its slot stays put.
      expect(find.widgetWithText(ListTile, 'Umbrella'), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();

      expect(_itemLabels(tester), ['Umbrella', 'Passport', 'Charger']);
    });
  }

  testWidgets('removing a row drops it', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close).at(1));
    await tester.pumpAndSettle();

    expect(_itemLabels(tester), ['Passport', 'Rain jacket']);
  });
}
