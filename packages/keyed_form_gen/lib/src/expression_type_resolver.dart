/// Pure AST-analysis helpers used by [SchemaParser] to resolve a validator
/// expression's Dart type. Unlike `_parseObjectExpression`/`_parseField`
/// (which recurse into each other to walk a whole `ks.object({...})` tree),
/// these never call back into the parser — they only look at the one
/// expression they're given — so they live in their own file instead of
/// schema_parser.dart. Not exported from the package's public API.
library;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';

import 'naming.dart';

/// Strips chained method calls like `.refine(...)` off [expr], returning the
/// innermost call/identifier (`base`) and the chain in source order
/// (`methodCalls`). E.g. for `ks.object({...}).refine(...)`, `base` is the
/// `ks.object({...})` invocation and `methodCalls` is `[.refine(...)]`.
({Expression base, List<MethodInvocation> methodCalls}) unrollExpression(
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
String? resolveDartType(Expression expr) {
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
  final unrolled = unrollExpression(expr);
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
        if (first is PrefixedIdentifier && first.identifier.name == 'values') {
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
        final innerType = resolveDartType(args.first) ?? 'Object';
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
        final k = resolveDartType(args[0]) ?? 'Object';
        final v = resolveDartType(args[1]) ?? 'Object';
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
    return capitalize(base.name);
  }
  return null;
}
