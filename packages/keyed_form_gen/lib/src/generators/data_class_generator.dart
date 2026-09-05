import '../models/schema_model.dart';
import '../naming.dart';
import 'optics_wrapper_generator.dart';
import 'value_semantics_writer.dart';

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

    final allFields = <FieldDef>[];
    if (parsedClass.isListItem) {
      allFields.add(
        FieldDef(
          name: 'clientId',
          type: 'String',
          isRequired: true,
          isClientId: true,
        ),
      );
    }
    for (final f in parsedClass.fields) {
      allFields.add(
        FieldDef(
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

    writeUnionBaseCopyWith(
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
    // this class (see writeUnionBaseCopyWith); this is just the getter.
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
    final prismsName = getPrismsClassName(name, suffix);
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
    final fieldsName = getFieldsClassName(name, suffix);
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

    final allFields = <FieldDef>[];
    if (parsedClass.isListItem) {
      allFields.add(
        FieldDef(
          name: 'clientId',
          type: 'String',
          isRequired: true,
          isClientId: true,
        ),
      );
    }
    for (final f in parsedClass.fields) {
      allFields.add(
        FieldDef(
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

    writeCopyWithInterfaceAndImpl(
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
    // this class (see writeCopyWithInterfaceAndImpl); this is just the
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
    writeEquality(buffer, name, allFields);

    // hashCode
    writeHashCode(buffer, allFields);

    buffer.writeln('}');
    buffer.writeln();

    // Fields container
    final fieldsName = getFieldsClassName(name, suffix);
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
    final allFields = <FieldDef>[];

    if (parsedClass.isListItem) {
      allFields.add(
        FieldDef(
          name: 'clientId',
          type: 'String',
          isRequired: true,
          isClientId: true,
        ),
      );
    }

    for (final f in parsedClass.fields) {
      allFields.add(
        FieldDef(
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

    writeCopyWithInterfaceAndImpl(buffer, name, allFields);

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
    // this class (see writeCopyWithInterfaceAndImpl); this is just the
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
    writeEquality(buffer, name, allFields);

    // 7. hashCode
    writeHashCode(buffer, allFields);

    // End class
    buffer.writeln('}');
    buffer.writeln();

    // 8. Generate Fields container class
    final fieldsName = getFieldsClassName(name, suffix);
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
        final wrapperName = wrapperClassName(f.name);
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
        emitObjectWrapper(
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
      generateNestedNavigators(
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
}
