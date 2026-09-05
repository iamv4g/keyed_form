import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:keyed_form_gen/src/schema_parser.dart';
import 'package:test/test.dart';

void main() {
  group('SchemaParser _resolveDartType and field parsing', () {
    const parser = SchemaParser();

    test('parses maps with type arguments or inferred validator arguments', () {
      const source = '''
final testSchema = ks.object({
  'explicitMap': ks.map<String, int>().optional(),
  'inferredMap': ks.map(ks.string(), ks.int()).nullable(),
  'nestedListMap': ks.map(ks.string(), ks.list(ks.int())),
});
''';
      final unit = parseString(content: source).unit;
      final decl = unit.declarations.first as TopLevelVariableDeclaration;
      final variable = decl.variables.variables.first;
      // In parseString AST, declaredElement may be null, but parseElement only uses element.name
      // Let's create a mock/fake element or pass variable.name.lexeme
      final classes = parser.parseElement(
        _FakeElement(variable.name.lexeme),
        decl,
        compilationUnit: unit,
      );

      expect(classes, hasLength(1));
      final fields = classes.first.fields;
      expect(
        fields.firstWhere((f) => f.name == 'explicitMap').dartType,
        'Map<String, int>',
      );
      expect(
        fields.firstWhere((f) => f.name == 'inferredMap').dartType,
        'Map<String, int>?',
      );
      expect(
        fields.firstWhere((f) => f.name == 'nestedListMap').dartType,
        'Map<String, List<int>>',
      );
    });

    test('parses nested lists and enums accurately', () {
      const source = '''
enum Priority { low, high }
enum Status { draft, published }

final testSchema = ks.object({
  'scores': ks.list(ks.int()),
  'nestedMatrix': ks.list(ks.list(ks.double())),
  'priorities': ks.list(ks.enums(Priority.values)),
  'status': ks.enums(Status.values),
});
''';
      final unit = parseString(content: source).unit;
      final decl = unit.declarations.last as TopLevelVariableDeclaration;
      final variable = decl.variables.variables.first;
      final classes = parser.parseElement(
        _FakeElement(variable.name.lexeme),
        decl,
        compilationUnit: unit,
      );

      expect(classes, hasLength(1));
      final fields = classes.first.fields;
      expect(fields.firstWhere((f) => f.name == 'scores').dartType, 'List<int>');
      expect(fields.firstWhere((f) => f.name == 'nestedMatrix').dartType, 'List<List<double>>');
      expect(fields.firstWhere((f) => f.name == 'priorities').dartType, 'List<Priority>');
      expect(fields.firstWhere((f) => f.name == 'status').dartType, 'Status?');
    });
  });
}

class _FakeElement implements Element {
  _FakeElement(this.name);

  @override
  final String name;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
