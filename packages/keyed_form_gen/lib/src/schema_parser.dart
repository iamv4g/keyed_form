import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import 'models/schema_model.dart';

class SchemaParser {
  const SchemaParser();

  List<ParsedClass> parseElement(
    Element element,
    AstNode node, {
    String suffix = 'Schema',
    CompilationUnit? compilationUnit,
  }) {
    // Determine default root class name (can be overridden by kz.object(className: ...))
    final schemaName = element.name ?? 'schema';
    final rootClassName = _inferClassName(schemaName, suffix);
    final isFunction =
        element is TopLevelFunctionElement ||
        element is ExecutableElement ||
        node is FunctionDeclaration;

    // Find the initializer/return expression
    Expression? initExpr;
    if (node is VariableDeclaration) {
      initExpr = node.initializer;
    } else if (node is TopLevelVariableDeclaration) {
      for (final variable in node.variables.variables) {
        if (variable.name.lexeme == schemaName) {
          initExpr = variable.initializer;
          break;
        }
      }
    } else if (node is FunctionDeclaration) {
      final body = node.functionExpression.body;
      if (body is ExpressionFunctionBody) {
        initExpr = body.expression;
      } else if (body is BlockFunctionBody) {
        for (final statement in body.block.statements) {
          if (statement is ReturnStatement) {
            initExpr = statement.expression;
            break;
          }
        }
      }
    }

    if (initExpr == null) {
      return [];
    }

    final parsedClasses = <ParsedClass>[];
    _parseObjectExpression(
      initExpr,
      rootClassName,
      schemaName,
      isListItem: false,
      isFunction: isFunction,
      outClasses: parsedClasses,
      suffix: suffix,
      compilationUnit: compilationUnit,
    );

    if (parsedClasses.isNotEmpty) {
      _updateDescendantAncestors(parsedClasses.first, [], parsedClasses);
    }

    return parsedClasses;
  }

  ParsedClass? _parseObjectExpression(
    Expression expr,
    String className,
    String schemaName, {
    required bool isListItem,
    bool isFunction = false,
    required List<ParsedClass> outClasses,
    ParsedClass? parentClass,
    String? listFieldNameInParent,
    String suffix = 'Schema',
    CompilationUnit? compilationUnit,
  }) {
    // Unroll method chains like ks.object({...}).refine(...)
    final unrolled = _unrollExpression(expr);
    final baseExpr = unrolled.base;
    final chainMethods = unrolled.methodCalls;

    if (baseExpr is MethodInvocation &&
        baseExpr.methodName.name == 'discriminatedUnion') {
      return _parseDiscriminatedUnionExpression(
        baseExpr,
        className,
        schemaName,
        isListItem: isListItem,
        isFunction: isFunction,
        outClasses: outClasses,
        parentClass: parentClass,
        listFieldNameInParent: listFieldNameInParent,
        suffix: suffix,
        compilationUnit: compilationUnit,
      );
    }

    if (baseExpr is! MethodInvocation || baseExpr.methodName.name != 'object') {
      // If expr is a reference to a function or variable schema in compilationUnit
      final refName = baseExpr is MethodInvocation
          ? baseExpr.methodName.name
          : (baseExpr is SimpleIdentifier ? baseExpr.name : null);
      if (refName != null && compilationUnit != null) {
        for (final decl in compilationUnit.declarations) {
          if (decl is FunctionDeclaration && decl.name.lexeme == refName) {
            final body = decl.functionExpression.body;
            Expression? targetExpr;
            if (body is ExpressionFunctionBody) targetExpr = body.expression;
            if (body is BlockFunctionBody) {
              for (final s in body.block.statements) {
                if (s is ReturnStatement) {
                  targetExpr = s.expression;
                  break;
                }
              }
            }
            if (targetExpr != null) {
              return _parseObjectExpression(
                targetExpr,
                _inferClassName(refName, suffix),
                refName,
                isListItem: isListItem,
                isFunction: true,
                outClasses: outClasses,
                parentClass: parentClass,
                listFieldNameInParent: listFieldNameInParent,
                suffix: suffix,
                compilationUnit: compilationUnit,
              );
            }
          } else if (decl is TopLevelVariableDeclaration) {
            for (final v in decl.variables.variables) {
              if (v.name.lexeme == refName && v.initializer != null) {
                return _parseObjectExpression(
                  v.initializer!,
                  _inferClassName(refName, suffix),
                  refName,
                  isListItem: isListItem,
                  isFunction: false,
                  outClasses: outClasses,
                  parentClass: parentClass,
                  listFieldNameInParent: listFieldNameInParent,
                  suffix: suffix,
                  compilationUnit: compilationUnit,
                );
              }
            }
          }
        }
      }
      return null;
    }

    final args = baseExpr.argumentList.arguments;
    String? explicitClassName;
    SetOrMapLiteral? mapLiteral;

    for (final arg in args) {
      if (arg is SetOrMapLiteral) {
        mapLiteral = arg;
      } else if (arg is NamedExpression && arg.name.label.name == 'className') {
        if (arg.expression is SimpleStringLiteral) {
          explicitClassName = (arg.expression as SimpleStringLiteral).value;
        }
      }
    }

    if (mapLiteral == null) {
      return null;
    }

    if (explicitClassName != null) {
      if (!explicitClassName.endsWith(suffix)) {
        explicitClassName = '$explicitClassName$suffix';
      }
    }

    final finalClassName = explicitClassName ?? className;

    // Check if this class was already parsed (deduplication)
    final existingIndex = outClasses.indexWhere(
      (c) => c.name == finalClassName,
    );
    if (existingIndex != -1) {
      return outClasses[existingIndex];
    }

    final ancestorListItems = <ParsedClass>[];
    if (parentClass != null) {
      ancestorListItems.addAll(parentClass.ancestorListItems);
      final itemToAdd =
          parentClass.unionBaseClass ??
          (parentClass.isListItem ? parentClass : null);
      if (itemToAdd != null &&
          !ancestorListItems.any((a) => a.name == itemToAdd.name)) {
        ancestorListItems.add(itemToAdd);
      }
    }

    final fields = <ParsedField>[];

    final parsedClass = ParsedClass(
      name: finalClassName,
      schemaName: schemaName,
      isListItem: isListItem,
      isFunction: isFunction,
      fields: fields,
      parentClass: parentClass,
      listFieldNameInParent: listFieldNameInParent,
      ancestorListItems: ancestorListItems,
      refinements: [],
    );
    outClasses.add(parsedClass);

    for (final entry in mapLiteral.elements) {
      if (entry is! MapLiteralEntry) continue;
      final keyExpr = entry.key;
      final valExpr = entry.value;

      String fieldName = '';
      if (keyExpr is SimpleStringLiteral) {
        fieldName = keyExpr.value;
      } else {
        continue;
      }

      final parsedField = _parseField(
        fieldName,
        valExpr,
        parentClass: parsedClass,
        outClasses: outClasses,
        suffix: suffix,
        compilationUnit: compilationUnit,
      );
      if (parsedField != null) {
        fields.add(parsedField);
      }
    }

    // Parse refinements from chainMethods
    for (final method in chainMethods) {
      if (method.methodName.name == 'refine') {
        final mArgs = method.argumentList.arguments;
        if (mArgs.isNotEmpty) {
          String? message;
          String? path;
          for (final a in mArgs) {
            if (a is NamedExpression) {
              final label = a.name.label.name;
              if (label == 'error') {
                final expr = a.expression;
                if (expr is MethodInvocation &&
                    expr.methodName.name == 'text') {
                  final firstArg = expr.argumentList.arguments.firstOrNull;
                  if (firstArg is SimpleStringLiteral) {
                    message = firstArg.value;
                  }
                }
              } else if (label == 'path' &&
                  a.expression is SimpleStringLiteral) {
                path = (a.expression as SimpleStringLiteral).value;
              }
            }
          }
          if (message != null && path != null) {
            parsedClass.refinements.add((
              testCode: mArgs.first.toSource(),
              message: message,
              path: path,
            ));
          }
        }
      }
    }

    return parsedClass;
  }

  ParsedField? _parseField(
    String fieldName,
    Expression expr, {
    required ParsedClass parentClass,
    required List<ParsedClass> outClasses,
    String suffix = 'Schema',
    CompilationUnit? compilationUnit,
  }) {
    final unrolled = _unrollExpression(expr);
    final baseExpr = unrolled.base;
    final chainMethods = unrolled.methodCalls;

    if (baseExpr is! MethodInvocation && baseExpr is! SimpleIdentifier) {
      return null;
    }

    final methodName = baseExpr is MethodInvocation
        ? baseExpr.methodName.name
        : (baseExpr as SimpleIdentifier).name;
    final rules = <String>[];
    bool isOptional = false;
    bool isNullable = false;
    String? defaultValue;

    for (final call in chainMethods) {
      final cName = call.methodName.name;
      rules.add(cName);
      if (cName == 'optional') {
        isOptional = true;
      } else if (cName == 'nullable') {
        isNullable = true;
      } else if (cName == 'defaultTo') {
        final args = call.argumentList.arguments;
        if (args.isNotEmpty) {
          defaultValue = args.first.toSource();
        }
      }
    }

    if (methodName == 'string') {
      final type = isNullable || (isOptional && defaultValue == null)
          ? 'String?'
          : 'String';
      return ParsedField(
        name: fieldName,
        dartType: type,
        isNullable: isNullable,
        isOptional: isOptional,
        defaultValue: defaultValue ?? (isNullable || isOptional ? null : "''"),
        rules: rules,
      );
    } else if (methodName == 'int') {
      final type = isNullable || isOptional || defaultValue == null
          ? 'int?'
          : 'int';
      return ParsedField(
        name: fieldName,
        dartType: type,
        isNullable: isNullable,
        isOptional: isOptional,
        defaultValue: defaultValue,
        rules: rules,
      );
    } else if (methodName == 'double') {
      final type = isNullable || isOptional || defaultValue == null
          ? 'double?'
          : 'double';
      return ParsedField(
        name: fieldName,
        dartType: type,
        isNullable: isNullable,
        isOptional: isOptional,
        defaultValue: defaultValue,
        rules: rules,
      );
    } else if (methodName == 'number' || methodName == 'num') {
      final type = isNullable || isOptional || defaultValue == null
          ? 'num?'
          : 'num';
      return ParsedField(
        name: fieldName,
        dartType: type,
        isNullable: isNullable,
        isOptional: isOptional,
        defaultValue: defaultValue,
        rules: rules,
      );
    } else if (methodName == 'boolean') {
      final type = isNullable ? 'bool?' : 'bool';
      return ParsedField(
        name: fieldName,
        dartType: type,
        isNullable: isNullable,
        isOptional: isOptional,
        defaultValue: defaultValue ?? (isNullable ? null : 'false'),
        rules: rules,
      );
    } else if (methodName == 'enums') {
      String enumType = 'Enum';
      if (baseExpr is MethodInvocation) {
        final typeArgs = baseExpr.typeArguments?.arguments;
        if (typeArgs != null && typeArgs.isNotEmpty) {
          enumType = typeArgs.first.toSource();
        } else {
          final args = baseExpr.argumentList.arguments;
          if (args.isNotEmpty) {
            final first = args.first;
            if (first is PrefixedIdentifier &&
                first.identifier.name == 'values') {
              enumType = first.prefix.name;
            } else if (first is PropertyAccess &&
                first.propertyName.name == 'values') {
              enumType = first.target?.toSource() ?? 'Enum';
            }
          }
        }
      }
      final type = isNullable || isOptional || defaultValue == null
          ? '$enumType?'
          : enumType;
      return ParsedField(
        name: fieldName,
        dartType: type,
        isNullable: isNullable,
        isOptional: isOptional,
        defaultValue: defaultValue,
        rules: rules,
      );
    } else if (methodName == 'map') {
      String keyType = 'Object';
      String valType = 'Object';
      if (baseExpr is MethodInvocation) {
        final typeArgs = baseExpr.typeArguments?.arguments;
        if (typeArgs != null && typeArgs.length >= 2) {
          keyType = typeArgs[0].toSource();
          valType = typeArgs[1].toSource();
        } else {
          final args = baseExpr.argumentList.arguments;
          if (args.length >= 2) {
            keyType = _resolveDartType(args[0]) ?? 'Object';
            valType = _resolveDartType(args[1]) ?? 'Object';
          }
        }
      }
      final type = isNullable
          ? 'Map<$keyType, $valType>?'
          : 'Map<$keyType, $valType>';
      return ParsedField(
        name: fieldName,
        dartType: type,
        isNullable: isNullable,
        isOptional: isOptional,
        defaultValue: defaultValue ?? (isNullable ? null : 'const {}'),
        rules: rules,
      );
    } else if (methodName == 'list') {
      if (baseExpr is! MethodInvocation) return null;
      final listArgs = baseExpr.argumentList.arguments;
      if (listArgs.isEmpty) return null;
      final itemArg = listArgs.first;

      String singular = _capitalize(fieldName);
      if (singular.endsWith('ies')) {
        singular = '${singular.substring(0, singular.length - 3)}y';
      } else if (singular.endsWith('ses') ||
          singular.endsWith('xes') ||
          singular.endsWith('shes') ||
          singular.endsWith('ches')) {
        singular = singular.substring(0, singular.length - 2);
      } else if (singular.endsWith('s') && !singular.endsWith('ss')) {
        singular = singular.substring(0, singular.length - 1);
      }
      final defaultItemTypeName = '$singular$suffix';

      String nestedSchemaName = '';
      if (itemArg is SimpleIdentifier) {
        nestedSchemaName = itemArg.name;
      } else if (compilationUnit != null) {
        final cand1 = '${_uncapitalize(singular)}$suffix';
        final cand2 = '${_uncapitalize(singular)}Schema';
        for (final d in compilationUnit.declarations) {
          if (d is TopLevelVariableDeclaration) {
            for (final v in d.variables.variables) {
              if (v.name.lexeme == cand1) nestedSchemaName = cand1;
              if (v.name.lexeme == cand2) nestedSchemaName = cand2;
            }
          } else if (d is FunctionDeclaration) {
            if (d.name.lexeme == cand1) nestedSchemaName = cand1;
            if (d.name.lexeme == cand2) nestedSchemaName = cand2;
          }
        }
      }

      // Parse nested list item
      final nestedClass = _parseObjectExpression(
        itemArg,
        defaultItemTypeName,
        nestedSchemaName,
        isListItem: true,
        outClasses: outClasses,
        parentClass: parentClass,
        listFieldNameInParent: fieldName,
        suffix: suffix,
        compilationUnit: compilationUnit,
      );

      String itemType = 'Object';
      if (nestedClass != null) {
        itemType = nestedClass.name;
      } else {
        itemType = _resolveDartType(itemArg) ?? 'Object';
      }
      final type = 'List<$itemType>';

      return ParsedField(
        name: fieldName,
        dartType: type,
        isNullable: false,
        isOptional: isOptional,
        defaultValue: defaultValue ?? 'const []',
        isList: true,
        listItemType: itemType,
        nestedClass: nestedClass,
        rules: rules,
      );
    } else if (methodName == 'object' ||
        (baseExpr is MethodInvocation &&
            ![
              'string',
              'int',
              'double',
              'number',
              'num',
              'boolean',
              'enums',
              'list',
              'map',
            ].contains(methodName))) {
      final nestedClassName = '${_capitalize(fieldName)}$suffix';
      final nestedClass = _parseObjectExpression(
        expr,
        nestedClassName,
        '$fieldName$suffix',
        isListItem: false,
        outClasses: outClasses,
        parentClass: parentClass,
        suffix: suffix,
        compilationUnit: compilationUnit,
      );
      if (nestedClass != null) {
        final type = isNullable ? '${nestedClass.name}?' : nestedClass.name;
        return ParsedField(
          name: fieldName,
          dartType: type,
          isNullable: isNullable,
          isOptional: isOptional,
          defaultValue:
              defaultValue ??
              (isNullable ? null : 'const ${nestedClass.name}()'),
          isNestedObject: true,
          nestedClass: nestedClass,
          rules: rules,
        );
      }
    }

    return null;
  }

  ({Expression base, List<MethodInvocation> methodCalls}) _unrollExpression(
    Expression expr,
  ) {
    final methodCalls = <MethodInvocation>[];
    Expression curr = expr;

    while (curr is MethodInvocation) {
      final target = curr.target;
      if (target != null && target is! SimpleIdentifier) {
        methodCalls.insert(0, curr);
        curr = target;
      } else {
        break;
      }
    }

    return (base: curr, methodCalls: methodCalls);
  }

  /// Resolves the Dart type representation of a validator expression.
  ///
  /// Priority:
  /// 1. Resolved static type via Dart Analyzer if available (`KSValidator<T>`).
  /// 2. AST-based recursive extraction for unresolved AST execution (e.g. unit tests).
  String? _resolveDartType(Expression expr) {
    // 1. Check resolved analyzer type if available
    final staticType = expr.staticType;
    if (staticType != null && staticType is InterfaceType) {
      InterfaceType? validatorType;
      if (staticType.element.name == 'KSValidator') {
        validatorType = staticType;
      } else {
        for (final supertype in staticType.allSupertypes) {
          if (supertype.element.name == 'KSValidator') {
            validatorType = supertype;
            break;
          }
        }
      }
      if (validatorType != null && validatorType.typeArguments.isNotEmpty) {
        var display = validatorType.typeArguments.first.getDisplayString();
        if (display.endsWith('?')) {
          display = display.substring(0, display.length - 1);
        }
        return display;
      }
    }

    // 2. Recursive AST fallback (unresolved AST)
    final unrolled = _unrollExpression(expr);
    final base = unrolled.base;

    if (base is MethodInvocation) {
      final name = base.methodName.name;
      if (name == 'int') return 'int';
      if (name == 'string') return 'String';
      if (name == 'double') return 'double';
      if (name == 'number' || name == 'num') return 'num';
      if (name == 'boolean') return 'bool';
      if (name == 'enums') {
        final typeArgs = base.typeArguments?.arguments;
        if (typeArgs != null && typeArgs.isNotEmpty) {
          return typeArgs.first.toSource();
        }
        final args = base.argumentList.arguments;
        if (args.isNotEmpty) {
          final first = args.first;
          if (first is PrefixedIdentifier &&
              first.identifier.name == 'values') {
            return first.prefix.name;
          } else if (first is PropertyAccess &&
              first.propertyName.name == 'values') {
            return first.target?.toSource() ?? 'Enum';
          }
        }
        return 'Enum';
      }
      if (name == 'list') {
        final args = base.argumentList.arguments;
        if (args.isNotEmpty) {
          final innerType = _resolveDartType(args.first) ?? 'Object';
          return 'List<$innerType>';
        }
        return 'List<Object>';
      }
      if (name == 'map') {
        final typeArgs = base.typeArguments?.arguments;
        if (typeArgs != null && typeArgs.length >= 2) {
          return 'Map<${typeArgs[0].toSource()}, ${typeArgs[1].toSource()}>';
        }
        final args = base.argumentList.arguments;
        if (args.length >= 2) {
          final k = _resolveDartType(args[0]) ?? 'Object';
          final v = _resolveDartType(args[1]) ?? 'Object';
          return 'Map<$k, $v>';
        }
        return 'Map<Object, Object>';
      }
      if (name == 'object' || name == 'discriminatedUnion') {
        for (final arg in base.argumentList.arguments) {
          if (arg is NamedExpression && arg.name.label.name == 'className') {
            if (arg.expression is SimpleStringLiteral) {
              return (arg.expression as SimpleStringLiteral).value;
            }
          }
        }
      }
    } else if (base is SimpleIdentifier) {
      return _capitalize(base.name);
    }
    return null;
  }

  ParsedClass? _parseDiscriminatedUnionExpression(
    MethodInvocation baseExpr,
    String className,
    String schemaName, {
    required bool isListItem,
    bool isFunction = false,
    required List<ParsedClass> outClasses,
    ParsedClass? parentClass,
    String? listFieldNameInParent,
    String suffix = 'Schema',
    CompilationUnit? compilationUnit,
  }) {
    final args = baseExpr.argumentList.arguments;
    if (args.length < 2) return null;

    final discArg = args[0];
    final variantsArg = args[1];

    String discriminator = 'category';
    if (discArg is SimpleStringLiteral) {
      discriminator = discArg.value;
    }

    String? explicitClassName;
    for (final a in args) {
      if (a is NamedExpression && a.name.label.name == 'className') {
        if (a.expression is SimpleStringLiteral) {
          explicitClassName = (a.expression as SimpleStringLiteral).value;
        }
      }
    }

    if (explicitClassName != null) {
      if (!explicitClassName.endsWith(suffix)) {
        explicitClassName = '$explicitClassName$suffix';
      }
    }
    final finalClassName = explicitClassName ?? className;

    final existingIndex = outClasses.indexWhere(
      (c) => c.name == finalClassName,
    );
    if (existingIndex != -1) {
      return outClasses[existingIndex];
    }

    final ancestorListItems = <ParsedClass>[];
    if (parentClass != null) {
      if (parentClass.isListItem) {
        ancestorListItems.addAll(parentClass.ancestorListItems);
        ancestorListItems.add(parentClass);
      } else {
        ancestorListItems.addAll(parentClass.ancestorListItems);
      }
    }

    final unionClass = ParsedClass(
      name: finalClassName,
      schemaName: schemaName,
      isListItem: isListItem,
      isFunction: isFunction,
      isUnion: true,
      unionDiscriminator: discriminator,
      unionVariants: {},
      fields: [],
      parentClass: parentClass,
      listFieldNameInParent: listFieldNameInParent,
      ancestorListItems: ancestorListItems,
    );
    outClasses.add(unionClass);

    if (variantsArg is SetOrMapLiteral) {
      for (final entry in variantsArg.elements) {
        if (entry is! MapLiteralEntry) continue;
        final keyExpr = entry.key;
        final valExpr = entry.value;

        String variantKey = '';
        if (keyExpr is SimpleStringLiteral) {
          variantKey = keyExpr.value;
        } else {
          continue;
        }

        final variantDefaultName =
            '${_capitalize(variantKey)}${_getSingularName(finalClassName, suffix)}$suffix';

        final variantClass = _parseObjectExpression(
          valExpr,
          variantDefaultName,
          valExpr is MethodInvocation ? valExpr.methodName.name : '',
          isListItem: true,
          outClasses: outClasses,
          parentClass: unionClass,
          listFieldNameInParent: listFieldNameInParent,
          suffix: suffix,
          compilationUnit: compilationUnit,
        );

        if (variantClass != null) {
          final updatedVariant = ParsedClass(
            name: variantClass.name,
            schemaName: variantClass.schemaName,
            isListItem: true,
            isFunction: variantClass.isFunction,
            fields: variantClass.fields,
            refinements: variantClass.refinements,
            parentClass: unionClass,
            listFieldNameInParent: listFieldNameInParent,
            unionBaseClass: unionClass,
            unionDiscriminatorValue: variantKey,
            ancestorListItems: ancestorListItems,
          );
          final vIdx = outClasses.indexOf(variantClass);
          if (vIdx != -1) {
            outClasses[vIdx] = updatedVariant;
          }
          unionClass.unionVariants![variantKey] = updatedVariant;
        }
      }
    }

    if (unionClass.unionVariants != null &&
        unionClass.unionVariants!.isNotEmpty) {
      final allVariantFields = unionClass.unionVariants!.values
          .map((v) => v.fields)
          .toList();
      final commonFieldNames = allVariantFields.first.map((f) => f.name).where((
        name,
      ) {
        return allVariantFields.every(
          (fields) => fields.any((f) => f.name == name),
        );
      }).toList();

      for (final name in commonFieldNames) {
        final fieldInFirst = allVariantFields.first.firstWhere(
          (f) => f.name == name,
        );
        unionClass.fields.add(fieldInFirst);
      }
    }

    _updateDescendantAncestors(unionClass, ancestorListItems, outClasses);

    return unionClass;
  }

  String _getSingularName(String name, String suffix) {
    if (name.length > suffix.length && name.endsWith(suffix)) {
      return name.substring(0, name.length - suffix.length);
    }
    if (name.length > 'Schema'.length && name.endsWith('Schema')) {
      return name.substring(0, name.length - 'Schema'.length);
    }
    return name;
  }

  String _inferClassName(String schemaName, String suffix) {
    var name = schemaName;
    if (name.startsWith('_')) {
      name = name.substring(1);
    }
    if (name.endsWith('Schema')) {
      name = name.substring(0, name.length - 'Schema'.length);
    }
    return '${_capitalize(name)}$suffix';
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _uncapitalize(String s) =>
      s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);

  void _updateDescendantAncestors(
    ParsedClass cls,
    List<ParsedClass> ancestors,
    List<ParsedClass> outClasses,
  ) {
    if (cls.isUnion && cls.unionVariants != null) {
      for (final variant in cls.unionVariants!.values) {
        final variantAncestors = [
          ...ancestors,
          if (!ancestors.any((a) => a.name == cls.name)) cls,
        ];
        _updateDescendantAncestors(variant, variantAncestors, outClasses);
      }
    }

    for (final f in cls.fields) {
      if (f.isList && f.nestedClass != null) {
        final child = f.nestedClass!;
        final effectiveCurrent =
            cls.unionBaseClass ?? (cls.isListItem ? cls : null);
        final childAncestors = [
          ...ancestors,
          if (effectiveCurrent != null &&
              !ancestors.any((a) => a.name == effectiveCurrent.name))
            effectiveCurrent,
        ];
        final updatedChild = ParsedClass(
          name: child.name,
          schemaName: child.schemaName,
          isListItem: true,
          isFunction: child.isFunction,
          fields: child.fields,
          refinements: child.refinements,
          parentClass: cls,
          listFieldNameInParent: f.name,
          unionBaseClass: child.unionBaseClass,
          unionDiscriminatorValue: child.unionDiscriminatorValue,
          isUnion: child.isUnion,
          unionDiscriminator: child.unionDiscriminator,
          unionVariants: child.unionVariants,
          ancestorListItems: childAncestors,
        );
        final cIdx = outClasses.indexOf(child);
        if (cIdx != -1) {
          outClasses[cIdx] = updatedChild;
        }
        _updateDescendantAncestors(updatedChild, childAncestors, outClasses);
      }
    }
  }
}
