import 'package:test/test.dart';

import 'fixtures/auth_schema.dart';

void main() {
  group('Generated AuthSchema & Fields & Validator', () {
    test('instantiates and uses lenses via AuthFields', () {
      var draft = const AuthSchema(
        username: 'admin',
        password: 'secretpassword',
        remember: true,
      );

      expect(AuthFields.username.get(draft), 'admin');
      expect(AuthFields.password.get(draft), 'secretpassword');
      expect(AuthFields.remember.get(draft), true);

      draft = AuthFields.username.set(draft, 'newuser');
      expect(draft.username, 'newuser');
    });

    test(
      'validates valid and invalid draft via draft.validate() and static validate',
      () {
        const invalidDraft = AuthSchema(username: 'al', password: '123');
        final errors = invalidDraft.validate();

        expect(errors.length, 2);
        expect(errors.byKey(AuthFields.username.key), 'Minimum 3 characters');
        expect(errors.byKey(AuthFields.password.key), 'Minimum 6 characters');

        const validDraft = AuthSchema(
          username: 'alex',
          password: 'strongpassword',
        );
        final validErrors = AuthSchema.validateData(validDraft);
        expect(validErrors.isEmpty, true);
      },
    );
  });
}
