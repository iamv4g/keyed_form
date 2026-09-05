import 'package:keyed_lens/src/field_key.dart';
import 'package:keyed_lens/src/lens.dart';

/// Validation errors keyed by [FieldKey], looked up by *lens* — callable so
/// UI code asks for a field's error in the same vocabulary it reads and
/// writes the field with, never touching `.key` directly:
///
/// ```dart
/// errorText: state.errors(admissionName(ref))
/// ```
///
/// The lens parameter is intentionally widened to `AffineLens<Object?,
/// Object?>` (safe under Dart's covariant generics because only `key` is
/// read); [E] is the application's error type.
final class FieldErrors<E> {
  const FieldErrors(Map<FieldKey, E> byKey) : _byKey = byKey;

  const FieldErrors.empty() : _byKey = const {};

  final Map<FieldKey, E> _byKey;

  E? call(AffineLens<Object?, Object?> lens) => _byKey[lens.key];

  E? byKey(FieldKey key) => _byKey[key];

  bool get isEmpty => _byKey.isEmpty;

  bool get isNotEmpty => _byKey.isNotEmpty;

  int get length => _byKey.length;

  Iterable<FieldKey> get keys => _byKey.keys;

  /// Drops every entry whose key is [root] or nested under it (per
  /// [FieldKey.contains]) — the operation an editor runs when a row is
  /// removed, so its field errors do not outlive it. Surviving entries keep
  /// their original (document) order.
  FieldErrors<E> removeSubtree(FieldKey root) {
    final kept = <FieldKey, E>{};
    for (final entry in _byKey.entries) {
      if (!root.contains(entry.key)) kept[entry.key] = entry.value;
    }
    return FieldErrors(kept);
  }
}
