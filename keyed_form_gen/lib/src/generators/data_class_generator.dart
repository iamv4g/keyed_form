import '../models/schema_model.dart';

class DataClassGenerator {
  const DataClassGenerator();

  String generate(
    ParsedClass parsedClass, {
    List<ParsedClass> allClasses = const [],
    String suffix = 'Schema',
  }) {
    if (parsedClass.isUnion) {
      return _generateUnionBaseClass(
        parsedClass,
        allClasses: allClasses,
        suffix: suffix,
      );
    }
    if (parsedClass.unionBaseClass != null) {
      return _generateUnionVariantClass(
        parsedClass,
        allClasses: allClasses,
        suffix: suffix,
      );
    }
    return _generateNormalClass(
      parsedClass,
      allClasses: allClasses,
      suffix: suffix,
    );
  }

  String _generateUnionBaseClass(
    ParsedClass parsedClass, {
    List<ParsedClass> allClasses = const [],
    String suffix = 'Schema',
  }) {
    final buffer = StringBuffer();
    final name = parsedClass.name;
    final disc = parsedClass.unionDiscriminator!;

    final allFields = <_FieldDef>[];
    if (parsedClass.isListItem) {
      allFields.add(
        _FieldDef(
          name: 'clientId',
          type: 'String',
          isRequired: true,
          isClientId: true,
        ),
      );
    }
    for (final f in parsedClass.fields) {
      allFields.add(
        _FieldDef(
          name: f.name,
          type: f.dartType,
          defaultValue: f.defaultValue,
          isRequired:
              !f.isNullable &&
              f.defaultValue == null &&
              !f.isOptional &&
              !f.dartType.endsWith('?'),
        ),
      );
    }

    _writeUnionBaseCopyWith(
      buffer,
      name,
      allFields,
      parsedClass.unionVariants ?? const {},
    );

    // 1. sealed class
    final sealedImpl = parsedClass.isListItem ? ' implements KeyedRow' : '';
    buffer.writeln('sealed class $name$sealedImpl {');
    buffer.writeln('  const $name({');
    for (final f in allFields) {
      if (f.isRequired) {
        buffer.writeln('    required this.${f.name},');
      } else if (f.defaultValue != null) {
        buffer.writeln('    this.${f.name} = ${f.defaultValue},');
      } else {
        buffer.writeln('    this.${f.name},');
      }
    }
    buffer.writeln('  });');
    buffer.writeln();

    for (final f in allFields) {
      buffer.writeln('  final ${f.type} ${f.name};');
    }
    buffer.writeln();
    buffer.writeln('  String get $disc;');
    buffer.writeln();

    // copyWith — the XCopyWith interface + impl are emitted just before
    // this class (see _writeUnionBaseCopyWith); this is just the getter.
    buffer.writeln(
      '  ${name}CopyWith<$name> get copyWith => _${name}CopyWithImpl(this);',
    );
    buffer.writeln();

    // toMap
    buffer.writeln('  Map<String, Object?> toMap() => switch (this) {');
    if (parsedClass.unionVariants != null) {
      for (final v in parsedClass.unionVariants!.values) {
        buffer.writeln('    ${v.name} x => x.toMap(),');
      }
    }
    buffer.writeln('  };');
    buffer.writeln();

    // validate
    buffer.writeln('  FieldErrors<String> validate() => switch (this) {');
    if (parsedClass.unionVariants != null) {
      for (final v in parsedClass.unionVariants!.values) {
        buffer.writeln('    ${v.name} x => x.validate(),');
      }
    }
    buffer.writeln('  };');
    buffer.writeln();

    // validateAsync
    buffer.writeln(
      '  Future<FieldErrors<String>> validateAsync() => switch (this) {',
    );
    if (parsedClass.unionVariants != null) {
      for (final v in parsedClass.unionVariants!.values) {
        buffer.writeln('    ${v.name} x => x.validateAsync(),');
      }
    }
    buffer.writeln('  };');
    buffer.writeln();

    buffer.writeln('}');
    buffer.writeln();

    // Prisms container
    final prismsName = _getPrismsClassName(name, suffix);
    buffer.writeln('abstract final class $prismsName {');
    if (parsedClass.unionVariants != null) {
      for (final entry in parsedClass.unionVariants!.entries) {
        final variantKey = entry.key;
        final variantClass = entry.value;
        buffer.writeln(
          '  static final $variantKey = Prism<$name, ${variantClass.name}>.type();',
        );
      }
    }
    buffer.writeln('}');
    buffer.writeln();

    // Fields container
    final fieldsName = _getFieldsClassName(name, suffix);
    buffer.writeln('abstract final class $fieldsName {');

    for (final f in parsedClass.fields) {
      buffer.writeln(
        '  static Lens<$name, ${f.dartType}> get ${f.name} => Lens.of(',
      );
      buffer.writeln("    key: FieldKey.name('${f.name}'),");
      buffer.writeln('    get: (x) => x.${f.name},');
      buffer.writeln('    set: (x, v) => x.copyWith(${f.name}: v),');
      buffer.writeln('  );');
      buffer.writeln();
    }
    buffer.writeln('}');
    buffer.writeln();

    return buffer.toString();
  }

  String _generateUnionVariantClass(
    ParsedClass parsedClass, {
    List<ParsedClass> allClasses = const [],
    String suffix = 'Schema',
  }) {
    final buffer = StringBuffer();
    final name = parsedClass.name;
    final base = parsedClass.unionBaseClass!;
    final disc = base.unionDiscriminator!;
    final discVal = parsedClass.unionDiscriminatorValue!;
    final schemaName = parsedClass.schemaName;
    final schemaCall = parsedClass.isFunction ? '$schemaName()' : schemaName;

    final allFields = <_FieldDef>[];
    if (parsedClass.isListItem) {
      allFields.add(
        _FieldDef(
          name: 'clientId',
          type: 'String',
          isRequired: true,
          isClientId: true,
        ),
      );
    }
    for (final f in parsedClass.fields) {
      allFields.add(
        _FieldDef(
          name: f.name,
          type: f.dartType,
          defaultValue: f.defaultValue,
          isRequired:
              !f.isNullable &&
              f.defaultValue == null &&
              !f.isOptional &&
              !f.dartType.endsWith('?'),
        ),
      );
    }

    final baseFieldNames = base.fields.map((f) => f.name).toSet();
    if (base.isListItem) baseFieldNames.add('clientId');

    _writeCopyWithInterfaceAndImpl(
      buffer,
      name,
      allFields,
      implementsInterface: '${base.name}CopyWith',
    );

    buffer.writeln('class $name extends ${base.name} {');
    buffer.writeln('  const $name({');
    for (final f in allFields) {
      final isSuper = baseFieldNames.contains(f.name);
      final prefix = isSuper ? 'super.' : 'this.';
      if (f.isRequired) {
        buffer.writeln('    required $prefix${f.name},');
      } else if (f.defaultValue != null) {
        buffer.writeln('    $prefix${f.name} = ${f.defaultValue},');
      } else {
        buffer.writeln('    $prefix${f.name},');
      }
    }
    buffer.writeln('  });');
    buffer.writeln();

    for (final f in allFields) {
      if (!baseFieldNames.contains(f.name)) {
        buffer.writeln('  final ${f.type} ${f.name};');
      } else {
        final baseField = base.fields
            .where((bf) => bf.name == f.name)
            .firstOrNull;
        if (baseField != null &&
            baseField.dartType != f.type &&
            baseField.dartType == '${f.type}?') {
          buffer.writeln('  @override');
          buffer.writeln('  ${f.type} get ${f.name} => super.${f.name}!;');
          buffer.writeln();
        }
      }
    }
    if (allFields.any((f) => !baseFieldNames.contains(f.name))) {
      buffer.writeln();
    }

    buffer.writeln('  @override');
    buffer.writeln("  String get $disc => '$discVal';");
    buffer.writeln();

    // Factory create method
    buffer.writeln(
      '  /// Creates a new [$name] instance with auto-generated UUID if needed.',
    );
    buffer.writeln('  factory $name.create({');
    for (final f in allFields) {
      if (f.isClientId) {
        buffer.writeln('    String? clientId,');
      } else {
        final nullableType = f.type.endsWith('?') ? f.type : '${f.type}?';
        buffer.writeln('    $nullableType ${f.name},');
      }
    }
    buffer.writeln('  }) {');
    buffer.writeln('    return $name(');
    for (final f in allFields) {
      if (f.isClientId) {
        buffer.writeln('      clientId: clientId ?? const Uuid().v4(),');
      } else if (f.defaultValue != null) {
        buffer.writeln('      ${f.name}: ${f.name} ?? ${f.defaultValue},');
      } else {
        buffer.writeln('      ${f.name}: ${f.name},');
      }
    }
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();

    // copyWith — the XCopyWith interface + impl are emitted just before
    // this class (see _writeCopyWithInterfaceAndImpl); this is just the
    // (overriding) getter.
    buffer.writeln('  @override');
    buffer.writeln(
      '  ${name}CopyWith<$name> get copyWith => _${name}CopyWithImpl(this);',
    );
    buffer.writeln();

    // toMap method
    buffer.writeln('  @override');
    buffer.writeln('  Map<String, Object?> toMap() => {');
    buffer.writeln("    '$disc': $disc,");
    if (parsedClass.isListItem) {
      buffer.writeln("    'clientId': clientId,");
    }
    for (final f in parsedClass.fields) {
      if (f.isList && f.nestedClass != null) {
        buffer.writeln(
          "    '${f.name}': ${f.name}.map((e) => e.toMap()).toList(),",
        );
      } else if (f.isNestedObject && f.nestedClass != null) {
        buffer.writeln("    '${f.name}': ${f.name}?.toMap(),");
      } else {
        buffer.writeln("    '${f.name}': ${f.name},");
      }
    }
    buffer.writeln('  };');
    buffer.writeln();

    // Validation methods
    if (schemaName.isNotEmpty) {
      buffer.writeln('  @override');
      buffer.writeln(
        '  FieldErrors<String> validate() => $schemaCall.validateMap(toMap());',
      );
      buffer.writeln();
      buffer.writeln('  @override');
      buffer.writeln(
        '  Future<FieldErrors<String>> validateAsync() => $schemaCall.validateMapAsync(toMap());',
      );
      buffer.writeln();
    }

    // operator ==
    _writeEquality(buffer, name, allFields);

    // hashCode
    _writeHashCode(buffer, allFields);

    buffer.writeln('}');
    buffer.writeln();

    // Fields container
    final fieldsName = _getFieldsClassName(name, suffix);
    buffer.writeln('abstract final class $fieldsName {');

    for (final f in parsedClass.fields) {
      buffer.writeln(
        '  static Lens<$name, ${f.dartType}> get ${f.name} => Lens.of(',
      );
      buffer.writeln("    key: FieldKey.name('${f.name}'),");
      buffer.writeln('    get: (x) => x.${f.name},');
      buffer.writeln('    set: (x, v) => x.copyWith(${f.name}: v),');
      buffer.writeln('  );');
      buffer.writeln();
    }
    buffer.writeln('}');
    buffer.writeln();

    return buffer.toString();
  }

  String _generateNormalClass(
    ParsedClass parsedClass, {
    List<ParsedClass> allClasses = const [],
    String suffix = 'Schema',
  }) {
    final buffer = StringBuffer();
    final name = parsedClass.name;
    final schemaName = parsedClass.schemaName;
    final schemaCall = parsedClass.isFunction ? '$schemaName()' : schemaName;

    // Header parameters for Primary Constructor: class Name({ ... })
    final allFields = <_FieldDef>[];

    if (parsedClass.isListItem) {
      allFields.add(
        _FieldDef(
          name: 'clientId',
          type: 'String',
          isRequired: true,
          isClientId: true,
        ),
      );
    }

    for (final f in parsedClass.fields) {
      allFields.add(
        _FieldDef(
          name: f.name,
          type: f.dartType,
          defaultValue: f.defaultValue,
          isRequired:
              !f.isNullable &&
              f.defaultValue == null &&
              !f.isOptional &&
              !f.dartType.endsWith('?'),
        ),
      );
    }

    _writeCopyWithInterfaceAndImpl(buffer, name, allFields);

    // 1. Class & Const Constructor declaration
    final classImpl = parsedClass.isListItem ? ' implements KeyedRow' : '';
    buffer.writeln('class $name$classImpl {');
    buffer.writeln('  const $name({');
    for (final f in allFields) {
      if (f.isRequired) {
        buffer.writeln('    required this.${f.name},');
      } else if (f.defaultValue != null) {
        buffer.writeln('    this.${f.name} = ${f.defaultValue},');
      } else {
        buffer.writeln('    this.${f.name},');
      }
    }
    buffer.writeln('  });');
    buffer.writeln();

    // Fields declaration
    for (final f in allFields) {
      buffer.writeln('  final ${f.type} ${f.name};');
    }
    buffer.writeln();

    // 2. Factory create method
    buffer.writeln(
      '  /// Creates a new [$name] instance with auto-generated UUID if needed.',
    );
    buffer.writeln('  factory $name.create({');
    for (final f in allFields) {
      if (f.isClientId) {
        buffer.writeln('    String? clientId,');
      } else {
        final nullableType = f.type.endsWith('?') ? f.type : '${f.type}?';
        buffer.writeln('    $nullableType ${f.name},');
      }
    }
    buffer.writeln('  }) {');
    buffer.writeln('    return $name(');
    for (final f in allFields) {
      if (f.isClientId) {
        buffer.writeln('      clientId: clientId ?? const Uuid().v4(),');
      } else if (f.defaultValue != null) {
        buffer.writeln('      ${f.name}: ${f.name} ?? ${f.defaultValue},');
      } else {
        buffer.writeln('      ${f.name}: ${f.name},');
      }
    }
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();

    // 3. copyWith — the XCopyWith interface + impl are emitted just before
    // this class (see _writeCopyWithInterfaceAndImpl); this is just the
    // getter.
    buffer.writeln(
      '  ${name}CopyWith<$name> get copyWith => _${name}CopyWithImpl(this);',
    );
    buffer.writeln();

    // 4. toMap method
    buffer.writeln('  /// Converts this [$name] to a Map representation.');
    buffer.writeln('  Map<String, Object?> toMap() => {');
    if (parsedClass.isListItem) {
      buffer.writeln("    'clientId': clientId,");
    }
    for (final f in parsedClass.fields) {
      if (f.isList && f.nestedClass != null) {
        buffer.writeln(
          "    '${f.name}': ${f.name}.map((e) => e.toMap()).toList(),",
        );
      } else if (f.isNestedObject && f.nestedClass != null) {
        buffer.writeln("    '${f.name}': ${f.name}?.toMap(),");
      } else {
        buffer.writeln("    '${f.name}': ${f.name},");
      }
    }
    buffer.writeln('  };');
    buffer.writeln();

    // 5. Validation methods (for classes with a schema)
    if (schemaName.isNotEmpty) {
      buffer.writeln(
        '  /// Synchronously validates this [$name] against its schema.',
      );
      buffer.writeln(
        '  FieldErrors<String> validate() => $schemaCall.validateMap(toMap());',
      );
      buffer.writeln();
      buffer.writeln(
        '  /// Asynchronously validates this [$name] against its schema.',
      );
      buffer.writeln(
        '  Future<FieldErrors<String>> validateAsync() => $schemaCall.validateMapAsync(toMap());',
      );
      buffer.writeln();
      buffer.writeln(
        '  /// Static validator function for [$name], suitable for Riverpod or callbacks.',
      );
      buffer.writeln(
        '  static FieldErrors<String> validateData($name schema) => schema.validate();',
      );
      buffer.writeln();
      buffer.writeln('  /// Static async validator function for [$name].');
      buffer.writeln(
        '  static Future<FieldErrors<String>> validateDataAsync($name schema) => schema.validateAsync();',
      );
      buffer.writeln();
    }

    // 6. operator ==
    _writeEquality(buffer, name, allFields);

    // 7. hashCode
    _writeHashCode(buffer, allFields);

    // End class
    buffer.writeln('}');
    buffer.writeln();

    // 8. Generate Fields container class
    final fieldsName = _getFieldsClassName(name, suffix);
    final wrappers = StringBuffer();
    final typedefs = StringBuffer();
    final emittedWrappers = <String>{};
    final emittedRefs = <String>{};
    buffer.writeln('abstract final class $fieldsName {');

    for (final f in parsedClass.fields) {
      // On the root, a non-list nested-object field is reached through its
      // own `<Field>FieldRefs` wrapper (e.g. `TourInfoBuilderFields.info.name`)
      // rather than the raw segment lens.
      if (!parsedClass.isListItem &&
          f.isNestedObject &&
          f.nestedClass != null) {
        final wrapperName = _wrapperClassName(f.name);
        final refined = (f.isNullable || f.isOptional) ? '.whenPresent()' : '';
        buffer.writeln(
          '  /// Field references for the nested `${f.name}` object — '
          '`$fieldsName.${f.name}.<field>`. Also a lens to the whole '
          '`${f.nestedClass!.name}` for `patch`.',
        );
        buffer.writeln('  static $wrapperName get ${f.name} => $wrapperName(');
        buffer.writeln('    Lens.of(');
        buffer.writeln("      key: FieldKey.name('${f.name}'),");
        buffer.writeln('      get: (x) => x.${f.name},');
        buffer.writeln('      set: (x, v) => x.copyWith(${f.name}: v),');
        buffer.writeln('    )$refined,');
        buffer.writeln('  );');
        buffer.writeln();
        _emitObjectWrapper(
          wrappers,
          emittedWrappers,
          name,
          f.nestedClass!,
          wrapperName,
          suffix,
        );
        continue;
      }
      buffer.writeln(
        '  static Lens<$name, ${f.dartType}> get ${f.name} => Lens.of(',
      );
      buffer.writeln("    key: FieldKey.name('${f.name}'),");
      buffer.writeln('    get: (x) => x.${f.name},');
      buffer.writeln('    set: (x, v) => x.copyWith(${f.name}: v),');
      buffer.writeln('  );');
      buffer.writeln();
    }

    if (!parsedClass.isListItem) {
      _generateNestedNavigators(
        buffer: buffer,
        wrappers: wrappers,
        typedefs: typedefs,
        emittedWrappers: emittedWrappers,
        emittedRefs: emittedRefs,
        rootClassName: name,
        currentClass: parsedClass,
        pathSegs: const [],
        ancestorClasses: const [],
        suffix: suffix,
      );
    }

    buffer.writeln('}');
    buffer.writeln();

    // `<Accessor>Ref` record typedefs, then the FieldRef wrapper classes.
    buffer.write(typedefs);
    if (typedefs.isNotEmpty) buffer.writeln();
    buffer.write(wrappers);

    return buffer.toString();
  }

  /// Getter names on a wrapper must not shadow the [AffineLens]/`Object` API
  /// the wrapper inherits.
  static const _reservedWrapperNames = <String>{
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

  String _wrapperClassName(String accessorName) =>
      '${_capitalize(accessorName)}FieldRefs';

  String _refTypeName(String accessorName) => '${_capitalize(accessorName)}Ref';

  /// Emits one leaf getter per scalar / nested-object field of [fieldsName]
  /// onto a wrapper whose lens is `_self` (an `AffineLens<Root, Struct>`).
  /// Returns the nested-object sub-wrappers still to be emitted — the caller
  /// must emit them *after* closing the current class (Dart has no nested
  /// class declarations).
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
        final nestedWrapper = _wrapperClassName(f.name);
        final refined = (f.isNullable || f.isOptional) ? '.whenPresent()' : '';
        w.writeln(
          '  /// Field references for the nested `${f.name}` object.',
        );
        w.writeln('  $nestedWrapper get ${f.name} =>');
        w.writeln(
          '      $nestedWrapper(_self.then($fieldsName.${f.name})$refined);',
        );
        pending.add((f.nestedClass!, nestedWrapper));
      } else {
        w.writeln('  /// `FieldRef` to `$fieldsName.${f.name}`.');
        w.writeln('  FieldRef<$rootClassName, ${f.dartType}> get ${f.name} =>');
        w.writeln('      _self.then($fieldsName.${f.name});');
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
      'final class $wrapperName extends AffineLens<$rootClassName, $structName> {',
    );
    w.writeln('  $wrapperName(this._self);');
    w.writeln();
    w.writeln('  final AffineLens<$rootClassName, $structName> _self;');
    w.writeln();
    w.writeln('  @override');
    w.writeln('  FieldKey get key => _self.key;');
    w.writeln();
    w.writeln('  @override');
    w.writeln('  Opt<$structName> find($rootClassName root) => _self.find(root);');
    w.writeln();
    w.writeln('  @override');
    w.writeln(
      '  $rootClassName set($rootClassName root, $structName value) => '
      '_self.set(root, value);',
    );
  }

  /// A plain (non-union) struct wrapper: `AffineLens<Root, Struct>` + one
  /// leaf getter per field. Recurses for nested-object fields.
  void _emitObjectWrapper(
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
      _getFieldsClassName(structClass.name, suffix),
      structClass.fields,
    );
    w.writeln('}');
    w.writeln();
    for (final (cls, name) in pending) {
      _emitObjectWrapper(w, emitted, rootClassName, cls, name, suffix);
    }
  }

  /// A discriminated-union wrapper: common-field getters plus `.asVariant`
  /// getters that narrow (via prism) into per-variant sub-wrappers.
  void _emitUnionWrapper(
    StringBuffer w,
    Set<String> emitted,
    String rootClassName,
    ParsedClass unionClass,
    String wrapperName,
    String suffix,
  ) {
    if (!emitted.add(wrapperName)) return;
    final prismsName = _getPrismsClassName(unionClass.name, suffix);
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
      _getFieldsClassName(unionClass.name, suffix),
      unionClass.fields,
    );

    final baseFieldNames = unionClass.fields.map((f) => f.name).toSet();
    final variants =
        unionClass.unionVariants ?? const <String, ParsedClass>{};
    final variantWrappers = <(ParsedClass, String)>[];
    for (final entry in variants.entries) {
      final variantClass = entry.value;
      final variantWrapper =
          '${_getSingularName(variantClass.name, suffix)}FieldRefs';
      w.writeln();
      w.writeln(
        '  /// Narrows to the `${entry.key}` variant '
        '([${variantClass.name}]) — affine: null / no-op when this '
        '${unionClass.name} is a different variant.',
      );
      w.writeln('  $variantWrapper get as${_capitalize(entry.key)} =>');
      w.writeln(
        '      $variantWrapper(_self.narrow($prismsName.${entry.key}));',
      );
      variantWrappers.add((variantClass, variantWrapper));
    }
    w.writeln('}');
    w.writeln();
    for (final (cls, name) in pending) {
      _emitObjectWrapper(w, emitted, rootClassName, cls, name, suffix);
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
      _getFieldsClassName(variantClass.name, suffix),
      variantClass.fields.where((f) => !baseFieldNames.contains(f.name)),
    );
    w.writeln('}');
    w.writeln();
    for (final (cls, name) in pending) {
      _emitObjectWrapper(w, emitted, rootClassName, cls, name, suffix);
    }
  }

  /// Emits, onto the root `<Root>Fields` class, a `static` navigator per list
  /// field at every depth. Each navigator takes a `<Accessor>Ref` record of
  /// client-id strings and returns a `<Accessor>FieldRefs` wrapper. The
  /// `<Accessor>Ref` typedefs are appended after the class via [typedefs].
  void _generateNestedNavigators({
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
      final navName = _uncapitalize(_singularizeField(field.name));
      final segs = [...pathSegs, navName];
      final segClasses = [...ancestorClasses, itemClass];
      final refType = _refTypeName(navName);
      final wrapperName = _wrapperClassName(navName);
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
        final parentFieldsName = _getFieldsClassName(parentClass.name, suffix);
        final listAccessorName = '$parentSeg${_capitalize(field.name)}';
        final parentArgs = pathSegs.map((s) => '$s: at.$s').join(', ');
        buffer.writeln();
        buffer.writeln(
          '  /// The `${field.name}` list on the `$parentSeg` row [at] '
          'addresses.',
        );
        buffer.writeln(
          '  static AffineLens<$rootClassName, List<${itemClass.name}>> '
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
        _emitObjectWrapper(
          wrappers,
          emittedWrappers,
          rootClassName,
          itemClass,
          wrapperName,
          suffix,
        );
      }

      _generateNestedNavigators(
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

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _uncapitalize(String s) =>
      s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);

  String _getSingularName(String name, String suffix) {
    if (name.length > suffix.length && name.endsWith(suffix)) {
      return name.substring(0, name.length - suffix.length);
    }
    if (name.length > 'Schema'.length && name.endsWith('Schema')) {
      return name.substring(0, name.length - 'Schema'.length);
    }
    return name;
  }

  String _getFieldsClassName(String name, String suffix) {
    if (name.length > suffix.length && name.endsWith(suffix)) {
      return '${name.substring(0, name.length - suffix.length)}Fields';
    }
    if (name.length > 'Schema'.length && name.endsWith('Schema')) {
      return '${name.substring(0, name.length - 'Schema'.length)}Fields';
    }
    return '${name}Fields';
  }

  String _getPrismsClassName(String name, String suffix) {
    if (name.length > suffix.length && name.endsWith(suffix)) {
      return '${name.substring(0, name.length - suffix.length)}Prisms';
    }
    if (name.length > 'Schema'.length && name.endsWith('Schema')) {
      return '${name.substring(0, name.length - 'Schema'.length)}Prisms';
    }
    return '${name}Prisms';
  }
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
String _nullableParamType(String type) =>
    type.endsWith('?') ? type : '$type?';

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
bool _needsSentinel(_FieldDef f) => f.type.endsWith('?');

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
void _writeCopyWithInterfaceAndImpl(
  StringBuffer buffer,
  String name,
  List<_FieldDef> allFields, {
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
/// [_writeCopyWithInterfaceAndImpl], but the impl's `call()` resolves each
/// param at the base level *first*, then forwards a concrete (already-
/// resolved) value to whichever variant `this` actually is — so "not
/// passed at the base" stays "not passed" once relayed to the variant's
/// own copyWith, rather than being flattened into an explicit `null`.
void _writeUnionBaseCopyWith(
  StringBuffer buffer,
  String name,
  List<_FieldDef> allFields,
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
void _writeEquality(
  StringBuffer buffer,
  String name,
  List<_FieldDef> allFields,
) {
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
/// [_writeEquality]'s per-field equality choice (`List<...>` →
/// `Object.hashAll`, `Map<...>` → the order-independent `_mapHash`).
void _writeHashCode(StringBuffer buffer, List<_FieldDef> allFields) {
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

class _FieldDef {
  _FieldDef({
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
