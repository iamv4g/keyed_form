import 'package:keyed_lens/src/field_key.dart';
import 'package:keyed_lens/src/opt.dart';

/// A composable, possibly-missing accessor into an immutable [Root] — the
/// *behavior* half of the engine ([FieldKey] is the identity half; every
/// lens carries its own [key]).
///
/// "Affine" means the target may not exist: any path that goes through a
/// by-id list segment can stop resolving the moment that row is removed.
/// The semantics are chosen so that stale lenses held by in-flight UI events
/// are harmless by construction:
///
/// - [find] returns [None] when the path doesn't resolve;
/// - [set]/[update] on a non-resolving path return [Root] **unchanged**
///   (no-op) instead of throwing.
///
/// Composition ([then]) concatenates both behavior and [key], so a fully
/// composed lens knows its own stable identity.
abstract class AffineLens<Root, Value> {
  const AffineLens();

  factory AffineLens.of({
    required FieldKey key,
    required Opt<Value> Function(Root root) find,
    required Root Function(Root root, Value value) set,
  }) => _FunctionAffineLens(key, find, set);

  /// Identity of the addressed field, relative to [Root].
  FieldKey get key;

  Opt<Value> find(Root root);

  /// Returns a new [Root] with the target replaced, or [root] unchanged when
  /// the path doesn't resolve.
  Root set(Root root, Value value);

  /// Everyday read. Note that for nullable [Value] this conflates "missing"
  /// with "present but null" — use [find] where that distinction matters
  /// (it rarely does outside the engine itself).
  Value? getOrNull(Root root) => switch (find(root)) {
    Some(:final value) => value,
    None() => null,
  };

  bool existsIn(Root root) => find(root) is Some<Value>;

  /// Reads the target, applies [transform], writes the result back; no-op
  /// when the path doesn't resolve.
  Root update(Root root, Value Function(Value value) transform) =>
      switch (find(root)) {
        Some(:final value) => set(root, transform(value)),
        None() => root,
      };

  /// Affine composition — the everyday one. Anything composed through a
  /// by-id segment is affine no matter how "required" its leaves are.
  AffineLens<Root, Next> then<Next>(AffineLens<Value, Next> next) =>
      _ComposedAffineLens(this, next);

  /// Per-field dirty check: whether this field differs between two roots
  /// (typically the seeded original and the current draft). Missing-vs-
  /// present counts as different; missing in both counts as equal.
  bool differs(Root a, Root b) => find(a) != find(b);
}

/// Refines a nullable field into an affine path to its non-null value.
extension WhenPresent<Root, Value extends Object> on AffineLens<Root, Value?> {
  /// `find` is [None] while the field holds null; `set` writes only while
  /// the field is currently non-null — a null struct means "absent
  /// subform", and *creating* it is a business command on the notifier,
  /// not a field write (the same no-op-on-miss law as removed rows).
  /// The [key] is unchanged: this addresses the same field, refined.
  AffineLens<Root, Value> whenPresent() => AffineLens<Root, Value>.of(
    key: key,
    find: (root) => switch (find(root)) {
      Some(:final value) => value == null ? None<Value>() : Some(value),
      None() => None<Value>(),
    },
    set: set,
  );
}

/// A total lens: the target always exists, so [get] is non-null and [set]
/// always applies. Use for scalar fields of a struct (`invoice.title`); a chain
/// stays total only while every segment is total ([thenTotal]).
abstract class Lens<Root, Value> extends AffineLens<Root, Value> {
  const Lens();

  factory Lens.of({
    required FieldKey key,
    required Value Function(Root root) get,
    required Root Function(Root root, Value value) set,
  }) => _FunctionLens(key, get, set);

  Value get(Root root);

  @override
  Opt<Value> find(Root root) => Some(get(root));

  Root modify(Root root, Value Function(Value value) transform) =>
      set(root, transform(get(root)));

  /// Total composition — preserves non-null [get]. Prefer [then] unless you
  /// actually need the total guarantee on the composed result.
  Lens<Root, Next> thenTotal<Next>(Lens<Value, Next> next) =>
      _ComposedLens(this, next);
}

final class _FunctionAffineLens<Root, Value> extends AffineLens<Root, Value> {
  const _FunctionAffineLens(this.key, this._find, this._set);

  @override
  final FieldKey key;
  final Opt<Value> Function(Root root) _find;
  final Root Function(Root root, Value value) _set;

  @override
  Opt<Value> find(Root root) => _find(root);

  @override
  Root set(Root root, Value value) => switch (find(root)) {
    Some() => _set(root, value),
    None() => root,
  };
}

final class _FunctionLens<Root, Value> extends Lens<Root, Value> {
  const _FunctionLens(this.key, this._get, this._set);

  @override
  final FieldKey key;
  final Value Function(Root root) _get;
  final Root Function(Root root, Value value) _set;

  @override
  Value get(Root root) => _get(root);

  @override
  Root set(Root root, Value value) => _set(root, value);
}

final class _ComposedAffineLens<Root, Mid, Value>
    extends AffineLens<Root, Value> {
  const _ComposedAffineLens(this.outer, this.inner);

  final AffineLens<Root, Mid> outer;
  final AffineLens<Mid, Value> inner;

  @override
  FieldKey get key => outer.key + inner.key;

  @override
  Opt<Value> find(Root root) => switch (outer.find(root)) {
    Some(:final value) => inner.find(value),
    None() => None<Value>(),
  };

  @override
  Root set(Root root, Value value) => switch (outer.find(root)) {
    Some(value: final mid) => outer.set(root, inner.set(mid, value)),
    None() => root,
  };
}

final class _ComposedLens<Root, Mid, Value> extends Lens<Root, Value> {
  const _ComposedLens(this.outer, this.inner);

  final Lens<Root, Mid> outer;
  final Lens<Mid, Value> inner;

  @override
  FieldKey get key => outer.key + inner.key;

  @override
  Value get(Root root) => inner.get(outer.get(root));

  @override
  Root set(Root root, Value value) =>
      outer.set(root, inner.set(outer.get(root), value));
}
