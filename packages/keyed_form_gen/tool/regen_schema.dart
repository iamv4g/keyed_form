// Standalone re-generator for `@keyedSchema library;` files.
//
// Replicates `KeyedFormGenerator` + the source_gen SharedPartBuilder wrapper
// without running build_runner (which, in this repo, prunes every generated
// file it cannot re-derive because dart_mappable/riverpod do not yet parse
// Dart 3.13 primary constructors).
//
// Usage: fvm dart run tool/regen_schema.dart <path/to/foo_schema.dart> [...]
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:dart_style/dart_style.dart';
import 'package:keyed_form_gen/src/generators/data_class_generator.dart';
import 'package:keyed_form_gen/src/generators/preamble.dart';
import 'package:keyed_form_gen/src/models/schema_model.dart';
import 'package:keyed_form_gen/src/schema_parser.dart';

class _NamedElement implements Element {
  _NamedElement(this._name);
  final String _name;
  @override
  String get name => _name;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

String _suffixFor(CompilationUnit unit) {
  // Look for `@KeyedSchema(suffix: '...')` on the library directive.
  for (final directive in unit.directives) {
    for (final md in directive.metadata) {
      if (md.name.name != 'KeyedSchema') continue;
      final args = md.arguments?.arguments ?? const <Expression>[];
      for (final arg in args) {
        if (arg is NamedExpression && arg.name.label.name == 'suffix') {
          final v = arg.expression;
          if (v is SimpleStringLiteral) return v.value;
        }
      }
    }
  }
  return 'Schema';
}

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('usage: regen_schema.dart <foo_schema.dart> [...]');
    exit(64);
  }

  final formatter = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  );

  for (final path in args) {
    final file = File(path);
    final source = file.readAsStringSync();
    final unit = parseString(content: source).unit;
    final suffix = _suffixFor(unit);

    final parser = const SchemaParser();
    final parsed = <ParsedClass>[];
    final seen = <String>{};
    void add(List<ParsedClass> classes) {
      for (final c in classes) {
        if (seen.add(c.name)) parsed.add(c);
      }
    }

    for (final declaration in unit.declarations) {
      String? name;
      if (declaration is FunctionDeclaration) {
        name = declaration.name.lexeme;
      } else if (declaration is TopLevelVariableDeclaration) {
        name = declaration.variables.variables.first.name.lexeme;
      }
      if (name == null) continue;
      add(
        parser.parseElement(
          _NamedElement(name),
          declaration,
          suffix: suffix,
          compilationUnit: unit,
        ),
      );
    }

    if (parsed.isEmpty) {
      stderr.writeln('!! no schema classes parsed from $path');
      continue;
    }

    final body = StringBuffer();
    body.write(generatedPreamble());

    const dataClassGen = DataClassGenerator();
    for (final cls in parsed) {
      body.writeln(
        dataClassGen.generate(cls, allClasses: parsed, suffix: suffix),
      );
    }

    final partOf = "part of '${_basename(path)}';";
    // Mirrors the real PartBuilder in lib/builder.dart byte-for-byte: the
    // ignore-comment sits in the header, before `part of` (writeDescriptions
    // is false there, so no generator-description banner follows it either).
    final full =
        '''
// GENERATED CODE - DO NOT MODIFY BY HAND

$generatedIgnoreComment

$partOf

${body.toString().trimRight()}
''';

    final outPath = path.replaceFirst(RegExp(r'\.dart$'), '.kfg.dart');
    String out;
    try {
      out = formatter.format(full);
    } catch (e) {
      File('$outPath.raw').writeAsStringSync(full);
      stderr.writeln('!! format failed for $outPath — wrote $outPath.raw\n$e');
      continue;
    }
    File(outPath).writeAsStringSync(out);
    stdout.writeln('wrote $outPath (${parsed.length} classes, suffix=$suffix)');
  }
}

String _basename(String path) => path.split(Platform.pathSeparator).last;
