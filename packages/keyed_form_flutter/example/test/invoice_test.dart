import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyed_form_flutter_example/invoice/invoice_screen.dart';

Widget _app() => const MaterialApp(home: InvoiceScreen());

void main() {
  testWidgets('the total is derived from quantity * unit price', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text(r'$150'), findsOneWidget);
  });

  testWidgets('locking line items freezes every field in the list', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.lock_open));
    await tester.pumpAndSettle();

    final description = tester.widget<TextField>(
      find.widgetWithText(TextField, 'Description'),
    );
    expect(description.enabled, isFalse);
  });
}
