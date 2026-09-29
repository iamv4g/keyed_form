import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyed_form_flutter_example/main.dart';

void main() {
  Future<void> openEmailCheck(WidgetTester tester) async {
    await tester.pumpWidget(const KeyedFormExampleApp());
    await tester.tap(find.text('Email check'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows a spinner during the async check, then the server error', (
    tester,
  ) async {
    await openEmailCheck(tester);

    await tester.enterText(find.byType(TextField), 'taken@example.com');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('This email is already registered'), findsOneWidget);
  });

  testWidgets('a check that throws marks the field failed, not invalid', (
    tester,
  ) async {
    await openEmailCheck(tester);

    await tester.enterText(find.byType(TextField), 'error@example.com');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't verify this email — try again."),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });
}
