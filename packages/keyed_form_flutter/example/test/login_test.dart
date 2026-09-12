import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyed_form_flutter_example/main.dart';

void main() {
  Future<void> openSignIn(WidgetTester tester) async {
    await tester.pumpWidget(const KeyedFormExampleApp());
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
  }

  testWidgets('bad credentials stay on the login screen with errors', (
    tester,
  ) async {
    await openSignIn(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('That does not look like an email'), findsNothing);
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(find.text('Tour builder'), findsNothing);
  });

  testWidgets('a valid sign-in pushes the tour builder', (tester) async {
    await openSignIn(tester);

    await tester.enterText(find.byType(TextField).at(0), 'ada@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'lovelace1843');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Tour builder'), findsOneWidget);
    expect(find.text('signed in as ada@example.com'), findsOneWidget);
  });

  testWidgets('Sign in disables itself and shows a spinner while submitting', (
    tester,
  ) async {
    await openSignIn(tester);

    await tester.enterText(find.byType(TextField).at(0), 'ada@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'lovelace1843');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump(); // flip `submitting` and let the reactive scope rebuild

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    await tester.pumpAndSettle();

    expect(find.text('Tour builder'), findsOneWidget);
  });

  testWidgets(
    'email field shows a spinner during its async check, then the '
    'server error',
    (tester) async {
      await openSignIn(tester);

      await tester.enterText(
        find.byType(TextField).at(0),
        'taken@example.com',
      );
      await tester.pump(); // let the field rebuild with the typed value
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('This email is already registered'), findsOneWidget);
    },
  );
}
