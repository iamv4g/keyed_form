import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyed_form_flutter_example/itinerary/itinerary_screen.dart';

Widget _app() => const MaterialApp(home: ItineraryScreen());

void main() {
  testWidgets('the seeded day shows a sightseeing activity', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Place'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Restaurant'), findsNothing);
  });

  testWidgets('switching kind swaps the narrowed field, not an error', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Meal'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Place'), findsNothing);
    expect(find.widgetWithText(TextField, 'Restaurant'), findsOneWidget);
  });

  testWidgets('Add day appends a new day card', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add day'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Day label'), findsNWidgets(2));
  });

  testWidgets(
    'nested place rule validates and ignores a result after variant change',
    (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Place'), 'closed');
      await tester.pump();
      await tester.tap(find.text('Meal'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Place'), findsNothing);
      expect(find.widgetWithText(TextField, 'Restaurant'), findsOneWidget);
      expect(find.text('This place is unavailable'), findsNothing);
    },
  );

  testWidgets('new nested activities use the configured availability rule', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add activity'));
    await tester.pumpAndSettle();
    final places = find.widgetWithText(TextField, 'Place');
    await tester.enterText(places.last, 'closed');
    await tester.pump();
    await tester.tap(find.text('Add activity'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.text('This place is unavailable'), findsOneWidget);
  });
}
