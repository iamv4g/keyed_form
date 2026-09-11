import 'package:flutter/widgets.dart';
import 'package:keyed_form/keyed_form.dart';

import 'keyed_form_context.dart';
import 'keyed_form.dart';

/// Scopes a `context.selectForm` rebuild to a subtree — the `provider`
/// `Selector` / `BlocSelector` of this family. Use it when the enclosing
/// `build()` is expensive and only a small part depends on the slice, so you
/// don't want to pull `context.selectForm` up there.
///
/// [child] is a subtree that doesn't depend on the selected value — built once
/// and handed to [builder] un-rebuilt.
///
/// ```dart
/// KeyedFormSelector<TourForm, bool>(
///   selector: (form) => form.isDirty,
///   builder: (context, dirty, _) => dirty ? const UnsavedChip() : const SizedBox(),
/// )
/// ```
class KeyedFormSelector<Root, T> extends StatelessWidget {
  const KeyedFormSelector({
    required this.selector,
    required this.builder,
    this.equals,
    this.child,
    super.key,
  });

  final T Function(KeyedFormController<Root> form) selector;
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final bool Function(T a, T b)? equals;
  final Widget? child;

  @override
  Widget build(BuildContext context) => builder(
    context,
    context.selectForm<Root, T>(selector, equals: equals),
    child,
  );
}

/// Rebuilds [builder] on *every* controller change — the whole-form escape
/// hatch for a widget that genuinely needs everything (a state inspector).
/// Prefer `context.watchField` / `context.selectForm` / [KeyedFormSelector]
/// when you read only a slice.
class KeyedFormBuilder<Root> extends StatefulWidget {
  const KeyedFormBuilder({required this.builder, super.key});

  final Widget Function(BuildContext context, KeyedFormController<Root> form)
  builder;

  @override
  State<KeyedFormBuilder<Root>> createState() => _KeyedFormBuilderState<Root>();
}

class _KeyedFormBuilderState<Root> extends State<KeyedFormBuilder<Root>> {
  KeyedFormController<Root>? _form;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final form = KeyedForm.controllerOf<Root>(context);
    if (!identical(form, _form)) {
      _form?.removeListener(_rebuild);
      _form = form..addListener(_rebuild);
    }
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _form?.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _form!);
}
