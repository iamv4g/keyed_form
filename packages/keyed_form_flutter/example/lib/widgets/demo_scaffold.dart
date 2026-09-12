import 'package:flutter/material.dart';

/// The chrome every demo screen shares — an `AppBar` over a body that's
/// optionally centered and width-capped — pulled out so a screen's own
/// `build()` shows `KeyedForm` as the first thing in its `child:`, not
/// buried under `Scaffold` > `Center` > `ConstrainedBox`.
class DemoScaffold extends StatelessWidget {
  const DemoScaffold({
    required this.title,
    required this.child,
    this.actions,
    this.maxWidth,
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  /// Caps and centers the body; omit for a screen (the rebuild lab's grid)
  /// that wants the full viewport instead.
  final double? maxWidth;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), actions: actions),
    body: maxWidth == null
        ? child
        : Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth!),
              child: child,
            ),
          ),
  );
}
