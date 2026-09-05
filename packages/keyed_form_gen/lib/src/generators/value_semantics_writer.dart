/// Emits the value-semantics boilerplate shared across every class shape
/// [DataClassGenerator] produces: the `copyWith` interface/impl pair,
/// `operator ==`, and `hashCode`. Not exported from the package's public
/// API — internal to the generator only.
library;

import '../models/schema_model.dart';

/// One resolved constructor parameter for a generated class — computed by
/// [DataClassGenerator] from a [ParsedField] (plus the always-present
/// `clientId` for a list item), and consumed by every writer in this file.
class FieldDef {
  FieldDef({
    required this.name,
    required this.type,
    this.defaultValue,
    this.isRequired = false,
    this.isClientId = false,
  });

  final String name;
  final String type;
  final String? defaultValue;
  final bool isRequired;
  final bool isClientId;
}

/// The public-interface param declaration (`Type name` or `Type name =
/// default`) for [f] in a copyWith `call()`:
///
/// - Already-nullable field → `Type? name` (no default written; an
///   optional nullable param can always be omitted).
/// The nullable-shaped param type for a `XCopyWith.call()` parameter — the
/// field's own type if already nullable, else that type suffixed `?`. Every
/// copyWith param is optional and nullable-shaped so it can be omitted; see
/// [_needsSentinel] for why a non-nullable field needs no default (dummy or
/// real) to go with it.
String _nullableParamType(String type) => type.endsWith('?') ? type : '$type?';

/// Whether [f] needs the `Object? = _unset` sentinel treatment at all:
/// **only genuinely nullable fields do.** A non-nullable field can never
/// legitimately be set to `null`, so "omitted" and "explicitly passed
/// null" collapse to the same intent ("don't change this field") — a
/// plain nullable param resolved with `field ?? _value.field` handles that
/// correctly with no sentinel, no cast, and no per-field/per-type default
/// value needed, for *any* type (int, bool, enum, nested object, ... —
/// not just the types the current schemas happen to use).
///
/// This mirrors `dart_mappable` (already generating other models in this
/// app, e.g. `tour_guide_builder.mapper.dart`): its nullable fields
/// (`id`, `groupId`, ...) get `Object? x = $none` + `x != $none`, exactly
/// the sentinel shape used here — but its **non-nullable** fields
/// (`dateIndexes`, `guideIdsByDay`, both of which *do* have a schema
/// default) still get a plain `List<int>? x` / `Map<int, int>? x` param
/// with a bare `x != null` check, never a "make it non-nullable with a
/// dummy/real default" trick. An earlier version of this generator tried
/// exactly that trick (real defaults for fields with one, a dummy `''`
/// for `clientId`) — it bought a compile error instead of a runtime crash
/// for `copyWith(field: null)` on those specific fields, but silently
/// left every *other* non-nullable-no-default field (any type but
/// `clientId`'s `String`) with the original runtime-crash risk, since
/// nothing but the interface's param type had changed for them. Using the
/// plain-nullable-plus-`??` shape for every non-nullable field closes
/// that gap uniformly instead of chasing it type by type.
bool _needsSentinel(FieldDef f) => f.type.endsWith('?');

/// Whether [type] (nullable or not) is a `List<...>`.
bool _isListType(String type) => _stripNullable(type).startsWith('List<');

/// Whether [type] (nullable or not) is a `Map<...>`.
bool _isMapType(String type) => _stripNullable(type).startsWith('Map<');

String _stripNullable(String type) =>
    type.endsWith('?') ? type.substring(0, type.length - 1) : type;

/// Emits the `${name}CopyWith` interface + `_${name}CopyWithImpl`, shared by
/// [DataClassGenerator._generateNormalClass] and
/// [DataClassGenerator._generateUnionVariantClass] — the `freezed`-style
/// callable-copyWith pattern.
///
/// The PUBLIC interface types every field as its own nullable-shaped type
/// ([_nullableParamType]), so a bare `[]`/`{}` literal at a call site gets
/// proper downward type inference — the untyped-literal cast crash that
/// motivated this is prevented by the type system, not patched around
/// inside copyWith.
///
/// The PRIVATE impl resolves each field one of two ways depending on
/// [_needsSentinel]:
/// - Nullable field: `Object? field = _unset` + `identical(field, _unset)
///   ? _value.field : field as Type`. Dart resolves the default value for
///   an *omitted* named argument through the method actually dispatched
///   to (here, always the impl, since `copyWith` is an interface-typed
///   getter and the call is a virtual dispatch the compiler can't resolve
///   at the call site) — not through the static interface declaration
///   used only to type-check the call. So `identical(field, _unset)`
///   still correctly distinguishes "field not passed" from "field
///   explicitly passed null" — with the exact same call-site syntax as a
///   plain method (`obj.copyWith(field: value)`), zero call-site
///   migration needed versus the old design.
/// - Non-nullable field: plain `Type? field` (no sentinel needed at all —
///   see [_needsSentinel]) + `field ?? _value.field`.
///
/// The interface is generic (`XCopyWith<T>`, always instantiated to the
/// concrete class at every `get copyWith` site) rather than returning the
/// class directly — purely to keep `field: null` from being flagged
/// `avoid_redundant_argument_values` at call sites (the lint's
/// redundant-default check doesn't fire through a generic-instantiated
/// receiver type the way it does a plain one; verified empirically against
/// this repo's `very_good_analysis` config). It has no effect on the
/// resolution mechanics above.
///
/// [implementsInterface], when given (union variants only), makes this
/// class's `XCopyWith<T>` interface `implements` the base's — required for
/// the variant's `@override XCopyWith<T> get copyWith` (covariant return
/// type) to type-check against the base's `BaseCopyWith<T> get copyWith`.
void writeCopyWithInterfaceAndImpl(
  StringBuffer buffer,
  String name,
  List<FieldDef> allFields, {
  String? implementsInterface,
}) {
  final copyWithName = '${name}CopyWith';
  final implName = '_${name}CopyWithImpl';
  final implementsClause = implementsInterface == null
      ? ''
      : ' implements $implementsInterface<T>';

  buffer.writeln(
    'abstract interface class $copyWithName<T>$implementsClause {',
  );
  buffer.writeln('  T call({');
  for (final f in allFields) {
    buffer.writeln('    ${_nullableParamType(f.type)} ${f.name},');
  }
  buffer.writeln('  });');
  buffer.writeln('}');
  buffer.writeln();

  buffer.writeln('class $implName implements $copyWithName<$name> {');
  buffer.writeln('  const $implName(this._value);');
  buffer.writeln('  final $name _value;');
  buffer.writeln();
  buffer.writeln('  @override');
  buffer.writeln('  $name call({');
  for (final f in allFields) {
    if (_needsSentinel(f)) {
      buffer.writeln('    Object? ${f.name} = _unset,');
    } else {
      buffer.writeln('    ${_nullableParamType(f.type)} ${f.name},');
    }
  }
  buffer.writeln('  }) => $name(');
  for (final f in allFields) {
    if (_needsSentinel(f)) {
      buffer.writeln(
        '    ${f.name}: identical(${f.name}, _unset) ? _value.${f.name} : ${f.name} as ${f.type},',
      );
    } else {
      buffer.writeln('    ${f.name}: ${f.name} ?? _value.${f.name},');
    }
  }
  buffer.writeln('  );');
  buffer.writeln('}');
  buffer.writeln();
}

/// Emits the `${name}CopyWith` interface + `_${name}CopyWithImpl` for a
/// union *base* (sealed) class —
/// [DataClassGenerator._generateUnionBaseClass]. Same public/private split
/// and per-field [_needsSentinel] branching as
/// [writeCopyWithInterfaceAndImpl], but the impl's `call()` resolves each
/// param at the base level *first*, then forwards a concrete (already-
/// resolved) value to whichever variant `this` actually is — so "not
/// passed at the base" stays "not passed" once relayed to the variant's
/// own copyWith, rather than being flattened into an explicit `null`.
void writeUnionBaseCopyWith(
  StringBuffer buffer,
  String name,
  List<FieldDef> allFields,
  Map<String, ParsedClass> unionVariants,
) {
  final copyWithName = '${name}CopyWith';
  final implName = '_${name}CopyWithImpl';

  buffer.writeln('abstract interface class $copyWithName<T> {');
  buffer.writeln('  T call({');
  for (final f in allFields) {
    buffer.writeln('    ${_nullableParamType(f.type)} ${f.name},');
  }
  buffer.writeln('  });');
  buffer.writeln('}');
  buffer.writeln();

  buffer.writeln('class $implName implements $copyWithName<$name> {');
  buffer.writeln('  const $implName(this._value);');
  buffer.writeln('  final $name _value;');
  buffer.writeln();
  buffer.writeln('  @override');
  buffer.writeln('  $name call({');
  for (final f in allFields) {
    if (_needsSentinel(f)) {
      buffer.writeln('    Object? ${f.name} = _unset,');
    } else {
      buffer.writeln('    ${_nullableParamType(f.type)} ${f.name},');
    }
  }
  buffer.writeln('  }) => switch (_value) {');
  for (final v in unionVariants.values) {
    final args = allFields
        .map((f) {
          if (_needsSentinel(f)) {
            return '${f.name}: identical(${f.name}, _unset) ? x.${f.name} : ${f.name} as ${f.type}';
          }
          return '${f.name}: ${f.name} ?? x.${f.name}';
        })
        .join(', ');
    buffer.writeln('    ${v.name} x => x.copyWith($args),');
  }
  buffer.writeln('  };');
  buffer.writeln('}');
  buffer.writeln();
}

/// Emits `operator ==`, shared by [DataClassGenerator._generateNormalClass]
/// and [DataClassGenerator._generateUnionVariantClass]. `List<...>` fields
/// compare via `_listEquals` (order-sensitive) and `Map<...>` fields via
/// `_mapEquals` (order-independent) — both from the shared preamble — since
/// plain `==` on a mutable `List`/`Map` is reference equality.
void writeEquality(StringBuffer buffer, String name, List<FieldDef> allFields) {
  buffer.writeln('  @override');
  buffer.writeln('  bool operator ==(Object other) {');
  buffer.writeln('    if (identical(this, other)) return true;');
  buffer.writeln('    return other is $name &&');
  final eqChecks = allFields
      .map((f) {
        if (_isListType(f.type)) {
          return '_listEquals(${f.name}, other.${f.name})';
        }
        if (_isMapType(f.type)) {
          return '_mapEquals(${f.name}, other.${f.name})';
        }
        return '${f.name} == other.${f.name}';
      })
      .join(' &&\n        ');
  buffer.writeln('        ${eqChecks.isEmpty ? 'true' : eqChecks};');
  buffer.writeln('  }');
  buffer.writeln();
}

/// Emits `hashCode`, shared by [DataClassGenerator._generateNormalClass] and
/// [DataClassGenerator._generateUnionVariantClass] — kept consistent with
/// [writeEquality]'s per-field equality choice (`List<...>` →
/// `Object.hashAll`, `Map<...>` → the order-independent `_mapHash`).
void writeHashCode(StringBuffer buffer, List<FieldDef> allFields) {
  buffer.writeln('  @override');
  if (allFields.isEmpty) {
    buffer.writeln('  int get hashCode => 0;');
  } else if (allFields.length == 1) {
    final f = allFields.first;
    if (_isListType(f.type)) {
      buffer.writeln('  int get hashCode => Object.hashAll(${f.name});');
    } else if (_isMapType(f.type)) {
      buffer.writeln('  int get hashCode => _mapHash(${f.name});');
    } else {
      buffer.writeln('  int get hashCode => ${f.name}.hashCode;');
    }
  } else if (allFields.length > 20) {
    buffer.writeln('  int get hashCode => Object.hashAll([');
    for (final f in allFields) {
      if (_isListType(f.type)) {
        buffer.writeln('    Object.hashAll(${f.name}),');
      } else if (_isMapType(f.type)) {
        buffer.writeln('    _mapHash(${f.name}),');
      } else {
        buffer.writeln('    ${f.name},');
      }
    }
    buffer.writeln('  ]);');
  } else {
    buffer.writeln('  int get hashCode => Object.hash(');
    for (final f in allFields) {
      if (_isListType(f.type)) {
        buffer.writeln('    Object.hashAll(${f.name}),');
      } else if (_isMapType(f.type)) {
        buffer.writeln('    _mapHash(${f.name}),');
      } else {
        buffer.writeln('    ${f.name},');
      }
    }
    buffer.writeln('  );');
  }
}
