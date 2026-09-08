import 'package:flutter/material.dart';

import 'login/login_screen.dart';

void main() => runApp(const KeyedFormExampleApp());

class KeyedFormExampleApp extends StatelessWidget {
  const KeyedFormExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'keyed_form_flutter',
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
      visualDensity: .compact,
      materialTapTargetSize: .shrinkWrap,
    ),
    darkTheme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.dark,
      visualDensity: .compact,
      materialTapTargetSize: .shrinkWrap,
    ),
    home: const LoginScreen(),
  );
}
