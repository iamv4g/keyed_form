import 'package:keyed_form_core/keyed_form_core.dart';
import 'package:test/test.dart';

void main() {
  group('FieldErrors', () {
    final nameRef = StrictFieldRef<(String,), String>.of(
      key: FieldKey.name('name'),
      get: (r) => r.$1,
      set: (r, v) => (v,),
    );

    test('looks an entry up by field reference, hiding FieldKey', () {
      final errors = FieldErrors({nameRef.key: 'required'});
      expect(errors(nameRef), 'required');
      expect(errors.byKey(FieldKey.name('name')), 'required');
      expect(errors.length, 1);
      expect(errors.isNotEmpty, isTrue);
    });

    test('empty has no matches', () {
      const errors = FieldErrors<String>.empty();
      expect(errors(nameRef), isNull);
      expect(errors.isEmpty, isTrue);
    });
  });
}
