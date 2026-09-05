import 'package:keyed_lens/src/field_key.dart';
import 'package:keyed_lens/src/lens.dart';
import 'package:keyed_lens/src/opt.dart';

/// Addresses one element of a list by row id — the segment that makes a
/// chain affine. Identity ([FieldKey.id]) uses the id, never the index, so
/// keys stay valid across insert/remove of sibling rows.
///
/// [set] replaces the first element [matches] accepts, preserving order and
/// the other elements; when no element matches (row was removed), it returns
/// the list unchanged, per the affine no-op contract.
final class ListItemLens<E> extends AffineLens<List<E>, E> {
  ListItemLens({required Object id, required bool Function(E element) matches})
    : this._(FieldKey.id(id), matches);

  ListItemLens._(this.key, this._matches);

  @override
  final FieldKey key;
  final bool Function(E element) _matches;

  @override
  Opt<E> find(List<E> root) {
    final index = root.indexWhere(_matches);
    return index < 0 ? None<E>() : Some(root[index]);
  }

  @override
  List<E> set(List<E> root, E value) {
    final index = root.indexWhere(_matches);
    if (index < 0) return root;
    return [...root]..[index] = value;
  }
}

extension ListLensAt<Root, E> on AffineLens<Root, List<E>> {
  /// Sugar for descending into a list row by id:
  /// `days.at(dayId, (d) => d.id == dayId)`. Applications typically wrap
  /// this in a typed helper so call sites pass the id once.
  AffineLens<Root, E> at(Object id, bool Function(E element) matches) =>
      then(ListItemLens(id: id, matches: matches));
}
