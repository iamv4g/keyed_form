import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyed_form_flutter_showcase/main.dart';

void main() {
  testWidgets('bad credentials stay on the login screen with errors', (
    tester,
  ) async {
    await tester.pumpWidget(const KeyedFormExampleApp());

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('That does not look like an email'), findsNothing);
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(find.text('Tour builder'), findsNothing);
  });

  testWidgets('a valid sign-in pushes the tour builder', (tester) async {
    await tester.pumpWidget(const KeyedFormExampleApp());

    await tester.enterText(find.byType(TextField).at(0), 'ada@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'lovelace1843');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Tour builder'), findsOneWidget);
    expect(find.text('signed in as ada@example.com'), findsOneWidget);
  });
}
