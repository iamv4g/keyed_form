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

  testWidgets('moving a row up swaps its position', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_upward).at(1)); // move Charger up
    await tester.pumpAndSettle();

    expect(_itemLabels(tester), ['Charger', 'Passport', 'Rain jacket']);
  });

  testWidgets('insert after adds a fresh row right below', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.playlist_add).at(0));
    await tester.pumpAndSettle();

    expect(_itemLabels(tester), ['Passport', '', 'Charger', 'Rain jacket']);
  });
}
