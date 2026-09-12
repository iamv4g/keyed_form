import 'package:keyed_lens/keyed_lens.dart'
    hide WhenPresent, AffineLensNarrowX, ListLensAt;

/// A typed handle to one field of [R] — read, write, dirty-check or focus it
/// without rebuilding the whole aggregate.
///
/// The target may be missing (a removed list row, a null sub-struct, the wrong
/// union variant), so `getOrNull` can return null and writes can no-op. Wraps
/// the `keyed_lens` affine optic; the form layers speak only this "field
/// reference" vocabulary — `then` is redeclared so composing two field
/// references keeps producing [FieldRef], never the underlying optic type.
extension type FieldRef<R, V>(AffineLens<R, V> _inner)
    implements AffineLens<R, V> {
  /// Builds a [FieldRef] from explicit [find] / [set] functions.
  factory FieldRef.of({
    required FieldKey key,
    required Opt<V> Function(R root) find,
    required R Function(R root, V value) set,
  }) => FieldRef(AffineLens<R, V>.of(key: key, find: find, set: set));

  /// Affine composition — the everyday one. Anything composed through a
  /// by-id segment is affine no matter how "required" its leaves are.
  FieldRef<R, Next> then<Next>(FieldRef<V, Next> next) =>
      FieldRef(_inner.then(next));
}

/// A [FieldRef] whose target always resolves — `get` is non-null and `set`
/// always applies. Generated for plain scalar struct fields. A chain stays
/// strict only while every segment is strict.
extension type StrictFieldRef<R, V>(Lens<R, V> _inner)
    implements Lens<R, V>, FieldRef<R, V> {
  /// Builds a [StrictFieldRef] from explicit [get] / [set] functions.
  factory StrictFieldRef.of({
    required FieldKey key,
    required V Function(R root) get,
    required R Function(R root, V value) set,
  }) => StrictFieldRef(Lens<R, V>.of(key: key, get: get, set: set));

  // `Lens<R, V>` and `FieldRef<R, V>` each contribute a `then` with a
  // different signature, so it must be redeclared here to resolve the
  // conflict (not just for vocabulary — this one is required to compile).
  FieldRef<R, Next> then<Next>(FieldRef<V, Next> next) =>
      FieldRef(_inner.then(next));

  /// Total composition — preserves non-null `get`. Prefer `then` unless you
  /// actually need the total guarantee on the composed result.
  StrictFieldRef<R, Next> thenTotal<Next>(StrictFieldRef<V, Next> next) =>
      StrictFieldRef(_inner.thenTotal(next));
}

/// A [FieldRef] valid only while [S] is a specific variant [V] of a sum type —
/// compose with [FieldRefNarrow.narrow].
extension type VariantRef<S, V extends S>(Prism<S, V> _inner)
    implements Prism<S, V>, FieldRef<S, V> {
  /// Creates a [VariantRef] leveraging Dart's type system (`source is V`).
  factory VariantRef.type({FieldKey? key}) =>
      VariantRef(Prism<S, V>.type(key: key));

  // Same conflict as `StrictFieldRef.then` above (`Prism` inherits
  // `AffineLens.then`, `FieldRef` redeclares it) — required to compile.
  FieldRef<S, Next> then<Next>(FieldRef<V, Next> next) =>
      FieldRef(_inner.then(next));
}

/// Base for generated `<X>FieldRefs` wrapper classes: holds an inner
/// [FieldRef] and forwards `key` / `find` / `set` to it, so generated code
/// never has to spell `Opt` or the raw optic types. Extend (don't implement)
/// so the wrapper inherits `then` / `getOrNull` / `update` / `differs`.
class DelegatingFieldRef<R, V> extends AffineLens<R, V> {
  DelegatingFieldRef(this.inner);

  /// The composed field reference this wrapper delegates to.
  final FieldRef<R, V> inner;

  /// This wrapper viewed as a plain [FieldRef]. Needed wherever a [FieldRef]
  /// value is expected: unlike the old `typedef`, an `extension type` does
  /// not implicitly accept a [DelegatingFieldRef] subclass in its place, so
  /// composing or passing a generated wrapper as a bare field reference goes
  /// through this getter (`wrapper.asFieldRef.then(...)`).
  FieldRef<R, V> get asFieldRef => FieldRef<R, V>(this);

  @override
  FieldKey get key => inner.key;

  @override
  Opt<V> find(R root) => inner.find(root);

  @override
  R set(R root, V value) => inner.set(root, value);
}

/// Refines a nullable field into a [FieldRef] to its non-null value: `find` is
/// missing while the field holds null, `set` writes only while it is
/// currently non-null.
extension FieldRefWhenPresent<R, V extends Object> on FieldRef<R, V?> {
  FieldRef<R, V> whenPresent() => FieldRef<R, V>.of(
    key: key,
    find: (root) => switch (find(root)) {
      Some(:final value) => value == null ? None<V>() : Some(value),
      None() => None<V>(),
    },
    set: set,
  );
}

/// Narrows a [FieldRef] on a sum type to one of its variants through a
/// [VariantRef] — null / no-op when the value is a different variant.
extension FieldRefNarrow<R, V> on FieldRef<R, V> {
  FieldRef<R, W> narrow<W extends V>(VariantRef<V, W> variant) => then(variant);
}

/// Descends into a list row by client id: `rows.at(id, (r) => r.clientId == id)`.
extension FieldRefAt<R, E> on FieldRef<R, List<E>> {
  FieldRef<R, E> at(Object id, bool Function(E element) matches) =>
      then(FieldRef<List<E>, E>(ListItemLens(id: id, matches: matches)));
}
