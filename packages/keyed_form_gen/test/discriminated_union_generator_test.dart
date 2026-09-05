import 'package:keyed_form_gen/src/generators/data_class_generator.dart';
import 'package:keyed_form_gen/src/models/schema_model.dart';
import 'package:test/test.dart';

void main() {
  group('Discriminated Union & Nested Optics Generator', () {
    const dataClassGen = DataClassGenerator();

    final admissionClass = ParsedClass(
      name: 'AdmissionSectionSchema',
      schemaName: 'admissionSectionSchema',
      isListItem: true,
      fields: [
        ParsedField(name: 'sortIndex', dartType: 'int', defaultValue: '0'),
        ParsedField(name: 'targetId', dartType: 'String?'),
      ],
    );

    final transferClass = ParsedClass(
      name: 'TransferSectionSchema',
      schemaName: 'transferSectionSchema',
      isListItem: true,
      fields: [
        ParsedField(name: 'sortIndex', dartType: 'int', defaultValue: '0'),
        ParsedField(name: 'transferTargetId', dartType: 'String?'),
      ],
    );

    final sectionBaseClass = ParsedClass(
      name: 'SectionSchema',
      schemaName: 'sectionSchema',
      isListItem: true,
      isUnion: true,
      unionDiscriminator: 'category',
      unionVariants: {'admission': admissionClass, 'transfer': transferClass},
      fields: [
        ParsedField(name: 'sortIndex', dartType: 'int', defaultValue: '0'),
      ],
    );

    test('generates sealed base class for discriminated union', () {
      final code = dataClassGen.generate(sectionBaseClass);

      expect(code, contains('sealed class SectionSchema implements KeyedRow {'));
      expect(code, contains('required this.clientId,'));
      expect(code, contains('final int sortIndex;'));
      expect(code, contains('String get category;'));
      expect(
        code,
        contains('abstract interface class SectionSchemaCopyWith<T> {'),
      );
      expect(
        code,
        contains(
          'class _SectionSchemaCopyWithImpl implements SectionSchemaCopyWith<SectionSchema> {',
        ),
      );
      expect(
        code,
        contains(
          'SectionSchemaCopyWith<SectionSchema> get copyWith => _SectionSchemaCopyWithImpl(this);',
        ),
      );
      expect(code, contains('AdmissionSectionSchema x => x.copyWith'));
      expect(code, contains('TransferSectionSchema x => x.copyWith'));
      expect(code, contains('Map<String, Object?> toMap() => switch (this) {'));
      expect(
        code,
        contains('FieldErrors<String> validate() => switch (this) {'),
      );
      expect(code, contains('abstract final class SectionPrisms {'));
      expect(
        code,
        contains(
          'static final admission = Prism<SectionSchema, AdmissionSectionSchema>.type();',
        ),
      );
      expect(
        code,
        contains(
          'static final transfer = Prism<SectionSchema, TransferSectionSchema>.type();',
        ),
      );
      expect(code, contains('abstract final class SectionFields {'));
    });

    test('generates variant class extending base union class', () {
      final variantWithBase = ParsedClass(
        name: 'AdmissionSectionSchema',
        schemaName: 'admissionSectionSchema',
        isListItem: true,
        unionBaseClass: sectionBaseClass,
        unionDiscriminatorValue: 'admission',
        fields: [
          ParsedField(name: 'sortIndex', dartType: 'int', defaultValue: '0'),
          ParsedField(name: 'targetId', dartType: 'String?'),
        ],
      );

      final code = dataClassGen.generate(variantWithBase);

      expect(
        code,
        contains('class AdmissionSectionSchema extends SectionSchema {'),
      );
      expect(code, contains('required super.clientId,'));
      expect(code, contains('super.sortIndex = 0,'));
      expect(code, contains('this.targetId,'));
      expect(code, contains('final String? targetId;'));
      expect(code, contains("String get category => 'admission';"));
      expect(code, contains("'category': category,"));
      expect(
        code,
        contains(
          'abstract interface class AdmissionSectionSchemaCopyWith<T> implements SectionSchemaCopyWith<T> {',
        ),
      );
      expect(
        code,
        contains(
          'class _AdmissionSectionSchemaCopyWithImpl implements AdmissionSectionSchemaCopyWith<AdmissionSectionSchema> {',
        ),
      );
      expect(
        code,
        contains(
          '@override\n'
          '  AdmissionSectionSchemaCopyWith<AdmissionSectionSchema> get copyWith => _AdmissionSectionSchemaCopyWithImpl(this);',
        ),
      );
      expect(code, contains('abstract final class AdmissionSectionFields {'));
      expect(
        code,
        contains(
          'static Lens<AdmissionSectionSchema, String?> get targetId =>',
        ),
      );
    });


    test('recursive nested navigators return field-name FieldRefs wrappers', () {
      final admissionClass = ParsedClass(
        name: 'AdmissionSchema',
        schemaName: 'admissionSchema',
        isListItem: true,
        fields: [ParsedField(name: 'targetId', dartType: 'String?')],
      );
      final sectionClass = ParsedClass(
        name: 'SectionSchema',
        schemaName: 'sectionSchema',
        isListItem: true,
        fields: [
          ParsedField(
            name: 'admissions',
            dartType: 'List<AdmissionSchema>',
            isList: true,
            nestedClass: admissionClass,
          ),
        ],
      );
      final groupClass = ParsedClass(
        name: 'GroupSchema',
        schemaName: 'groupSchema',
        isListItem: true,
        fields: [
          ParsedField(
            name: 'sections',
            dartType: 'List<SectionSchema>',
            isList: true,
            nestedClass: sectionClass,
          ),
        ],
      );
      final dayClass = ParsedClass(
        name: 'DaySchema',
        schemaName: 'daySchema',
        isListItem: true,
        fields: [
          ParsedField(name: 'name', dartType: 'String', defaultValue: "''"),
          ParsedField(
            name: 'groups',
            dartType: 'List<GroupSchema>',
            isList: true,
            nestedClass: groupClass,
          ),
        ],
      );
      final rootClass = ParsedClass(
        name: 'ItineraryBuilderSchema',
        schemaName: 'itineraryBuilderSchema',
        isListItem: false,
        fields: [
          ParsedField(
            name: 'days',
            dartType: 'List<DaySchema>',
            isList: true,
            nestedClass: dayClass,
          ),
        ],
      );

      final code = dataClassGen.generate(rootClass);

      // Navigators keyed by field name, taking an inline ({String seg,…}) record.
      expect(
        code,
        contains('static DayFieldRefs day(DayRef at) =>'),
      );
      expect(
        code,
        contains('DayFieldRefs(days.at(at.day, (x) => x.clientId == at.day))'),
      );
      expect(
        code,
        contains('static GroupFieldRefs group(GroupRef at) =>'),
      );
      expect(
        code,
        contains('static SectionFieldRefs section(SectionRef at) =>'),
      );
      expect(
        code,
        contains('static AdmissionFieldRefs admission(AdmissionRef at) =>'),
      );

      // Leaf getters live on the wrapper.
      expect(
        code,
        contains(
          'FieldRef<ItineraryBuilderSchema, String> get name =>\n'
          '      _self.then(DayFields.name);',
        ),
      );
      expect(
        code,
        contains(
          'FieldRef<ItineraryBuilderSchema, String?> get targetId =>\n'
          '      _self.then(AdmissionFields.targetId);',
        ),
      );

      // No generated ClientId / Ref types anymore.
      expect(code, contains('typedef DayRef = ({String day});'));
      expect(code, contains('typedef AdmissionRef = ({String day, String group, String section, String admission});'));
      expect(code, isNot(contains('extension type const')));
      
    });

    test('union wrapper narrows through prisms into variant sub-wrappers', () {
      final transferDetailsClass = ParsedClass(
        name: 'TransferDetailsSchema',
        schemaName: 'transferDetailsSchema',
        fields: [
          ParsedField(name: 'vehicle', dartType: 'String', defaultValue: "''"),
        ],
      );
      final admissionVariant = ParsedClass(
        name: 'AdmissionSectionSchema',
        schemaName: 'admissionSectionSchema',
        isListItem: true,
        unionDiscriminatorValue: 'admission',
        fields: [
          ParsedField(name: 'sortIndex', dartType: 'int', defaultValue: '0'),
          ParsedField(name: 'targetId', dartType: 'String?'),
        ],
      );
      final transferVariant = ParsedClass(
        name: 'TransferSectionSchema',
        schemaName: 'transferSectionSchema',
        isListItem: true,
        unionDiscriminatorValue: 'transfer',
        fields: [
          ParsedField(name: 'sortIndex', dartType: 'int', defaultValue: '0'),
          ParsedField(
            name: 'details',
            dartType: 'TransferDetailsSchema?',
            isNestedObject: true,
            nestedClass: transferDetailsClass,
            isNullable: true,
          ),
        ],
      );
      final sectionUnionClass = ParsedClass(
        name: 'SectionSchema',
        schemaName: 'sectionSchema',
        isListItem: true,
        isUnion: true,
        unionDiscriminator: 'category',
        unionVariants: {
          'admission': admissionVariant,
          'transfer': transferVariant,
        },
        fields: [
          ParsedField(name: 'sortIndex', dartType: 'int', defaultValue: '0'),
        ],
      );
      final dayClass = ParsedClass(
        name: 'DaySchema',
        schemaName: 'daySchema',
        isListItem: true,
        fields: [
          ParsedField(
            name: 'sections',
            dartType: 'List<SectionSchema>',
            isList: true,
            nestedClass: sectionUnionClass,
          ),
        ],
      );
      final rootClass = ParsedClass(
        name: 'PlanSchema',
        schemaName: 'planSchema',
        isListItem: false,
        fields: [
          ParsedField(
            name: 'days',
            dartType: 'List<DaySchema>',
            isList: true,
            nestedClass: dayClass,
          ),
        ],
      );

      final code = dataClassGen.generate(rootClass);

      // Union base wrapper: common field + `.asVariant` narrowers.
      expect(
        code,
        contains(
          'final class SectionFieldRefs extends AffineLens<PlanSchema, SectionSchema> {',
        ),
      );
      expect(
        code,
        contains(
          'FieldRef<PlanSchema, int> get sortIndex =>\n'
          '      _self.then(SectionFields.sortIndex);',
        ),
      );
      expect(
        code,
        contains(
          'TransferSectionFieldRefs get asTransfer =>\n'
          '      TransferSectionFieldRefs(_self.narrow(SectionPrisms.transfer));',
        ),
      );
      expect(
        code,
        contains(
          'AdmissionSectionFieldRefs get asAdmission =>\n'
          '      AdmissionSectionFieldRefs(_self.narrow(SectionPrisms.admission));',
        ),
      );

      // Variant sub-wrapper only carries the fields it adds over the base,
      // and a nullable nested object refines through `.whenPresent()`.
      expect(
        code,
        contains(
          'final class TransferSectionFieldRefs extends AffineLens<PlanSchema, TransferSectionSchema> {',
        ),
      );
      expect(
        code,
        contains(
          'DetailsFieldRefs get details =>\n'
          '      DetailsFieldRefs(_self.then(TransferSectionFields.details)'
          '.whenPresent());',
        ),
      );
      expect(
        code,
        contains(
          'FieldRef<PlanSchema, String> get vehicle =>\n'
          '      _self.then(TransferDetailsFields.vehicle);',
        ),
      );
    });
  });
}
