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
}
