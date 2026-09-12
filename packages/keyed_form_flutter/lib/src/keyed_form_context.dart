import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:keyed_form/keyed_form.dart';

/// `context.watchField` / `context.watchForm` / `context.selectForm` — read a
/// slice of the ambient [KeyedFormController] in `build()`, get the value
/// back, and rebuild **this** element only when that slice changes.
///
/// The react-hook-form `watch(name)` / bloc `context.select` of this family.
/// The machinery mirrors `provider`'s `context.select`: a hidden inherited
/// scope ([KeyedForm] installs it) whose element listens to the
/// controller and, on each change, re-runs every dependent's registered
/// predicate — a dependent rebuilds only if one says its slice moved.
extension KeyedFormContext on BuildContext {
  /// The whole draft — rebuilds on any change to it (the `Root` `==`). The
  /// analogue of react-hook-form's `watch()`.
  Root watchForm<Root>() => _watchSlice<Root, Root>(this, (f) => f.value);

  /// One field's current value — rebuilds when it changes. The analogue of
  /// react-hook-form's `watch("name")`. Its error / dirty state live on the
  /// controller (`context.selectForm((f) => f.visibleErrorFor(ref))`).
  V? watchField<Root, V>(FieldRef<Root, V> ref) =>
      _watchSlice<Root, V?>(this, (f) => ref.getOrNull(f.value));

  /// A derived slice — rebuilds when `selector(form)` changes (by [equals],
  /// default `==`). The analogue of bloc's `context.select`.
  ///
  /// `Root` infers from a typed closure parameter
  /// (`(KeyedFormController<TourForm> f) => f.isDirty`); otherwise give it
  /// explicitly (`context.selectForm<TourForm, bool>(...)`). A collection
  /// slice needs an [equals] (there is no pure-Dart `listEquals`) or should
  /// be a record of scalars, which compare structurally.
  ///
  /// The selector must not write to the controller.
  T selectForm<Root, T>(
    T Function(KeyedFormController<Root> form) selector, {
    bool Function(T a, T b)? equals,
  }) => _watchSlice<Root, T>(this, selector, equals: equals);
}

bool _defaultEquals<T>(T a, T b) => a == b;

// Set while a selector / predicate runs, so a nested watch/select throws.
bool _debugSelecting = false;

T _watchSlice<Root, T>(
  BuildContext context,
  T Function(KeyedFormController<Root> form) selector, {
  bool Function(T a, T b)? equals,
}) {
  assert(
    context.debugDoingBuild,
    'watchForm / watchField / selectForm must be called inside build().',
  );
  assert(
    !_debugSelecting,
    'watchForm / watchField / selectForm cannot be used inside a selector.',
  );
  final element = context
      .getElementForInheritedWidgetOfExactType<_KeyedFormReactiveScope<Root>>();
  assert(element != null, 'No KeyedForm<$Root> ancestor found.');
  final scope = element! as _KeyedFormReactiveScopeElement<Root>;
  final controller = scope.controller;

  final T selected;
  assert(() {
    _debugSelecting = true;
    return true;
  }());
  try {
    selected = selector(controller);
  } finally {
    assert(() {
      _debugSelecting = false;
      return true;
    }());
  }

  final eq = equals ?? _defaultEquals;
  context.dependOnInheritedElement(
    scope,
    aspect: _FormSlice(() {
      final T next;
      assert(() {
        _debugSelecting = true;
        return true;
      }());
      try {
        next = selector(scope.controller);
      } finally {
        assert(() {
          _debugSelecting = false;
          return true;
        }());
      }
      return !eq(next, selected);
    }),
  );
  return selected;
}

/// A registered "did my slice move?" predicate. Identity-based so each build
/// installs a fresh one; the element drops the previous build's set (see
/// [_SliceDependency]).
class _FormSlice {
  _FormSlice(this.changed);
  final bool Function() changed;
}

class _SliceDependency {
  final List<_FormSlice> slices = [];
  bool shouldClear = false;
  bool clearScheduled = false;
}

/// Installed by [KeyedForm] (via the private `_FormScope`) just below
/// itself. Never notifies via the widget-diff path (`updateShouldNotify` is
/// `false`); every rebuild of a dependent goes through
/// [_KeyedFormReactiveScopeElement.notifyClients].
class _KeyedFormReactiveScope<Root> extends InheritedWidget {
  const _KeyedFormReactiveScope({
    required this.controller,
    required super.child,
  });

  final KeyedFormController<Root> controller;

  @override
  bool updateShouldNotify(_KeyedFormReactiveScope<Root> oldWidget) => false;

  @override
  InheritedElement createElement() =>
      _KeyedFormReactiveScopeElement<Root>(this);
}

class _KeyedFormReactiveScopeElement<Root> extends InheritedElement {
  _KeyedFormReactiveScopeElement(_KeyedFormReactiveScope<Root> super.widget);

  KeyedFormController<Root> get controller =>
      (widget as _KeyedFormReactiveScope<Root>).controller;

  bool _notifyPending = false;
  bool _listening = false;

  void _onControllerChange() {
    _notifyPending = true;
    markNeedsBuild();
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    controller.addListener(_onControllerChange);
    _listening = true;
  }

  @override
  void update(_KeyedFormReactiveScope<Root> newWidget) {
    final oldController = controller;
    super.update(newWidget);
    if (!identical(oldController, controller)) {
      oldController.removeListener(_onControllerChange);
      controller.addListener(_onControllerChange);
      _notifyPending = true; // a full swap: every dependent re-reads
      markNeedsBuild();
    }
  }

  @override
  Widget build() {
    if (_notifyPending) {
      _notifyPending = false;
      notifyClients(widget as _KeyedFormReactiveScope<Root>);
    }
    return super.build();
  }

  @override
  void unmount() {
    if (_listening) {
      controller.removeListener(_onControllerChange);
      _listening = false;
    }
    super.unmount();
  }

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    final existing = getDependencies(dependent);
    if (existing != null && existing is! _SliceDependency) {
      return; // once "watch everything", always
    }
    if (aspect is _FormSlice) {
      final dep = (existing ?? _SliceDependency()) as _SliceDependency;
      if (dep.shouldClear) {
        dep.shouldClear = false;
        dep.slices.clear();
      }
      if (!dep.clearScheduled) {
        dep.clearScheduled = true;
        scheduleMicrotask(() {
          dep.clearScheduled = false;
          dep.shouldClear = true;
        });
      }
      dep.slices.add(aspect);
      setDependencies(dependent, dep);
    } else {
      setDependencies(dependent, const Object());
    }
  }

  @override
  void notifyDependent(
    covariant _KeyedFormReactiveScope<Root> oldWidget,
    Element dependent,
  ) {
    final dep = getDependencies(dependent);
    if (dep == null || dependent.dirty) return;
    if (dep is! _SliceDependency) {
      dependent.didChangeDependencies();
      return;
    }
    for (final slice in dep.slices) {
      if (slice.changed()) {
        dependent.didChangeDependencies();
        return;
      }
    }
  }
}

/// Used by the private `_FormScope` (`keyed_form.dart`) to install the
/// reactive scope below itself.
InheritedWidget wrapWithReactiveScope<Root>(
  KeyedFormController<Root> controller,
  Widget child,
) => _KeyedFormReactiveScope<Root>(controller: controller, child: child);
