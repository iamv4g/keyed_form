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
      expect(
        fields.firstWhere((f) => f.name == 'scores').dartType,
        'List<int>',
      );
      expect(
        fields.firstWhere((f) => f.name == 'nestedMatrix').dartType,
        'List<List<double>>',
      );
      expect(
        fields.firstWhere((f) => f.name == 'priorities').dartType,
        'List<Priority>',
      );
      expect(fields.firstWhere((f) => f.name == 'status').dartType, 'Status?');
    });
  });

  group('root-level function schema declarations', () {
    const parser = SchemaParser();

    test('an arrow-bodied function schema resolves its expression body', () {
      const source = '''
KSObject loginSchema() => ks.object({
  'username': ks.string(),
});
''';
      final unit = parseString(content: source).unit;
      final decl = unit.declarations.first as FunctionDeclaration;
      final classes = parser.parseElement(
        _FakeElement('loginSchema'),
        decl,
        compilationUnit: unit,
      );

      expect(classes, hasLength(1));
      expect(classes.first.name, 'LoginSchema');
      expect(classes.first.isFunction, isTrue);
      expect(classes.first.fields.single.name, 'username');
    });

    test('a block-bodied function schema resolves its return statement', () {
      const source = '''
KSObject loginSchema() {
  final unused = 1;
  return ks.object({
    'username': ks.string(),
  });
}
''';
      final unit = parseString(content: source).unit;
      final decl = unit.declarations.first as FunctionDeclaration;
      final classes = parser.parseElement(
        _FakeElement('loginSchema'),
        decl,
        compilationUnit: unit,
      );

      expect(classes, hasLength(1));
      expect(classes.first.name, 'LoginSchema');
      expect(classes.first.fields.single.name, 'username');
    });

    test('a function body with no return statement yields no classes', () {
      const source = '''
KSObject loginSchema() {
  final unused = 1;
}
''';
      final unit = parseString(content: source).unit;
      final decl = unit.declarations.first as FunctionDeclaration;
      final classes = parser.parseElement(
        _FakeElement('loginSchema'),
        decl,
        compilationUnit: unit,
      );

      expect(classes, isEmpty);
    });
  });

  group('explicit className override', () {
    const parser = SchemaParser();

    test('ks.object(className: ...) sets the class name, appending the suffix if missing', () {
      const source = '''
final testSchema = ks.object(className: 'CustomThing', {
  'foo': ks.string(),
});
''';
      final unit = parseString(content: source).unit;
      final decl = unit.declarations.first as TopLevelVariableDeclaration;
      final classes = parser.parseElement(
        _FakeElement('testSchema'),
        decl,
        compilationUnit: unit,
      );

      expect(classes, hasLength(1));
      expect(classes.first.name, 'CustomThingSchema');
    });

    test(
      'an explicit className already ending in the suffix is not doubled',
      () {
        const source = '''
final testSchema = ks.object(className: 'CustomThingSchema', {
  'foo': ks.string(),
});
''';
        final unit = parseString(content: source).unit;
        final decl = unit.declarations.first as TopLevelVariableDeclaration;
        final classes = parser.parseElement(
          _FakeElement('testSchema'),
          decl,
          compilationUnit: unit,
        );

        expect(classes, hasLength(1));
        expect(classes.first.name, 'CustomThingSchema');
      },
    );
  });

  group('.refine() cross-field refinements', () {
    const parser = SchemaParser();

    test('captures the callback source, message, and path', () {
      const source = '''
final testSchema = ks.object({
  'password': ks.string(),
  'confirm': ks.string(),
}).refine(
  (data) => data['password'] == data['confirm'],
  error: KSError.text('Passwords must match'),
  path: 'confirm',
);
''';
      final unit = parseString(content: source).unit;
      final decl = unit.declarations.first as TopLevelVariableDeclaration;
      final classes = parser.parseElement(
        _FakeElement('testSchema'),
        decl,
        compilationUnit: unit,
      );

      expect(classes, hasLength(1));
      final refinement = classes.first.refinements.single;
      expect(refinement.message, 'Passwords must match');
      expect(refinement.path, 'confirm');
      expect(refinement.testCode, contains("data['password']"));
    });

    test('a refine() missing error or path contributes no refinement', () {
      const source = '''
final testSchema = ks.object({
  'a': ks.string(),
}).refine((data) => true);
''';
      final unit = parseString(content: source).unit;
      final decl = unit.declarations.first as TopLevelVariableDeclaration;
      final classes = parser.parseElement(
        _FakeElement('testSchema'),
        decl,
        compilationUnit: unit,
      );

      expect(classes.first.refinements, isEmpty);
    });
  });

  group('discriminatedUnion parsing', () {
    const parser = SchemaParser();

    test('parses the discriminator, both variants, and promotes shared fields to the base class', () {
      const source = '''
final testSchema = ks.discriminatedUnion('category', {
  'admission': ks.object({
    'sortIndex': ks.int().defaultTo(0),
    'targetId': ks.string().optional(),
  }),
  'transfer': ks.object({
    'sortIndex': ks.int().defaultTo(0),
    'transferTargetId': ks.string().optional(),
  }),
}, className: 'SectionSchema');
''';
      final unit = parseString(content: source).unit;
      final decl = unit.declarations.first as TopLevelVariableDeclaration;
      final classes = parser.parseElement(
        _FakeElement('testSchema'),
        decl,
        compilationUnit: unit,
      );

      // The union base class + both variants.
      expect(classes, hasLength(3));
      final union = classes.firstWhere((c) => c.name == 'SectionSchema');
      expect(union.isUnion, isTrue);
      expect(union.unionDiscriminator, 'category');
      expect(union.unionVariants!.keys, containsAll(['admission', 'transfer']));
      // 'sortIndex' is common to every variant, so it's promoted to the base.
      expect(union.fields.map((f) => f.name), contains('sortIndex'));

      final admission = union.unionVariants!['admission']!;
      expect(admission.unionBaseClass, same(union));
      expect(admission.unionDiscriminatorValue, 'admission');
      expect(admission.fields.map((f) => f.name), contains('targetId'));

      final transfer = union.unionVariants!['transfer']!;
      expect(transfer.unionDiscriminatorValue, 'transfer');
      expect(transfer.fields.map((f) => f.name), contains('transferTargetId'));
      // A field unique to one variant is not promoted to the base.
      expect(
        union.fields.map((f) => f.name),
        isNot(contains('transferTargetId')),
      );
    });

    test(
      'a discriminator argument default of "category" is used when omitted',
      () {
        // Malformed input (missing the discriminator string literal) still
        // parses without throwing — falls back to the 'category' default.
        const source = '''
final testSchema = ks.discriminatedUnion(someVar, {
  'a': ks.object({'x': ks.string()}),
}, className: 'PolySchema');
''';
        final unit = parseString(content: source).unit;
        final decl = unit.declarations.first as TopLevelVariableDeclaration;
        final classes = parser.parseElement(
          _FakeElement('testSchema'),
          decl,
          compilationUnit: unit,
        );

        final union = classes.firstWhere((c) => c.name == 'PolySchema');
        expect(union.unionDiscriminator, 'category');
      },
    );
  });

  group('nested object field (non-list)', () {
    const parser = SchemaParser();

    test(
      'a ks.object({...}) field value produces a nested class and typed field',
      () {
        const source = '''
final testSchema = ks.object({
  'name': ks.string(),
  'address': ks.object({
    'city': ks.string(),
  }),
});
''';
        final unit = parseString(content: source).unit;
        final decl = unit.declarations.first as TopLevelVariableDeclaration;
        final classes = parser.parseElement(
          _FakeElement('testSchema'),
          decl,
          compilationUnit: unit,
        );

        expect(classes, hasLength(2));
        final root = classes.first;
        final addressField = root.fields.firstWhere((f) => f.name == 'address');
        expect(addressField.isNestedObject, isTrue);
        expect(addressField.dartType, 'AddressSchema');
        expect(addressField.nestedClass!.fields.single.name, 'city');
      },
    );
  });

  group('list field item-type singularization', () {
    const parser = SchemaParser();

    test('covers every pluralization branch the generator relies on', () {
      const source = '''
final testSchema = ks.object({
  'categories': ks.list(ks.object({'v': ks.string()})),
  'boxes': ks.list(ks.object({'v': ks.string()})),
  'buses': ks.list(ks.object({'v': ks.string()})),
  'dishes': ks.list(ks.object({'v': ks.string()})),
  'watches': ks.list(ks.object({'v': ks.string()})),
  'items': ks.list(ks.object({'v': ks.string()})),
  'glass': ks.list(ks.object({'v': ks.string()})),
});
''';
      final unit = parseString(content: source).unit;
      final decl = unit.declarations.first as TopLevelVariableDeclaration;
      final classes = parser.parseElement(
        _FakeElement('testSchema'),
        decl,
        compilationUnit: unit,
      );
      final fields = classes.first.fields;

      String itemTypeOf(String fieldName) =>
          fields.firstWhere((f) => f.name == fieldName).listItemType!;

      expect(itemTypeOf('categories'), 'CategorySchema'); // 'ies' -> 'y'
      expect(itemTypeOf('boxes'), 'BoxSchema'); // 'xes' -> trim 2
      expect(itemTypeOf('buses'), 'BusSchema'); // 'ses' -> trim 2
      expect(itemTypeOf('dishes'), 'DishSchema'); // 'shes' -> trim 2
      expect(itemTypeOf('watches'), 'WatchSchema'); // 'ches' -> trim 2
      expect(itemTypeOf('items'), 'ItemSchema'); // plain 's' -> trim 1
      expect(itemTypeOf('glass'), 'GlassSchema'); // 'ss' -> left alone
    });
  });

  group('schema references (a field value naming another declared schema)', () {
    const parser = SchemaParser();

    test(
      'a bare identifier list item resolves to a sibling variable schema',
      () {
        const source = '''
final lineItemSchema = ks.object({'sku': ks.string()});

final testSchema = ks.object({
  'items': ks.list(lineItemSchema),
});
''';
        final unit = parseString(content: source).unit;
        final decl = unit.declarations.last as TopLevelVariableDeclaration;
        final classes = parser.parseElement(
          _FakeElement('testSchema'),
          decl,
          compilationUnit: unit,
        );

        final itemsField = classes.first.fields.single;
        expect(itemsField.nestedClass, isNotNull);
        expect(itemsField.nestedClass!.fields.single.name, 'sku');
      },
    );

    test(
      'a field value calling a sibling function schema resolves through it',
      () {
        const source = '''
KSObject partSchema() => ks.object({'code': ks.string()});

final testSchema = ks.object({
  'part': partSchema(),
});
''';
        final unit = parseString(content: source).unit;
        final decl = unit.declarations.last as TopLevelVariableDeclaration;
        final classes = parser.parseElement(
          _FakeElement('testSchema'),
          decl,
          compilationUnit: unit,
        );

        final partField = classes.first.fields.single;
        expect(partField.isNestedObject, isTrue);
        expect(partField.nestedClass!.fields.single.name, 'code');
      },
    );
  });
}

class _FakeElement implements Element {
  _FakeElement(this.name);

  @override
  final String name;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
