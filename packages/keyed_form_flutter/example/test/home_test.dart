import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyed_form_flutter_example/main.dart';

void main() {
  testWidgets('every demo listed on Home actually opens', (tester) async {
    // All six entries must be on screen at once — no scrolling in this test.
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const KeyedFormExampleApp());
    await tester.pumpAndSettle();

    for (final title in [
      'Sign in',
      'Invoice',
      'Packing list',
      'Itinerary',
      'Rebuild lab',
      'Tour builder',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();

      expect(find.text(title), findsWidgets); // still there (app bar title)

      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });
}
