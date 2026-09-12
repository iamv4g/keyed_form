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

    test(
      'ks.object(className: ...) sets the class name, appending the suffix if missing',
      () {
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
      },
    );

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

    test(
      'parses the discriminator, both variants, and promotes shared fields to the base class',
      () {
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
        expect(
          union.unionVariants!.keys,
          containsAll(['admission', 'transfer']),
        );
        // 'sortIndex' is common to every variant, so it's promoted to the base.
        expect(union.fields.map((f) => f.name), contains('sortIndex'));

        final admission = union.unionVariants!['admission']!;
        expect(admission.unionBaseClass, same(union));
        expect(admission.unionDiscriminatorValue, 'admission');
        expect(admission.fields.map((f) => f.name), contains('targetId'));

        final transfer = union.unionVariants!['transfer']!;
        expect(transfer.unionDiscriminatorValue, 'transfer');
        expect(
          transfer.fields.map((f) => f.name),
          contains('transferTargetId'),
        );
        // A field unique to one variant is not promoted to the base.
        expect(
          union.fields.map((f) => f.name),
          isNot(contains('transferTargetId')),
        );
      },
    );

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

    test('a variant nested inside a list keeps the root schemaName, not the '
        "variant's own ks.object() method name", () {
      const source = '''
final testSchema = ks.object({
  'items': ks.list(
    ks.discriminatedUnion('kind', {
      'a': ks.object({'x': ks.string()}),
      'b': ks.object({'y': ks.string()}),
    }, className: 'ItemSchema'),
  ),
});
''';
      final unit = parseString(content: source).unit;
      final decl = unit.declarations.first as TopLevelVariableDeclaration;
      final classes = parser.parseElement(
        _FakeElement('testSchema'),
        decl,
        compilationUnit: unit,
      );

      final union = classes.firstWhere((c) => c.name == 'ItemSchema');
      for (final variant in union.unionVariants!.values) {
        expect(
          variant.schemaName,
          'testSchema',
          reason:
              'every generated validate() in the tree calls back into the '
              "root schema — a variant's schemaName must never fall back "
              "to the bare method name of its own ks.object(...) call",
        );
      }
    });
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

    test(
      'a field value calling a sibling block-bodied function schema resolves through it',
      () {
        const source = '''
KSObject partSchema() {
  return ks.object({'code': ks.string()});
}

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
        expect(partField.nestedClass!.fields.single.name, 'code');
      },
    );

    test('an inline list item borrows schemaName from a same-named sibling '
        'function declaration', () {
      // 'items' singularizes to 'Item'; both the default-suffix and
      // literal-'Schema' candidates the list branch searches for collapse
      // to the same name here, so a same-named top-level function
      // anywhere in the file gets its name silently borrowed as the
      // item's schemaName — even though the item itself is an inline
      // object, unrelated to that function.
      const source = '''
KSObject itemSchema() => ks.object({'unrelated': ks.string()});

final testSchema = ks.object({
  'items': ks.list(ks.object({'v': ks.string()})),
});
''';
      final unit = parseString(content: source).unit;
      final decl = unit.declarations.last as TopLevelVariableDeclaration;
      final classes = parser.parseElement(
        _FakeElement('testSchema'),
        decl,
        compilationUnit: unit,
      );

      final itemClass = classes.first.fields.single.nestedClass!;
      expect(itemClass.schemaName, 'itemSchema');
    });
  });

  group('parseElement node-type flexibility', () {
    const parser = SchemaParser();

    test('accepts a bare VariableDeclaration node directly, not just its '
        'TopLevelVariableDeclaration wrapper', () {
      const source = '''
final testSchema = ks.object({'name': ks.string()});
''';
      final unit = parseString(content: source).unit;
      final topDecl = unit.declarations.first as TopLevelVariableDeclaration;
      final bareVarDecl = topDecl.variables.variables.first;

      final classes = parser.parseElement(
        _FakeElement('testSchema'),
        bareVarDecl,
        compilationUnit: unit,
      );

      expect(classes, hasLength(1));
      expect(classes.first.fields.single.name, 'name');
    });
  });

  group('a bare-identifier field value (unlike a list item, not resolved)', () {
    const parser = SchemaParser();

    test('is silently dropped rather than crashing', () {
      const source = '''
final testSchema = ks.object({
  'name': ks.string(),
  'weird': someUndeclaredThing,
});
''';
      final unit = parseString(content: source).unit;
      final decl = unit.declarations.first as TopLevelVariableDeclaration;
      final classes = parser.parseElement(
        _FakeElement('testSchema'),
        decl,
        compilationUnit: unit,
      );

      final fieldNames = classes.first.fields.map((f) => f.name);
      expect(fieldNames, contains('name'));
      expect(fieldNames, isNot(contains('weird')));
    });
  });

  group('double / num / number scalar fields', () {
    const parser = SchemaParser();

    test('are nullable unless a defaultTo(...) is chained', () {
      const source = '''
final testSchema = ks.object({
  'price': ks.double(),
  'ratio': ks.num(),
  'score': ks.number(),
  'weight': ks.double().defaultTo(1.5),
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

      expect(fields.firstWhere((f) => f.name == 'price').dartType, 'double?');
      expect(fields.firstWhere((f) => f.name == 'ratio').dartType, 'num?');
      expect(fields.firstWhere((f) => f.name == 'score').dartType, 'num?');
      expect(fields.firstWhere((f) => f.name == 'weight').dartType, 'double');
    });
  });

  group('enum field edge cases', () {
    const parser = SchemaParser();

    test(
      'an explicit generic type argument takes priority over the inferred type',
      () {
        const source = '''
enum Priority { low, high }

final testSchema = ks.object({
  'level': ks.enums<Priority>(Priority.values),
});
''';
        final unit = parseString(content: source).unit;
        final decl = unit.declarations.last as TopLevelVariableDeclaration;
        final classes = parser.parseElement(
          _FakeElement('testSchema'),
          decl,
          compilationUnit: unit,
        );

        expect(classes.first.fields.single.dartType, 'Priority?');
      },
    );

    test(
      'a namespaced (3-segment) Foo.Bar.values access resolves via the target property access',
      () {
        const source = '''
final testSchema = ks.object({
  'level': ks.enums(prefix.Priority.values),
});
''';
        final unit = parseString(content: source).unit;
        final decl = unit.declarations.first as TopLevelVariableDeclaration;
        final classes = parser.parseElement(
          _FakeElement('testSchema'),
          decl,
          compilationUnit: unit,
        );

        expect(classes.first.fields.single.dartType, 'prefix.Priority?');
      },
    );
  });

  group('object-level dedup by explicit className', () {
    const parser = SchemaParser();

    test(
      'two fields with the same explicit className resolve to a single cached class',
      () {
        const source = '''
final testSchema = ks.object({
  'primary': ks.object(className: 'AddressSchema', {'city': ks.string()}),
  'secondary': ks.object(className: 'AddressSchema', {'zip': ks.string()}),
});
''';
        final unit = parseString(content: source).unit;
        final decl = unit.declarations.first as TopLevelVariableDeclaration;
        final classes = parser.parseElement(
          _FakeElement('testSchema'),
          decl,
          compilationUnit: unit,
        );

        // Deduped: only one AddressSchema, not two.
        expect(classes.where((c) => c.name == 'AddressSchema'), hasLength(1));
        final address = classes.firstWhere((c) => c.name == 'AddressSchema');
        // The first definition wins; the second field's own fields never
        // reach outClasses.
        expect(address.fields.map((f) => f.name), contains('city'));
        expect(address.fields.map((f) => f.name), isNot(contains('zip')));

        final secondaryField = classes.first.fields.firstWhere(
          (f) => f.name == 'secondary',
        );
        expect(secondaryField.nestedClass, same(address));
      },
    );
  });

  group('nested object field ancestor tracking', () {
    const parser = SchemaParser();

    test(
      'a nested object field inside a list item records that list item as an ancestor',
      () {
        const source = '''
final testSchema = ks.object({
  'sections': ks.list(ks.object({
    'title': ks.string(),
    'detail': ks.object({
      'note': ks.string(),
    }),
  })),
});
''';
        final unit = parseString(content: source).unit;
        final decl = unit.declarations.first as TopLevelVariableDeclaration;
        final classes = parser.parseElement(
          _FakeElement('testSchema'),
          decl,
          compilationUnit: unit,
        );

        final sectionClass = classes.first.fields.single.nestedClass!;
        final detailField = sectionClass.fields.firstWhere(
          (f) => f.name == 'detail',
        );
        final detailClass = detailField.nestedClass!;
        expect(
          detailClass.ancestorListItems.map((c) => c.name),
          contains('SectionSchema'),
        );
      },
    );
  });

  group('discriminatedUnion edge cases', () {
    const parser = SchemaParser();

    test(
      'appends the suffix to a bare explicit className, dedupes two fields '
      'sharing a finalClassName, and tracks a list-item ancestor two levels deep',
      () {
        const source = '''
final testSchema = ks.object({
  'primaryPayment': ks.discriminatedUnion('kind', {
    'cash': ks.object({'amount': ks.int()}),
  }, className: 'Method'),
  'backupPayment': ks.discriminatedUnion('kind', {}, className: 'MethodSchema'),
  'days': ks.list(ks.object({
    'sections': ks.list(ks.discriminatedUnion('category', {
      'admission': ks.object({'targetId': ks.string().optional()}),
      'transfer': ks.object({'transferTargetId': ks.string().optional()}),
    }, className: 'SectionSchema')),
  })),
});
''';
        final unit = parseString(content: source).unit;
        final decl = unit.declarations.first as TopLevelVariableDeclaration;
        final classes = parser.parseElement(
          _FakeElement('testSchema'),
          decl,
          compilationUnit: unit,
        );

        // 'Method' (no suffix) becomes 'MethodSchema' — the same
        // finalClassName as 'backupPayment''s explicit 'MethodSchema', so
        // the two dedupe to one union class carrying the first's variants.
        expect(classes.where((c) => c.name == 'MethodSchema'), hasLength(1));
        final method = classes.firstWhere((c) => c.name == 'MethodSchema');
        expect(method.unionVariants!.keys, contains('cash'));

        // Nested two levels deep (days -> DaySchema -> sections -> union),
        // the union tracks its enclosing list item as an ancestor.
        final section = classes.firstWhere((c) => c.name == 'SectionSchema');
        expect(
          section.ancestorListItems.map((c) => c.name),
          contains('DaySchema'),
        );
      },
    );
  });

  group('boolean scalar field', () {
    const parser = SchemaParser();

    test('is non-nullable by default; a bare .nullable() flips it', () {
      const source = '''
final testSchema = ks.object({
  'active': ks.boolean(),
  'archived': ks.boolean().nullable(),
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

      final active = fields.firstWhere((f) => f.name == 'active');
      expect(active.dartType, 'bool');
      expect(active.defaultValue, 'false');

      final archived = fields.firstWhere((f) => f.name == 'archived');
      expect(archived.dartType, 'bool?');
      expect(archived.defaultValue, isNull);
    });
  });

  group('_inferClassName on a private schema variable', () {
    const parser = SchemaParser();

    test('strips the leading underscore before capitalizing', () {
      const source = '''
final _internalSchema = ks.object({'name': ks.string()});
''';
      final unit = parseString(content: source).unit;
      final decl = unit.declarations.first as TopLevelVariableDeclaration;
      final classes = parser.parseElement(
        _FakeElement('_internalSchema'),
        decl,
        compilationUnit: unit,
      );

      expect(classes.first.name, 'InternalSchema');
    });
  });

  group('_resolveDartType fallback branches, reached only through a scalar list '
      'item that _parseObjectExpression could not resolve to a class', () {
    const parser = SchemaParser();

    test('an explicit generic type argument on a list of enums', () {
      const source = '''
enum Priority { low, high }

final testSchema = ks.object({
  'levels': ks.list(ks.enums<Priority>(Priority.values)),
});
''';
      final unit = parseString(content: source).unit;
      final decl = unit.declarations.last as TopLevelVariableDeclaration;
      final classes = parser.parseElement(
        _FakeElement('testSchema'),
        decl,
        compilationUnit: unit,
      );

      expect(classes.first.fields.single.listItemType, 'Priority');
    });

    test('a namespaced Foo.Bar.values access on a list of enums', () {
      const source = '''
final testSchema = ks.object({
  'levels': ks.list(ks.enums(prefix.Priority.values)),
});
''';
      final unit = parseString(content: source).unit;
      final decl = unit.declarations.first as TopLevelVariableDeclaration;
      final classes = parser.parseElement(
        _FakeElement('testSchema'),
        decl,
        compilationUnit: unit,
      );

      expect(classes.first.fields.single.listItemType, 'prefix.Priority');
    });

    test('an explicit generic type argument on a list of maps', () {
      const source = '''
final testSchema = ks.object({
  'batches': ks.list(ks.map<String, int>()),
});
''';
      final unit = parseString(content: source).unit;
      final decl = unit.declarations.first as TopLevelVariableDeclaration;
      final classes = parser.parseElement(
        _FakeElement('testSchema'),
        decl,
        compilationUnit: unit,
      );

      expect(classes.first.fields.single.listItemType, 'Map<String, int>');
    });

    test('inferred key/value validators on a list of maps', () {
      const source = '''
final testSchema = ks.object({
  'batches': ks.list(ks.map(ks.string(), ks.int())),
});
''';
      final unit = parseString(content: source).unit;
      final decl = unit.declarations.first as TopLevelVariableDeclaration;
      final classes = parser.parseElement(
        _FakeElement('testSchema'),
        decl,
        compilationUnit: unit,
      );

      expect(classes.first.fields.single.listItemType, 'Map<String, int>');
    });

    test(
      'a malformed ks.object(className: ...) missing its field map falls back to the className',
      () {
        const source = '''
final testSchema = ks.object({
  'items': ks.list(ks.object(className: 'BrokenSchema')),
});
''';
        final unit = parseString(content: source).unit;
        final decl = unit.declarations.first as TopLevelVariableDeclaration;
        final classes = parser.parseElement(
          _FakeElement('testSchema'),
          decl,
          compilationUnit: unit,
        );

        expect(classes.first.fields.single.listItemType, 'BrokenSchema');
      },
    );

    test(
      'an undeclared bare identifier falls back to its capitalized name',
      () {
        const source = '''
final testSchema = ks.object({
  'items': ks.list(someUndeclaredThing),
});
''';
        final unit = parseString(content: source).unit;
        final decl = unit.declarations.first as TopLevelVariableDeclaration;
        final classes = parser.parseElement(
          _FakeElement('testSchema'),
          decl,
          compilationUnit: unit,
        );

        expect(classes.first.fields.single.listItemType, 'SomeUndeclaredThing');
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
