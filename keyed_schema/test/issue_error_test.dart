import 'package:keyed_schema/keyed_schema.dart';
import 'package:test/test.dart';

void main() {
  group('KSIssue and KSError system', () {
    test('KSError.text returns constant message', () {
      final v = ks.string(error: .text('Custom Required'));
      expect(v.validate(null), 'Custom Required');
      expect(v.validate(''), 'Custom Required');
    });

    test('KSError.builder evaluates getter dynamically', () {
      var lang = 'en';
      final v = ks.int(
        error: .builder(
          (_) => lang == 'vi' ? 'Tuổi là bắt buộc' : 'Age required',
        ),
      );

      expect(v.validate(null), 'Age required');
      lang = 'vi';
      expect(v.validate(null), 'Tuổi là bắt buộc');
    });

    test('KSError.builder matches KSIssue subclasses and handles issues', () {
      final v = ks
          .string(
            error: .builder((issue) {
              return switch (issue) {
                KSInvalidTypeIssue() => 'Please provide a value',
                KSTooSmallIssue(:final minimum) =>
                  'Too short! Need at least $minimum chars',
                KSTooBigIssue(:final maximum) => 'Too long! Max is $maximum',
                _ => null, // fallback to default
              };
            }),
          )
          .min(3)
          .max(10);

      expect(v.validate(null), 'Please provide a value');
      expect(v.validate('a'), 'Too short! Need at least 3 chars');
      expect(v.validate('abcdefghijkl'), 'Too long! Max is 10');
      expect(v.validate('valid'), isNull);
    });

    test('KSError.builder returning null falls back to issue.message', () {
      final v = ks
          .string(
            error: .builder((issue) {
              if (issue is KSInvalidTypeIssue) return 'Missing field';
              return null; // fallback for min/max
            }),
          )
          .min(5);

      expect(v.validate(null), 'Missing field');
      // For min length, builder returns null, so it falls back to default KSTooSmallIssue.message
      expect(v.validate('abc'), 'Must be at least 5 characters');
    });

    test('Rule-level error takes precedence over factory-level error', () {
      final v = ks
          .string(error: .text('Factory error'))
          .min(3, error: .text('Rule min error'));

      // Missing field uses factory error
      expect(v.validate(null), 'Factory error');

      // Failing min(3) uses rule min error, NOT factory error
      expect(v.validate('a'), 'Rule min error');
    });

    test(
      'validateIssue returns strongly-typed KSIssue instances with enums',
      () {
        final strValidator = ks.string().min(5).max(10).email();

        final nullIssue = strValidator.validateIssue(null);
        expect(nullIssue, isA<KSInvalidTypeIssue>());
        expect(nullIssue!.code, KSIssueCode.invalidType);
        expect((nullIssue as KSInvalidTypeIssue).expected, 'string');

        final tooSmall = strValidator.validateIssue('abc');
        expect(tooSmall, isA<KSTooSmallIssue>());
        expect(tooSmall!.code, KSIssueCode.tooSmall);
        expect((tooSmall as KSTooSmallIssue).origin, KSIssueOrigin.string);
        expect(tooSmall.minimum, 5);

        final tooBig = strValidator.validateIssue(
          'this is too long for the field',
        );
        expect(tooBig, isA<KSTooBigIssue>());
        expect(tooBig!.code, KSIssueCode.tooBig);
        expect((tooBig as KSTooBigIssue).origin, KSIssueOrigin.string);
        expect(tooBig.maximum, 10);

        final invalidEmail = strValidator.validateIssue('abcdefg');
        expect(invalidEmail, isA<KSInvalidFormatIssue>());
        expect(invalidEmail!.code, KSIssueCode.invalidFormat);
        expect(
          (invalidEmail as KSInvalidFormatIssue).format,
          KSStringFormat.email,
        );
      },
    );
  });
}
