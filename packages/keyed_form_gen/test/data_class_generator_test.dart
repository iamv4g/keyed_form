import 'package:keyed_form_gen/src/generators/data_class_generator.dart';
import 'package:keyed_form_gen/src/models/schema_model.dart';
import 'package:test/test.dart';

void main() {
  group('DataClassGenerator', () {
    const generator = DataClassGenerator();

    test('generates primary constructor with auto clientId for list items', () {
      final parsedClass = ParsedClass(
        name: 'HotelSchema',
        schemaName: 'hotelSchema',
        isListItem: true,
        fields: [
          ParsedField(name: 'hotelName', dartType: 'String?'),
          ParsedField(
            name: 'hotelPrice',
            dartType: 'String?',
            isOptional: true,
          ),
          ParsedField(name: 'prefectureId', dartType: 'int?', isNullable: true),
        ],
      );

      final code = generator.generate(parsedClass);

      expect(code, contains('class HotelSchema implements KeyedRow {'));
      expect(code, contains('required this.clientId,'));
      expect(code, contains('final String? hotelName;'));
      expect(code, contains('abstract final class HotelFields {'));
      expect(
        code,
        contains(
          'static StrictFieldRef<HotelSchema, String?> get hotelName =>',
        ),
      );
      expect(code, contains('factory HotelSchema.create({'));
      expect(
        code,
        contains('abstract interface class HotelSchemaCopyWith<T> {'),
      );
      expect(
        code,
        contains(
          'class _HotelSchemaCopyWithImpl implements HotelSchemaCopyWith<HotelSchema> {',
        ),
      );
      expect(
        code,
        contains(
          'HotelSchemaCopyWith<HotelSchema> get copyWith => _HotelSchemaCopyWithImpl(this);',
        ),
      );
      expect(code, contains('Map<String, Object?> toMap() => {'));
      expect(code, contains('bool operator ==(Object other)'));
      expect(code, contains('int get hashCode =>'));
    });

    test(
      'generates primary constructor without clientId for root form and includes validate()',
      () {
        final parsedClass = ParsedClass(
          name: 'LoginSchema',
          schemaName: 'loginSchema',
          isListItem: false,
          fields: [
            ParsedField(
              name: 'username',
              dartType: 'String',
              defaultValue: "''",
            ),
            ParsedField(
              name: 'password',
              dartType: 'String',
              defaultValue: "''",
            ),
            ParsedField(
              name: 'remember',
              dartType: 'bool',
              defaultValue: 'false',
            ),
          ],
        );

        final code = generator.generate(parsedClass);

        expect(code, contains('class LoginSchema {'));
        expect(code, isNot(contains('clientId')));
        expect(code, contains("this.username = '',"));
        expect(code, contains("this.password = '',"));
        expect(code, contains('this.remember = false,'));
        expect(code, contains('abstract final class LoginFields {'));
        expect(
          code,
          contains(
            'static StrictFieldRef<LoginSchema, String> get username =>',
          ),
        );
        expect(
          code,
          contains(
            'FieldErrors<String> validate([FieldKey? scope]) => '
            'loginSchema.validateValues(_validationValues, scope: scope);',
          ),
        );
        expect(
          code,
          contains(
            'Future<FieldErrors<String>> validateAsync([FieldKey? scope]) => '
            'loginSchema.validateValuesAsync(_validationValues, scope: scope);',
          ),
        );
        expect(code, contains('List<Object?> get _validationValues => ['));
        expect(
          code,
          contains(
            'static FieldErrors<String> validateData(LoginSchema schema, '
            '[FieldKey? scope]) => schema.validate(scope);',
          ),
        );
        expect(
          code,
          contains(
            'static FieldKey? scopeOf(FieldKey writtenKey) => '
            'rowScopeOf(writtenKey);',
          ),
        );
      },
    );

    test('copyWith interface is fully typed, the impl still uses the _unset '
        'sentinel, and == / hashCode use _mapEquals / _mapHash for Map fields', () {
      final parsedClass = ParsedClass(
        name: 'TripSchema',
        schemaName: 'tripSchema',
        // isListItem: true auto-adds `clientId` — String, required, no
        // default. Its non-nullable-with-no-default shape is treated
        // exactly like `status` below (any non-nullable field, default
        // or not) — plain nullable param + `??`, no sentinel needed.
        isListItem: true,
        fields: [
          ParsedField(name: 'title', dartType: 'String', defaultValue: "''"),
          ParsedField(
            name: 'confirmedDays',
            dartType: 'List<int>',
            defaultValue: 'const []',
          ),
          ParsedField(
            name: 'dayNotes',
            dartType: 'Map<String, int>',
            defaultValue: 'const {}',
          ),
          ParsedField(name: 'ownerNote', dartType: 'String?'),
          // Required, non-nullable, no default, not clientId — proves
          // the plain-nullable-plus-`??` treatment isn't special-cased
          // to `clientId`/String; it applies to *every* non-nullable
          // field uniformly, so this (or an enum, or a nested object)
          // is handled exactly the same way, with no dummy value needed.
          ParsedField(name: 'status', dartType: 'String'),
        ],
      );

      final code = generator.generate(parsedClass);

      // Public interface: every non-nullable field — with a schema
      // default (title/confirmedDays/dayNotes) or without one
      // (clientId/status) alike — is nullable-wrapped, matching
      // dart_mappable's own treatment of this exact distinction
      // (tour_guide_builder.mapper.dart: dateIndexes/guideIdsByDay are
      // non-nullable *with* a default and still just `List<int>?`/
      // `Map<int,int>?`, no dummy/real default baked into the
      // interface). Only `ownerNote` (genuinely nullable) needs the
      // sentinel-based treatment below — never bare Object? for any
      // field either way.
      expect(
        code,
        contains(
          'abstract interface class TripSchemaCopyWith<T> {\n'
          '  T call({\n'
          '    String? clientId,\n'
          '    String? title,\n'
          '    List<int>? confirmedDays,\n'
          '    Map<String, int>? dayNotes,\n'
          '    String? ownerNote,\n'
          '    String? status,\n'
          '  });\n'
          '}',
        ),
      );

      // Private impl: non-nullable fields resolve via plain `??` (no
      // sentinel, no cast); only the nullable field keeps the
      // Object?/_unset/identical/cast treatment.
      expect(
        code,
        contains(
          'class _TripSchemaCopyWithImpl implements TripSchemaCopyWith<TripSchema> {',
        ),
      );
      expect(code, contains('String? clientId,'));
      expect(code, contains('clientId: clientId ?? _value.clientId,'));
      expect(code, contains('String? title,'));
      expect(code, contains('title: title ?? _value.title,'));
      expect(code, contains('List<int>? confirmedDays,'));
      expect(
        code,
        contains('confirmedDays: confirmedDays ?? _value.confirmedDays,'),
      );
      expect(code, contains('String? status,'));
      expect(code, contains('status: status ?? _value.status,'));
      expect(code, contains('Object? ownerNote = _unset,'));
      expect(
        code,
        contains(
          'ownerNote: identical(ownerNote, _unset) ? _value.ownerNote : ownerNote as String?,',
        ),
      );
      expect(code, isNot(contains('Object? clientId = _unset,')));
      expect(code, isNot(contains('Object? title = _unset,')));

      // The getter — no plain `TripSchema copyWith(` method left.
      expect(
        code,
        contains(
          'TripSchemaCopyWith<TripSchema> get copyWith => _TripSchemaCopyWithImpl(this);',
        ),
      );
      expect(code, isNot(contains('TripSchema copyWith(')));

      // == / hashCode: List → _listEquals/Object.hashAll (existing),
      // Map → the new _mapEquals/_mapHash.
      expect(code, contains('_listEquals(confirmedDays, other.confirmedDays)'));
      expect(code, contains('_mapEquals(dayNotes, other.dayNotes)'));
      expect(code, contains('Object.hashAll(confirmedDays)'));
      expect(code, contains('_mapHash(dayNotes)'));
    });

    test(
      'a root non-list nested-object field gets its own FieldRefs wrapper (toMap + Fields)',
      () {
        final infoClass = ParsedClass(
          name: 'TourInfoSchema',
          schemaName: 'tourInfoSchema',
          fields: [
            ParsedField(name: 'name', dartType: 'String', defaultValue: "''"),
          ],
        );
        final rootClass = ParsedClass(
          name: 'TourSchema',
          schemaName: 'tourSchema',
          fields: [
            ParsedField(
              name: 'info',
              dartType: 'TourInfoSchema',
              isNestedObject: true,
              nestedClass: infoClass,
            ),
            ParsedField(
              name: 'altInfo',
              dartType: 'TourInfoSchema?',
              isNestedObject: true,
              isNullable: true,
              nestedClass: infoClass,
            ),
          ],
        );

        final code = generator.generate(rootClass);

        // toMap: a nested-object field maps through its own toMap().
        expect(code, contains("'info': info?.toMap(),"));

        // Fields: a non-nullable nested field is a plain lens; a nullable one
        // refines through .whenPresent(). The wrapper name derives from the
        // *field* name ('info'), not the nested class's own name.
        expect(
          code,
          contains('static InfoFieldRefs get info => InfoFieldRefs('),
        );
        expect(code, contains("key: FieldKey.name('info'),"));
        expect(
          code,
          contains('static AltInfoFieldRefs get altInfo => AltInfoFieldRefs('),
        );
        expect(code, contains(').whenPresent(),'));

        // The nested wrapper class itself, with a leaf getter for `name`.
        expect(
          code,
          contains(
            'final class InfoFieldRefs extends DelegatingFieldRef<TourSchema, TourInfoSchema> {',
          ),
        );
        expect(
          code,
          contains(
            'FieldRef<TourSchema, String> get name =>\n'
            '      inner.then(TourInfoFields.name);',
          ),
        );
      },
    );

    test(
      'a field name colliding with the FieldRef API throws a clear StateError',
      () {
        final rootClass = ParsedClass(
          name: 'BadSchema',
          schemaName: 'badSchema',
          fields: [
            ParsedField(
              name: 'inner',
              dartType: 'InnerSchema',
              isNestedObject: true,
              nestedClass: ParsedClass(
                name: 'InnerSchema',
                schemaName: 'innerSchema',
                fields: [ParsedField(name: 'hashCode', dartType: 'int')],
              ),
            ),
          ],
        );

        expect(
          () => generator.generate(rootClass),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains("field 'hashCode'"),
            ),
          ),
        );
      },
    );

    test(
      '_singularizeField: "ies" and the (ss|x|z|ch|sh)es regex branches, via list navigators',
      () {
        final categoryClass = ParsedClass(
          name: 'CategorySchema',
          schemaName: 'categorySchema',
          isListItem: true,
          fields: [
            ParsedField(name: 'label', dartType: 'String', defaultValue: "''"),
          ],
        );
        final boxClass = ParsedClass(
          name: 'BoxSchema',
          schemaName: 'boxSchema',
          isListItem: true,
          fields: [
            ParsedField(name: 'weight', dartType: 'int', defaultValue: '0'),
          ],
        );
        final rootClass = ParsedClass(
          name: 'CatalogSchema',
          schemaName: 'catalogSchema',
          fields: [
            ParsedField(
              name: 'categories',
              dartType: 'List<CategorySchema>',
              isList: true,
              nestedClass: categoryClass,
            ),
            ParsedField(
              name: 'boxes',
              dartType: 'List<BoxSchema>',
              isList: true,
              nestedClass: boxClass,
            ),
          ],
        );

        final code = generator.generate(rootClass);

        // 'categories' ('ies' branch) -> navigator 'category'.
        expect(
          code,
          contains('static CategoryFieldRefs category(CategoryRef at) =>'),
        );
        // 'boxes' (regex '(ss|x|z|ch|sh)es$' branch) -> navigator 'box'.
        expect(code, contains('static BoxFieldRefs box(BoxRef at) =>'));
      },
    );

    test(
      'a two-level-deep non-list nested-object chain recurses to emit both wrappers',
      () {
        final detailClass = ParsedClass(
          name: 'DetailSchema',
          schemaName: 'detailSchema',
          fields: [
            ParsedField(name: 'note', dartType: 'String', defaultValue: "''"),
          ],
        );
        final infoClass = ParsedClass(
          name: 'InfoSchema',
          schemaName: 'infoSchema',
          fields: [
            ParsedField(
              name: 'detail',
              dartType: 'DetailSchema',
              isNestedObject: true,
              nestedClass: detailClass,
            ),
          ],
        );
        final rootClass = ParsedClass(
          name: 'RootSchema',
          schemaName: 'rootSchema',
          fields: [
            ParsedField(
              name: 'info',
              dartType: 'InfoSchema',
              isNestedObject: true,
              nestedClass: infoClass,
            ),
          ],
        );

        final code = generator.generate(rootClass);

        expect(
          code,
          contains(
            'final class InfoFieldRefs extends DelegatingFieldRef<RootSchema, InfoSchema> {',
          ),
        );
        expect(
          code,
          contains(
            'final class DetailFieldRefs extends DelegatingFieldRef<RootSchema, DetailSchema> {',
          ),
        );
        expect(
          code,
          contains(
            'FieldRef<RootSchema, String> get note =>\n'
            '      inner.then(DetailFields.note);',
          ),
        );
      },
    );

    test(
      'a class name ending in literal "Schema" under a custom suffix falls back correctly',
      () {
        // DataClassGenerator's naming helpers accept `name`/`suffix`
        // independently of SchemaParser — this exercises the '...Schema'
        // fallback a caller hits when the class name doesn't end with the
        // active suffix (SchemaParser's own pipeline always keeps them in
        // sync, but DataClassGenerator's public API does not assume that).
        final parsedClass = ParsedClass(
          name: 'LegacyThingSchema',
          schemaName: 'legacyThingSchema',
          fields: [
            ParsedField(name: 'label', dartType: 'String', defaultValue: "''"),
          ],
        );

        final code = generator.generate(parsedClass, suffix: 'Model');

        expect(code, contains('abstract final class LegacyThingFields {'));
      },
    );

    test(
      'hashCode: zero fields, a single Map field, and more than 20 fields',
      () {
        final empty = generator.generate(
          ParsedClass(
            name: 'EmptySchema',
            schemaName: 'emptySchema',
            fields: [],
          ),
        );
        expect(empty, contains('int get hashCode => 0;'));

        final singleMap = generator.generate(
          ParsedClass(
            name: 'TagsSchema',
            schemaName: 'tagsSchema',
            fields: [
              ParsedField(
                name: 'tags',
                dartType: 'Map<String, int>',
                defaultValue: 'const {}',
              ),
            ],
          ),
        );
        expect(singleMap, contains('int get hashCode => _mapHash(tags);'));

        final manyFields = generator.generate(
          ParsedClass(
            name: 'WideSchema',
            schemaName: 'wideSchema',
            fields: [
              for (var i = 0; i < 21; i++)
                ParsedField(name: 'f$i', dartType: 'int', defaultValue: '0'),
            ],
          ),
        );
        expect(manyFields, contains('int get hashCode => Object.hashAll(['));
        expect(manyFields, contains('    f0,'));
        expect(manyFields, contains('    f20,'));
      },
    );
  });
}
