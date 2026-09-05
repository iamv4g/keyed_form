import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

class _Host extends StatefulWidget {
  const _Host({required this.initial, required this.log});

  final String initial;
  final List<String> log;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late String value = widget.initial;

  void push(String next) => setState(() => value = next);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: KeyedTextBinding(
          value: value,
          onChanged: (v) {
            widget.log.add(v);
            setState(() => value = v);
          },
          builder: (context, controller) => TextField(controller: controller),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('user edits are reported and the echo keeps the caret', (
    tester,
  ) async {
    final log = <String>[];
    await tester.pumpWidget(_Host(initial: 'abc', log: log));

    await tester.enterText(find.byType(TextField), 'abcd');
    await tester.pump();

    expect(log, ['abcd']);
    final controller =
        tester.widget<TextField>(find.byType(TextField)).controller!;
    expect(controller.text, 'abcd');
    expect(controller.selection.extentOffset, 4);
  });

  testWidgets('external update overwrites text and clamps the selection', (
    tester,
  ) async {
    final log = <String>[];
    await tester.pumpWidget(_Host(initial: 'hello world', log: log));

    final controller =
        tester.widget<TextField>(find.byType(TextField)).controller!;
    controller.selection = const TextSelection.collapsed(offset: 11);

    tester.state<_HostState>(find.byType(_Host)).push('hi');
    await tester.pump();

    expect(controller.text, 'hi');
    expect(controller.selection.extentOffset, 2);
    expect(log, isEmpty);
  });

  testWidgets('selection-only changes do not fire onChanged', (tester) async {
    final log = <String>[];
    await tester.pumpWidget(_Host(initial: 'abc', log: log));

    final controller =
        tester.widget<TextField>(find.byType(TextField)).controller!;
    controller.selection = const TextSelection.collapsed(offset: 1);
    await tester.pump();

    expect(log, isEmpty);
  });
}
