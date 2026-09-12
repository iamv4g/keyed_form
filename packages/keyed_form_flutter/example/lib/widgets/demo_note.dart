import 'package:flutter/material.dart';

/// A short "what this screen demonstrates" blurb, placed at the top of every
/// demo screen so the pattern is explained right where it's shown, not only
/// in `example.md`.
class DemoNote extends StatelessWidget {
  const DemoNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    ),
  );
}
