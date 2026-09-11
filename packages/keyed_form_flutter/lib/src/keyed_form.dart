import 'package:flutter/widgets.dart';
import 'package:keyed_form/keyed_form.dart';

import 'keyed_field_registry.dart';
import 'keyed_form_context.dart';

/// Turns a stored error string into display text for the given context — the
/// app's i18n switch. Return the input unchanged for schemas that already
/// store localized messages.
typedef KeyedErrorTranslator =
    String Function(BuildContext context, String error);

String _identity(BuildContext _, String error) => error;

/// Wraps [child] in the ambient form for [Root] — the `Form` of this family.
/// Publishes [controller] and owns a [KeyedFieldRegistry] (created once, for
/// the lifetime of this widget — apps never construct one) for
/// [KeyedFormField] / [KeyedFieldList] to find, and installs the hidden
/// reactive scope that backs `context.watchField` / `context.watchForm` /
/// `context.selectForm`.
///
/// [translateError] must be a stable reference (a top-level or static
/// function) — it is read non-reactively and a change to it does not
/// re-propagate.
class KeyedForm<Root> extends StatefulWidget {
  const KeyedForm({
    required this.controller,
    this.translateError = _identity,
    required this.child,
    super.key,
  });

  final KeyedFormController<Root> controller;
  final KeyedErrorTranslator translateError;
  final Widget child;

  /// The ambient [KeyedFormController] for this [Root] type. [context] must
  /// be a descendant of a [KeyedForm]`<Root>` — typically the `context` a
  /// builder callback hands you (`KeyedFormSelector`, `KeyedFormBuilder`,
  /// `KeyedFormField`'s own builder), not the `context` of the [State] that
  /// *created* the [KeyedForm] (that one sits above it in the tree).
  static KeyedFormController<Root> controllerOf<Root>(BuildContext context) =>
      _FormScope.of<Root>(context).controller;

  /// The ambient [KeyedFieldRegistry] for this [Root] type — see
  /// [controllerOf] for the [context] requirement. Prefer
  /// `form.handleSubmit(context, onValid)`, which reads this for you.
  static KeyedFieldRegistry registryOf<Root>(BuildContext context) =>
      _FormScope.of<Root>(context).registry;

  /// The ambient [KeyedErrorTranslator] for this [Root] type — see
  /// [controllerOf] for the [context] requirement.
  static KeyedErrorTranslator translateErrorOf<Root>(BuildContext context) =>
      _FormScope.of<Root>(context).translateError;

  @override
  State<KeyedForm<Root>> createState() => _KeyedFormState<Root>();
}

class _KeyedFormState<Root> extends State<KeyedForm<Root>> {
  // Created once and held for this State's lifetime, so anchors registered
  // by descendants stay valid across every rebuild of `KeyedForm` itself.
  final KeyedFieldRegistry _registry = KeyedFieldRegistry();

  @override
  Widget build(BuildContext context) => _FormScope<Root>(
    controller: widget.controller,
    registry: _registry,
    translateError: widget.translateError,
    child: widget.child,
  );
}

/// This is an [InheritedWidget], not an [InheritedNotifier]: the controller
/// is a `package:listen` `ChangeNotifier`, so widgets subscribe to it
/// directly (via the field widgets or the `context.*` selectors) and rebuild
/// selectively rather than all together.
class _FormScope<Root> extends InheritedWidget {
  _FormScope({
    required this.controller,
    required this.registry,
    required Widget child,
    this.translateError = _identity,
  }) : super(child: wrapWithReactiveScope<Root>(controller, child));

  final KeyedFormController<Root> controller;
  final KeyedFieldRegistry registry;
  final KeyedErrorTranslator translateError;

  static _FormScope<Root>? _maybeOf<Root>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_FormScope<Root>>();

  static _FormScope<Root> of<Root>(BuildContext context) {
    final scope = _maybeOf<Root>(context);
    assert(scope != null, 'No KeyedForm<$Root> ancestor found');
    return scope!;
  }

  @override
  bool updateShouldNotify(_FormScope<Root> oldWidget) =>
      !identical(controller, oldWidget.controller) ||
      !identical(registry, oldWidget.registry);
}
