import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:keyed_schema/keyed_schema.dart';
import 'package:source_gen/source_gen.dart';

import 'generators/data_class_generator.dart';
import 'generators/preamble.dart';
import 'models/schema_model.dart';
import 'schema_parser.dart';

class _NamedElement implements Element {
  final String _name;
  _NamedElement(this._name);
  @override
  String get name => _name;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// `source_gen` generator for a `@keyedSchema`-annotated library: it expands
/// every top-level schema declared in that file into immutable data models, a
/// `<Root>Fields` lens namespace, and type-safe validation functions, emitted
/// into the library's `.kfg.dart` part.
class KeyedFormGenerator extends GeneratorForAnnotation<KeyedSchema> {
  /// Creates the generator. Wired in by `keyedFormBuilder`; construct it
  /// directly only for a custom build.
  const KeyedFormGenerator();

  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final unit = await _getCompilationUnit(element, buildStep);
    if (unit == null) {
      return '// Could not resolve AST compilation unit';
    }

    final suffix = annotation.peek('suffix')?.stringValue ?? 'Schema';
    final parser = const SchemaParser();
    final parsedClasses = <ParsedClass>[];
    final seenClassNames = <String>{};

    void addClasses(List<ParsedClass> classes) {
      for (final cls in classes) {
        if (seenClassNames.add(cls.name)) {
          parsedClasses.add(cls);
        }
      }
    }

    if (element is LibraryElement) {
      // Library-level annotation: parse all top-level schema declarations in the file
      for (final declaration in unit.declarations) {
        String? name;
        if (declaration is FunctionDeclaration) {
          name = declaration.name.lexeme;
        } else if (declaration is TopLevelVariableDeclaration) {
          for (final v in declaration.variables.variables) {
            name = v.name.lexeme;
            break;
          }
        }
        if (name == null) continue;

        final targetElement = _NamedElement(name);
        final classes = parser.parseElement(
          targetElement,
          declaration,
          suffix: suffix,
          compilationUnit: unit,
        );
        addClasses(classes);
      }
    } else if (element is TopLevelVariableElement ||
        element is TopLevelFunctionElement ||
        element is ExecutableElement) {
      final astNode = await _getAstNode(element, unit);
      if (astNode != null) {
        final classes = parser.parseElement(
          element,
          astNode,
          suffix: suffix,
          compilationUnit: unit,
        );
        addClasses(classes);
      }
    } else {
      throw InvalidGenerationSourceError(
        '@KeyedSchema can only be placed at the file level (`@keyedSchema library;`) or on top-level schema declarations.',
        element: element,
      );
    }

    if (parsedClasses.isEmpty) {
      return '// No valid schema definition found in ${element.name}';
    }

    final buffer = StringBuffer();
    buffer.write(generatedPreamble());

    // Data classes, `<Root>Fields` namespaces and `<Accessor>FieldRefs`
    // wrappers. Row identity is a plain `String` clientId passed inline as a
    // `({String seg,…})` record — no generated ClientId / Ref types.
    const dataClassGen = DataClassGenerator();
    for (final cls in parsedClasses) {
      buffer.writeln(
        dataClassGen.generate(cls, allClasses: parsedClasses, suffix: suffix),
      );
    }

    return buffer.toString();
  }

  Future<CompilationUnit?> _getCompilationUnit(
    Element element,
    BuildStep buildStep,
  ) async {
    try {
      return await buildStep.resolver.compilationUnitFor(buildStep.inputId);
    } catch (_) {
      return null;
    }
  }

  Future<AstNode?> _getAstNode(Element element, CompilationUnit? unit) async {
    if (unit == null) return null;
    for (final declaration in unit.declarations) {
      if (declaration is TopLevelVariableDeclaration) {
        for (final v in declaration.variables.variables) {
          if (v.name.lexeme == element.name) {
            return declaration;
          }
        }
      } else if (declaration is FunctionDeclaration) {
        if (declaration.name.lexeme == element.name) {
          return declaration;
        }
      }
    }
    return null;
  }
}
