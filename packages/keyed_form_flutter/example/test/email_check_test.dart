import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyed_form_flutter_example/main.dart';

void main() {
  Future<void> openEmailCheck(WidgetTester tester) async {
    await tester.pumpWidget(const KeyedFormExampleApp());
    await tester.tap(find.text('Email check'));
    await tester.pumpAndSettle();
  }

  testWidgets('submit starts an email check and renders the server error', (
    tester,
  ) async {
    await openEmailCheck(tester);

    await tester.enterText(find.byType(TextField), 'taken@example.com');
    await tester.pump();
    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('This email is already registered'), findsOneWidget);
    expect(find.text('Submitted'), findsNothing);
  });

  testWidgets('technical failure blocks submit and offers a retry', (
    tester,
  ) async {
    await openEmailCheck(tester);

    await tester.enterText(find.byType(TextField), 'error@example.com');
    await tester.pump();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't verify this email — try again."),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.text('Submitted'), findsNothing);
  });

  testWidgets('successful submit reports Submitted after a fresh check', (
    tester,
  ) async {
    await openEmailCheck(tester);

    await tester.enterText(find.byType(TextField), 'new@example.com');
    await tester.pump();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Submitted'), findsOneWidget);
  });
}
