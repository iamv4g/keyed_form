import 'package:keyed_form_schema/keyed_form_schema.dart';
import 'package:test/test.dart';

void main() {
  group('KSObject schema and FieldErrors mapping', () {
    test('validates nested fields and maps to correct FieldKey', () {
      final userSchema = ks.object({
        'username': ks.string().min(3, error: .text('Username too short')),
        'age': ks.int().min(18, error: .text('Must be at least 18')),
        'profile': ks.object({
          'bio': ks.string().min(5, error: .text('Bio too short')),
        }),
      });

      final invalidData = {
        'username': 'al',
        'age': 16,
        'profile': {'bio': 'hi'},
      };

      final errors = userSchema.validateMap(invalidData);
      expect(errors.length, 3);
      expect(errors.byKey(FieldKey.name('username')), 'Username too short');
      expect(errors.byKey(FieldKey.name('age')), 'Must be at least 18');
      expect(
        errors.byKey(FieldKey.name('profile') + FieldKey.name('bio')),
        'Bio too short',
      );
    });

    test('refine cross-field validation', () {
      final formSchema = ks
          .object({
            'password': ks.string().min(6),
            'confirmPassword': ks.string().min(6),
          })
          .refine(
            (data) => data['password'] == data['confirmPassword'],
            error: .text('Passwords do not match'),
            path: 'confirmPassword',
          );

      final invalid = {
        'password': 'password123',
        'confirmPassword': 'different',
      };
      final errors = formSchema.validateMap(invalid);
      expect(
        errors.byKey(FieldKey.name('confirmPassword')),
        'Passwords do not match',
      );

      final valid = {
        'password': 'password123',
        'confirmPassword': 'password123',
      };
      expect(formSchema.validateMap(valid).isEmpty, isTrue);
    });

    test(
      'refine form-level error maps to FieldKey.root when path and key are omitted',
      () {
        final formSchema = ks
            .object({
              'email': ks.string().optional().nullable(),
              'phone': ks.string().optional().nullable(),
            })
            .refine(
              (data) => data['email'] != null || data['phone'] != null,
              error: .text('At least one contact method is required'),
            );

        final invalid = {'email': null, 'phone': null};
        final errors = formSchema.validateMap(invalid);
        expect(
          errors.byKey(FieldKey.root),
          'At least one contact method is required',
        );

        final valid = {'email': 'test@example.com', 'phone': null};
        expect(formSchema.validateMap(valid).isEmpty, isTrue);
      },
    );

    test('refine with key targets deep FieldKey', () {
      final customKey =
          FieldKey.name('days') + FieldKey.id(1) + FieldKey.name('hotel');
      final formSchema = ks
          .object({})
          .refine(
            (_) => false,
            key: customKey,
            error: .text('Hotel error on day 1'),
          );

      final errors = formSchema.validateMap({});
      expect(errors.byKey(customKey), 'Hotel error on day 1');
    });

    test(
      'refine with when precondition only executes when condition is met',
      () {
        var checkExecuted = false;
        final schema = ks
            .object({
              'requiresVerification': ks.boolean(),
              'code': ks.string().optional(),
            })
            .refine(
              (data) {
                checkExecuted = true;
                return data['code'] == '1234';
              },
              when: (data) => data['requiresVerification'] == true,
              path: 'code',
              error: .text('Invalid code'),
            );

        // When false: check is skipped
        final validSkipped = {'requiresVerification': false, 'code': null};
        final errors1 = schema.validateMap(validSkipped);
        expect(errors1.isEmpty, isTrue);
        expect(checkExecuted, isFalse);

        // When true: check is executed
        final invalid = {'requiresVerification': true, 'code': 'wrong'};
        final errors2 = schema.validateMap(invalid);
        expect(errors2.byKey(FieldKey.name('code')), 'Invalid code');
        expect(checkExecuted, isTrue);
      },
    );

    test('refine with abort stops subsequent refinements upon failure', () {
      var secondRuleRan = false;
      final schema = ks
          .object({
            'start': ks.string().optional().nullable(),
            'end': ks.string().optional().nullable(),
          })
          .refine(
            (data) => data['start'] != null && data['end'] != null,
            error: .text('Both dates required'),
            path: 'start',
            abort: true,
          )
          .refine(
            (data) {
              secondRuleRan = true;
              return true;
            },
            error: .text('Should not run'),
            path: 'end',
          );

      final errors = schema.validateMap({'start': null, 'end': null});
      expect(errors.byKey(FieldKey.name('start')), 'Both dates required');
      expect(secondRuleRan, isFalse);
    });

    test('refine passes params down to KSCustomIssue', () {
      String? receivedParam;
      final schema = ks
          .object({})
          .refine(
            (_) => false,
            params: {'code': 'CUSTOM_ERR_42'},
            error: .builder((issue) {
              if (issue is KSCustomIssue) {
                receivedParam = issue.params?['code'] as String?;
              }
              return 'Error with code: $receivedParam';
            }),
          );

      final errors = schema.validateMap({});
      expect(receivedParam, 'CUSTOM_ERR_42');
      expect(errors.byKey(FieldKey.root), 'Error with code: CUSTOM_ERR_42');
    });

    test(
      'unified refine: async check works in validateMapAsync and throws KSAsyncValidationError in validateMap',
      () async {
        final schema = ks
            .object({'username': ks.string()})
            .refine(
              (data) async {
                await Future<void>.delayed(const Duration(milliseconds: 5));
                return data['username'] != 'taken';
              },
              path: 'username',
              error: .text('Username is already taken'),
            );

        // Synchronous validateMap throws KSAsyncValidationError
        expect(
          () => schema.validateMap({'username': 'taken'}),
          throwsA(isA<KSAsyncValidationError>()),
        );

        // Asynchronous validateMapAsync works as expected
        final errors = await schema.validateMapAsync({'username': 'taken'});
        expect(
          errors.byKey(FieldKey.name('username')),
          'Username is already taken',
        );

        final valid = await schema.validateMapAsync({'username': 'available'});
        expect(valid.isEmpty, isTrue);
      },
    );
  });
}
