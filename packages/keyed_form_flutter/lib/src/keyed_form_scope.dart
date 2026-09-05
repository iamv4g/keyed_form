import 'package:flutter/widgets.dart';
import 'package:keyed_form/keyed_form.dart';

import 'keyed_field_registry.dart';

/// Turns a stored error string into display text for the given context — the
/// app's i18n switch. Return the input unchanged for schemas that already
/// store localized messages.
typedef KeyedErrorTranslator = String Function(BuildContext context, String error);

String _identity(BuildContext _, String error) => error;

/// Publishes a [KeyedFormController], a [KeyedFieldRegistry] and an [KeyedErrorTranslator]
/// down the tree for [KeyedFormField] / [KeyedFieldList] to find.
///
/// This is an [InheritedWidget], not an [InheritedNotifier]: the controller is
/// a `package:listen` `ChangeNotifier`, so widgets subscribe to it directly
/// and rebuild selectively rather than all together.
///
/// [translateError] must be a stable reference (a top-level or static
/// function) — it is read non-reactively and a change to it does not
/// re-propagate.
class KeyedFormScope<Root> extends InheritedWidget {
  const KeyedFormScope({
    required this.controller,
    required this.registry,
    required super.child,
    this.translateError = _identity,
    super.key,
  });

  final KeyedFormController<Root> controller;
  final KeyedFieldRegistry registry;
  final KeyedErrorTranslator translateError;

  /// The nearest [KeyedFormScope] of this [Root] type, or `null`.
  static KeyedFormScope<Root>? maybeOf<Root>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<KeyedFormScope<Root>>();

  /// The nearest [KeyedFormScope] of this [Root] type. Asserts one exists.
  static KeyedFormScope<Root> of<Root>(BuildContext context) {
    final scope = maybeOf<Root>(context);
    assert(scope != null, 'No KeyedFormScope<$Root> ancestor found');
    return scope!;
  }

  /// The ambient [KeyedFormController] for this [Root] type.
  static KeyedFormController<Root> controllerOf<Root>(BuildContext context) =>
      of<Root>(context).controller;

  /// The ambient [KeyedFieldRegistry] for this [Root] type.
  static KeyedFieldRegistry registryOf<Root>(BuildContext context) =>
      of<Root>(context).registry;

  @override
  bool updateShouldNotify(KeyedFormScope<Root> oldWidget) =>
      !identical(controller, oldWidget.controller) ||
      !identical(registry, oldWidget.registry);
}
