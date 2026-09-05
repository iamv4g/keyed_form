/// The block emitted at the top of every generated part file: the
/// ignore-comment, the `_listEquals`/`_mapEquals`/`_mapHash` helpers used by
/// generated `operator ==`/`hashCode`, and the `_unset` sentinel used inside
/// every generated `_XCopyWithImpl.call()`.
///
/// Both the real `PartBuilder` ([KeyedFormGenerator], `lib/src/keyed_form_generator.dart`)
/// and the standalone `tool/regen_schema.dart` must emit byte-identical
/// output, so both call this instead of duplicating the string — the prior
/// duplication was itself the cause of one generator fix landing in only one
/// of the two places.
///
/// The helpers are emitted unconditionally (regardless of whether the file's
/// schema actually has a `List`/`Map` field), which is why the ignore-comment
/// suppresses `unused_element`.
String generatedPreamble() {
  final buffer = StringBuffer();
  buffer.writeln(
    '// ignore_for_file: type=lint, unused_element, sort_constructors_first, avoid_equals_and_hash_code_on_mutable_classes, specify_nonobvious_property_types',
  );
  buffer.writeln();

  // List-field equality — order-sensitive (a List's identity includes order).
  buffer.writeln('bool _listEquals<T>(List<T>? a, List<T>? b) {');
  buffer.writeln('  if (identical(a, b)) return true;');
  buffer.writeln('  if (a == null || b == null) return false;');
  buffer.writeln('  if (a.length != b.length) return false;');
  buffer.writeln('  for (var i = 0; i < a.length; i++) {');
  buffer.writeln('    if (a[i] != b[i]) return false;');
  buffer.writeln('  }');
  buffer.writeln('  return true;');
  buffer.writeln('}');
  buffer.writeln();

  // Map-field equality/hash — order-independent (a Map's identity is its
  // key/value pairs, not their insertion order), so the hash combines
  // per-entry hashes with XOR rather than `Object.hashAll`, which would be
  // order-sensitive and break the equals/hashCode contract.
  buffer.writeln('bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {');
  buffer.writeln('  if (identical(a, b)) return true;');
  buffer.writeln('  if (a == null || b == null) return false;');
  buffer.writeln('  if (a.length != b.length) return false;');
  buffer.writeln('  for (final entry in a.entries) {');
  buffer.writeln(
    '    if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {',
  );
  buffer.writeln('      return false;');
  buffer.writeln('    }');
  buffer.writeln('  }');
  buffer.writeln('  return true;');
  buffer.writeln('}');
  buffer.writeln();
  buffer.writeln('int _mapHash(Map<Object?, Object?>? map) {');
  buffer.writeln('  if (map == null) return 0;');
  buffer.writeln('  var hash = 0;');
  buffer.writeln('  for (final entry in map.entries) {');
  buffer.writeln('    hash ^= Object.hash(entry.key, entry.value);');
  buffer.writeln('  }');
  buffer.writeln('  return hash;');
  buffer.writeln('}');
  buffer.writeln();

  // The copyWith sentinel — used only inside each generated
  // `_XCopyWithImpl.call()` override to distinguish "not passed" from
  // "explicitly passed null"; the public `XCopyWith.call()` interface each
  // class exposes is fully typed and never sees `_unset`.
  buffer.writeln('const _unset = Object();');
  buffer.writeln();
  return buffer.toString();
}
