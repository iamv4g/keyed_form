import 'package:keyed_lens/keyed_lens.dart'
    hide WhenPresent, AffineLensNarrowX, ListLensAt;

/// A typed handle to one field of [R] — read, write, dirty-check or focus it
/// without rebuilding the whole aggregate.
///
/// The target may be missing (a removed list row, a null sub-struct, the wrong
/// union variant), so `getOrNull` can return null and writes can no-op. Alias
/// of the `keyed_lens` affine optic; the form layers speak only this
/// "field reference" vocabulary.
typedef FieldRef<R, V> = AffineLens<R, V>;

/// A [FieldRef] whose target always resolves — `get` is non-null and `set`
/// always applies. Generated for plain scalar struct fields. A chain stays
/// strict only while every segment is strict.
typedef StrictFieldRef<R, V> = Lens<R, V>;

/// A [FieldRef] valid only while [S] is a specific variant [V] of a sum type —
/// compose with [FieldRefNarrow.narrow].
typedef VariantRef<S, V extends S> = Prism<S, V>;

/// Base for generated `<X>FieldRefs` wrapper classes: holds an inner
/// [FieldRef] and forwards `key` / `find` / `set` to it, so generated code
/// never has to spell `Opt` or the raw optic types. Extend (don't implement)
/// so the wrapper inherits `then` / `getOrNull` / `update` / `differs`.
class DelegatingFieldRef<R, V> extends AffineLens<R, V> {
  DelegatingFieldRef(this.inner);

  /// The composed field reference this wrapper delegates to.
  final FieldRef<R, V> inner;

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
  FieldRef<R, V> whenPresent() => AffineLens<R, V>.of(
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
      then(ListItemLens(id: id, matches: matches));
}
