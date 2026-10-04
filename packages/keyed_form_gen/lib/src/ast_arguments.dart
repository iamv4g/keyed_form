import 'package:analyzer/dart/ast/ast.dart';

/// Extracts an argument's expression across analyzer AST versions.
Expression argumentExpressionOf(Object argument) {
  final dynamic node = argument;
  try {
    return node.argumentExpression as Expression;
  } on NoSuchMethodError {
    try {
      return node.expression as Expression;
    } on NoSuchMethodError {
      return node as Expression;
    }
  }
}

/// Extracts a named argument's label across analyzer AST versions.
String? argumentNameOf(Object argument) {
  final dynamic node = argument;
  try {
    final dynamic name = node.name;
    try {
      return name.label.name as String;
    } on NoSuchMethodError {
      return name.lexeme as String;
    }
  } on NoSuchMethodError {
    return null;
  }
}
