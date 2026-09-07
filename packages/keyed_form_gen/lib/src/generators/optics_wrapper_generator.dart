/// Emits the field-reference wrapper subsystem for [DataClassGenerator]: per
/// nested-object `<Field>FieldRefs` wrappers, per-list-field navigators (and
/// their `<Accessor>Ref` typedefs), and discriminated-union variant-narrowing
/// wrappers. Not exported from the package's public API — internal to the
/// generator only.
library;

import '../models/schema_model.dart' show ParsedClass, ParsedField;
import '../naming.dart';

/// Getter names on a wrapper must not shadow the `FieldRef` /
/// `DelegatingFieldRef` / `Object` API the wrapper inherits.
const _reservedWrapperNames = <String>{
  'inner',
  'key',
  'find',
  'set',
  'getOrNull',
  'existsIn',
  'update',
  'then',
  'differs',
  'hashCode',
  'runtimeType',
  'toString',
  'noSuchMethod',
};

/// Pluralised list-field name → singular accessor name.
/// `days`→`day`, `boxes`→`box`, `entryPoints`→`entryPoint`,
/// `rooming`→`rooming`, `statusBuilders`→`statusBuilder`.
String _singularizeField(String name) {
  if (name.endsWith('ies') && name.length > 3) {
    return '${name.substring(0, name.length - 3)}y';
  }
  if (RegExp(r'(ss|x|z|ch|sh)es$').hasMatch(name)) {
    return name.substring(0, name.length - 2);
  }
  if (name.endsWith('s') && !name.endsWith('ss') && name.length > 1) {
    return name.substring(0, name.length - 1);
  }
  return name;
}

String _recordType(List<String> segs) =>
    '({${segs.map((s) => 'String $s').join(', ')}})';

String wrapperClassName(String accessorName) =>
    '${capitalize(accessorName)}FieldRefs';

String _refTypeName(String accessorName) => '${capitalize(accessorName)}Ref';

/// Emits one leaf getter per scalar / nested-object field of [fieldsName]
/// onto a wrapper whose composed reference is `inner` (a `FieldRef<Root,
/// Struct>`). Returns the nested-object sub-wrappers still to be emitted —
/// the caller must emit them *after* closing the current class (Dart has no
/// nested class declarations).
List<(ParsedClass, String)> _emitLeafGetters(
  StringBuffer w,
  String rootClassName,
  String fieldsName,
  Iterable<ParsedField> subFields,
) {
  final pending = <(ParsedClass, String)>[];
  for (final f in subFields) {
    if (f.name == 'clientId') continue;
    if (f.isList && f.nestedClass != null) continue;
    if (_reservedWrapperNames.contains(f.name)) {
      throw StateError(
        "keyed_form_gen: field '${f.name}' on $fieldsName collides with the "
        'FieldRef API — rename it in the schema.',
      );
    }
    w.writeln();
    if (f.isNestedObject && f.nestedClass != null) {
      final nestedWrapper = wrapperClassName(f.name);
      final refined = (f.isNullable || f.isOptional) ? '.whenPresent()' : '';
      w.writeln('  /// Field references for the nested `${f.name}` object.');
      w.writeln('  $nestedWrapper get ${f.name} =>');
      w.writeln(
        '      $nestedWrapper(inner.then($fieldsName.${f.name})$refined);',
      );
      pending.add((f.nestedClass!, nestedWrapper));
    } else {
      w.writeln('  /// `FieldRef` to `$fieldsName.${f.name}`.');
      w.writeln('  FieldRef<$rootClassName, ${f.dartType}> get ${f.name} =>');
      w.writeln('      inner.then($fieldsName.${f.name});');
    }
  }
  return pending;
}

void _emitWrapperHeader(
  StringBuffer w,
  String rootClassName,
  String structName,
  String wrapperName,
  String doc,
) {
  w.writeln('/// $doc');
  w.writeln(
    'final class $wrapperName '
    'extends DelegatingFieldRef<$rootClassName, $structName> {',
  );
  w.writeln('  $wrapperName(super.inner);');
}

/// A plain (non-union) struct wrapper: a `DelegatingFieldRef<Root, Struct>`
/// plus one leaf getter per field. Recurses for nested-object fields.
void emitObjectWrapper(
  StringBuffer w,
  Set<String> emitted,
  String rootClassName,
  ParsedClass structClass,
  String wrapperName,
  String suffix,
) {
  if (!emitted.add(wrapperName)) return;
  _emitWrapperHeader(
    w,
    rootClassName,
    structClass.name,
    wrapperName,
    'Field references for a [${structClass.name}] within [$rootClassName].',
  );
  final pending = _emitLeafGetters(
    w,
    rootClassName,
    getFieldsClassName(structClass.name, suffix),
    structClass.fields,
  );
  w.writeln('}');
  w.writeln();
  for (final (cls, name) in pending) {
    emitObjectWrapper(w, emitted, rootClassName, cls, name, suffix);
  }
}

/// A discriminated-union wrapper: common-field getters plus `.asVariant`
/// getters that narrow into per-variant sub-wrappers.
void _emitUnionWrapper(
  StringBuffer w,
  Set<String> emitted,
  String rootClassName,
  ParsedClass unionClass,
  String wrapperName,
  String suffix,
) {
  if (!emitted.add(wrapperName)) return;
  final variantsName = getVariantsClassName(unionClass.name, suffix);
  _emitWrapperHeader(
    w,
    rootClassName,
    unionClass.name,
    wrapperName,
    'Field references for a [${unionClass.name}] within [$rootClassName].',
  );
  final pending = _emitLeafGetters(
    w,
    rootClassName,
    getFieldsClassName(unionClass.name, suffix),
    unionClass.fields,
  );

  final baseFieldNames = unionClass.fields.map((f) => f.name).toSet();
  final variants = unionClass.unionVariants ?? const <String, ParsedClass>{};
  final variantWrappers = <(ParsedClass, String)>[];
  for (final entry in variants.entries) {
    final variantClass = entry.value;
    final variantWrapper =
        '${getSingularName(variantClass.name, suffix)}FieldRefs';
    w.writeln();
    w.writeln(
      '  /// Narrows to the `${entry.key}` variant '
      '([${variantClass.name}]) — affine: null / no-op when this '
      '${unionClass.name} is a different variant.',
    );
    w.writeln('  $variantWrapper get as${capitalize(entry.key)} =>');
    w.writeln(
      '      $variantWrapper(inner.narrow($variantsName.${entry.key}));',
    );
    variantWrappers.add((variantClass, variantWrapper));
  }
  w.writeln('}');
  w.writeln();
  for (final (cls, name) in pending) {
    emitObjectWrapper(w, emitted, rootClassName, cls, name, suffix);
  }
  for (final (cls, name) in variantWrappers) {
    _emitVariantWrapper(
      w,
      emitted,
      rootClassName,
      cls,
      baseFieldNames,
      name,
      suffix,
    );
  }
}

/// A union-variant wrapper: only the fields the variant adds over its base.
void _emitVariantWrapper(
  StringBuffer w,
  Set<String> emitted,
  String rootClassName,
  ParsedClass variantClass,
  Set<String> baseFieldNames,
  String wrapperName,
  String suffix,
) {
  if (!emitted.add(wrapperName)) return;
  _emitWrapperHeader(
    w,
    rootClassName,
    variantClass.name,
    wrapperName,
    'Field references for a [${variantClass.name}] within [$rootClassName].',
  );
  final pending = _emitLeafGetters(
    w,
    rootClassName,
    getFieldsClassName(variantClass.name, suffix),
    variantClass.fields.where((f) => !baseFieldNames.contains(f.name)),
  );
  w.writeln('}');
  w.writeln();
  for (final (cls, name) in pending) {
    emitObjectWrapper(w, emitted, rootClassName, cls, name, suffix);
  }
}

/// Emits, onto the root `<Root>Fields` class, a `static` navigator per list
/// field at every depth. Each navigator takes a `<Accessor>Ref` record of
/// client-id strings and returns a `<Accessor>FieldRefs` wrapper. The
/// `<Accessor>Ref` typedefs are appended after the class via [typedefs].
void generateNestedNavigators({
  required StringBuffer buffer,
  required StringBuffer wrappers,
  required StringBuffer typedefs,
  required Set<String> emittedWrappers,
  required Set<String> emittedRefs,
  required String rootClassName,
  required ParsedClass currentClass,
  required List<String> pathSegs,
  required List<ParsedClass> ancestorClasses,
  required String suffix,
}) {
  for (final field in currentClass.fields.where(
    (f) => f.isList && f.nestedClass != null,
  )) {
    final itemClass = field.nestedClass!;
    final navName = uncapitalize(_singularizeField(field.name));
    final segs = [...pathSegs, navName];
    final segClasses = [...ancestorClasses, itemClass];
    final refType = _refTypeName(navName);
    final wrapperName = wrapperClassName(navName);
    final matcher = '(x) => x.clientId == at.$navName';

    if (emittedRefs.add(refType)) {
      final pairs = [
        for (var i = 0; i < segs.length; i++)
          '`${segs[i]}` = a `${segClasses[i].name}.clientId`',
      ].join(', ');
      typedefs.writeln(
        '/// Identifies one `${field.name}` row by its clientId path: $pairs.',
      );
      typedefs.writeln(
        "/// Build it from your row objects, e.g. "
        "`(${segs.map((s) => '$s: …').join(', ')})`.",
      );
      typedefs.writeln('typedef $refType = ${_recordType(segs)};');
    }

    final navDoc =
        '  /// Field references for the `${field.name}` row identified by '
        '[at].\n'
        '  /// Affine — reads null / writes are a no-op if that row no longer '
        'exists.';

    if (pathSegs.isEmpty) {
      buffer.writeln();
      buffer.writeln(navDoc);
      buffer.writeln('  static $wrapperName $navName($refType at) =>');
      buffer.writeln(
        '      $wrapperName(${field.name}.at(at.$navName, $matcher));',
      );
    } else {
      final parentSeg = pathSegs.last;
      final parentClass = ancestorClasses.last;
      final parentFieldsName = getFieldsClassName(parentClass.name, suffix);
      final listAccessorName = '$parentSeg${capitalize(field.name)}';
      final parentArgs = pathSegs.map((s) => '$s: at.$s').join(', ');
      buffer.writeln();
      buffer.writeln(
        '  /// The `${field.name}` list on the `$parentSeg` row [at] '
        'addresses.',
      );
      buffer.writeln(
        '  static FieldRef<$rootClassName, List<${itemClass.name}>> '
        '$listAccessorName(${_refTypeName(parentSeg)} at) =>',
      );
      buffer.writeln(
        '      $parentSeg(at).then($parentFieldsName.${field.name});',
      );
      buffer.writeln();
      buffer.writeln(navDoc);
      buffer.writeln('  static $wrapperName $navName($refType at) =>');
      buffer.writeln(
        '      $wrapperName($listAccessorName(($parentArgs)).at(at.$navName, $matcher));',
      );
    }

    if (itemClass.isUnion) {
      _emitUnionWrapper(
        wrappers,
        emittedWrappers,
        rootClassName,
        itemClass,
        wrapperName,
        suffix,
      );
    } else {
      emitObjectWrapper(
        wrappers,
        emittedWrappers,
        rootClassName,
        itemClass,
        wrapperName,
        suffix,
      );
    }

    generateNestedNavigators(
      buffer: buffer,
      wrappers: wrappers,
      typedefs: typedefs,
      emittedWrappers: emittedWrappers,
      emittedRefs: emittedRefs,
      rootClassName: rootClassName,
      currentClass: itemClass,
      pathSegs: segs,
      ancestorClasses: [...ancestorClasses, itemClass],
      suffix: suffix,
    );
  }
}
