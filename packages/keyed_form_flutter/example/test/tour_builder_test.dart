import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyed_form_flutter_example/tour_builder/tour_builder_screen.dart';

Widget _app() =>
    const MaterialApp(home: TourBuilderScreen(email: 'ada@example.com'));

void main() {
  testWidgets(
    'renders the seeded tour with a state inspector on wide screens',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.text('Tour builder'), findsOneWidget);
      expect(find.text('signed in as ada@example.com'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'City'), findsNWidgets(2));
      expect(find.text('State'), findsOneWidget); // the side inspector
    },
  );

  testWidgets('Save surfaces the required-name error in field and inspector', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Tour name'), 'xy');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Once in the field's errorText, once in the inspector's error list.
    expect(find.textContaining('Give the tour a name'), findsNWidgets(2));
  });

  testWidgets('Save disables itself and shows a spinner while submitting', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pump(); // flip `submitting` and let the reactive scope rebuild

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<FloatingActionButton>(find.byType(FloatingActionButton))
          .onPressed,
      isNull,
    );

    await tester.pumpAndSettle();

    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('the 14-night cross-field rule fires on Save', (tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    // Icons.add order: [maxGuests +, stop0 nights +, stop1 nights +, Add stop].
    // Seeded nights are 3 + 1; push stop0 to its cap of 14 -> 15 total.
    for (var i = 0; i < 11; i++) {
      await tester.tap(find.byIcon(Icons.add).at(1));
      await tester.pump();
    }
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Keep the itinerary under 14 nights'), findsWidgets);
  });
}
