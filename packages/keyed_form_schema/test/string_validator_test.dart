import 'package:keyed_form_schema/keyed_form_schema.dart';
import 'package:test/test.dart';

void main() {
  group('KSString validator', () {
    test('min and max length validation default messages', () {
      final validator = ks.string().min(3).max(5);

      expect(validator.validate('ab'), 'Must be at least 3 characters');
      expect(validator.validate('abc'), isNull);
      expect(validator.validate('abcde'), isNull);
      expect(validator.validate('abcdef'), 'Must be at most 5 characters');
    });

    test('required and optional behavior', () {
      final req = ks.string();
      expect(req.validate(null), 'Required');
      expect(req.validate(''), 'Required');
      expect(req.validate('   '), 'Required');
      expect(req.validate('hello'), isNull);

      final opt = ks.string().min(3).optional();
      expect(opt.validate(null), isNull);
      expect(opt.validate(''), isNull);
      expect(opt.validate('ab'), 'Must be at least 3 characters');
      expect(opt.validate('abc'), isNull);
    });

    test('email validation default message', () {
      final validator = ks.string().email();
      expect(validator.validate('test'), 'Invalid email address');
      expect(validator.validate('test@'), 'Invalid email address');
      expect(validator.validate('test@example.com'), isNull);
    });

    test('numeric validation default message', () {
      final validator = ks.string().numeric();
      expect(validator.validate('abc'), 'Must be a number');
      expect(validator.validate('123'), isNull);
      expect(validator.validate('123.45'), isNull);
      expect(validator.validate('-99.5'), isNull);
    });

    test('time format validation (HH:mm) default message', () {
      final validator = ks.string().time();
      expect(validator.validate('25:00'), 'Time format must be HH:mm');
      expect(validator.validate('12:60'), 'Time format must be HH:mm');
      expect(validator.validate('08:30'), isNull);
      expect(validator.validate('23:59'), isNull);
    });

    test('sync and async refine', () async {
      final syncValidator = ks.string().refine(
        (v) => v != 'admin',
        error: .text('Admin name is forbidden'),
      );

      expect(syncValidator.validate('admin'), 'Admin name is forbidden');
      expect(syncValidator.validate('user'), isNull);

      final asyncValidator = syncValidator.refine(
        (v) async => v != 'root',
        error: .text('Root name is forbidden'),
      );

      expect(
        await asyncValidator.validateAsync('root'),
        'Root name is forbidden',
      );
      expect(await asyncValidator.validateAsync('user'), isNull);
    });

    test('refine with when and abort', () {
      var secondRuleRan = false;
      final validator = ks
          .string()
          .refine(
            (v) => v != 'skip',
            when: (v) => v != 'ignore',
            error: .text('Forbidden skip'),
            abort: true,
          )
          .refine((v) {
            secondRuleRan = true;
            return v != 'another';
          }, error: .text('Forbidden another'));

      // when condition skips check
      expect(validator.validate('ignore'), isNull);
      expect(
        secondRuleRan,
        isTrue,
      ); // second rule ran because first was skipped

      // check runs and fails, aborts second check
      secondRuleRan = false;
      expect(validator.validate('skip'), 'Forbidden skip');
      expect(secondRuleRan, isFalse);
    });

    test(
      'refine throws KSAsyncValidationError when async rule evaluated synchronously',
      () {
        final validator = ks.string().refine(
          (v) async => v == 'valid',
          error: .text('Must be valid'),
        );

        expect(
          () => validator.validate('invalid'),
          throwsA(isA<KSAsyncValidationError>()),
        );
      },
    );

    test('supports i18n callback message with KSError.builder', () {
      var currentLocale = 'en';
      String getUsernameError() =>
          currentLocale == 'vi' ? 'Tên bắt buộc' : 'Username required';

      final validator = ks.string(error: .builder((_) => getUsernameError()));

      expect(validator.validate(''), 'Username required');

      // Change locale dynamically
      currentLocale = 'vi';
      expect(validator.validate(''), 'Tên bắt buộc');
    });
  });
}
