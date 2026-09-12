import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyed_form_flutter_example/rebuild_lab/rebuild_lab_screen.dart';

Widget _app() => const MaterialApp(home: RebuildLabScreen());

void main() {
  testWidgets("typing into one field only bumps that field's own counter", (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.textContaining('Field 0 · rebuilt 1×'), findsOneWidget);
    expect(find.textContaining('Field 1 · rebuilt 1×'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'v0-edited');
    await tester.pump();

    expect(find.textContaining('Field 0 · rebuilt 2×'), findsOneWidget);
    expect(find.textContaining('Field 1 · rebuilt 1×'), findsOneWidget);
  });
}
