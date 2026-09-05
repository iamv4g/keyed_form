import 'package:test/test.dart';

import 'fixtures/function_schema.dart';

void main() {
  group('Function Schema generator', () {
    test('validates correctly using generated function caller', () {
      const invalidDraft = LoginSchema(username: '', password: '');
      final errors = invalidDraft.validate();

      expect(errors.length, 2);
      expect(
        errors.byKey(LoginFields.username.key),
        'Username is required',
      );
      expect(
        errors.byKey(LoginFields.password.key),
        'Password is required',
      );

      const validDraft = LoginSchema(
        username: 'admin',
        password: 'password123',
      );
      final validErrors = LoginSchema.validateData(validDraft);
      expect(validErrors.isEmpty, true);
    });
  });
}
