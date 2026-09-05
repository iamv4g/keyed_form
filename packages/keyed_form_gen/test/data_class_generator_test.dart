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
        contains('static Lens<HotelSchema, String?> get hotelName =>'),
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

    test('generates primary constructor without clientId for root form and includes validate()', () {
      final parsedClass = ParsedClass(
        name: 'LoginSchema',
        schemaName: 'loginSchema',
        isListItem: false,
        fields: [
          ParsedField(name: 'username', dartType: 'String', defaultValue: "''"),
          ParsedField(name: 'password', dartType: 'String', defaultValue: "''"),
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
        contains('static Lens<LoginSchema, String> get username =>'),
      );
      expect(
        code,
        contains(
          'FieldErrors<String> validate() => loginSchema.validateMap(toMap());',
        ),
      );
      expect(
        code,
        contains(
          'Future<FieldErrors<String>> validateAsync() => loginSchema.validateMapAsync(toMap());',
        ),
      );
      expect(
        code,
        contains(
          'static FieldErrors<String> validateData(LoginSchema schema) => schema.validate();',
        ),
      );
    });

    test(
      'copyWith interface is fully typed, the impl still uses the _unset '
      'sentinel, and == / hashCode use _mapEquals / _mapHash for Map fields',
      () {
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
        expect(
          code,
          contains('_listEquals(confirmedDays, other.confirmedDays)'),
        );
        expect(code, contains('_mapEquals(dayNotes, other.dayNotes)'));
        expect(code, contains('Object.hashAll(confirmedDays)'));
        expect(code, contains('_mapHash(dayNotes)'));
      },
    );
  });
}
