import 'package:keyed_form_schema/keyed_form_schema.dart';
import 'package:test/test.dart';

void main() {
  group('KSDiscriminatedUnion', () {
    final admissionSchema = ks.object({
      'targetId': ks.string().min(2, error: .text('Spot is required')),
      'name': ks.string().optional(),
    });

    final transferSchema = ks.object({
      'targetId': ks.string().min(2, error: .text('Transfer is required')),
      'type': ks.string().optional(),
    });

    final sectionUnion = ks.discriminatedUnion('category', {
      'admission': admissionSchema,
      'transfer': transferSchema,
    }, className: 'SectionSchema');

    test('validates matching variant correctly', () {
      final validAdmission = {'category': 'admission', 'targetId': 'spot-1'};
      expect(sectionUnion.validateMap(validAdmission).isEmpty, isTrue);

      final invalidAdmission = {'category': 'admission', 'targetId': 's'};
      final admissionErrors = sectionUnion.validateMap(invalidAdmission);
      expect(
        admissionErrors.byKey(FieldKey.name('targetId')),
        'Spot is required',
      );

      final validTransfer = {'category': 'transfer', 'targetId': 'train-1'};
      expect(sectionUnion.validateMap(validTransfer).isEmpty, isTrue);

      final invalidTransfer = {'category': 'transfer', 'targetId': 't'};
      final transferErrors = sectionUnion.validateMap(invalidTransfer);
      expect(
        transferErrors.byKey(FieldKey.name('targetId')),
        'Transfer is required',
      );
    });

    test('errors on missing or unknown discriminator', () {
      final missingDisc = {'targetId': 'spot-1'};
      final errors1 = sectionUnion.validateMap(missingDisc);
      expect(errors1.byKey(FieldKey.name('category')) != null, isTrue);

      final unknownDisc = {'category': 'unknown', 'targetId': 'spot-1'};
      final errors2 = sectionUnion.validateMap(unknownDisc);
      expect(errors2.byKey(FieldKey.name('category')) != null, isTrue);
    });

    test('validates correctly inside KSList with prefix and clientId', () {
      final groupSchema = ks.object({'sections': ks.list(sectionUnion)});

      final data = {
        'sections': [
          {'clientId': 's1', 'category': 'admission', 'targetId': 'spot-1'},
          {
            'clientId': 's2',
            'category': 'transfer',
            'targetId': 'x', // Invalid, min 2
          },
        ],
      };

      final errors = groupSchema.validateMap(data);
      expect(errors.length, 1);
      final expectedKey =
          FieldKey.name('sections') +
          FieldKey.id('s2') +
          FieldKey.name('targetId');
      expect(errors.byKey(expectedKey), 'Transfer is required');
    });
  });
}
