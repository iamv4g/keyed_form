import 'package:keyed_form_gen/src/models/schema_model.dart';
import 'package:test/test.dart';

void main() {
  group('ParsedField.nonNullDartType', () {
    test('strips a single trailing "?" from a nullable type', () {
      final field = ParsedField(name: 'note', dartType: 'String?');
      expect(field.nonNullDartType, 'String');
    });

    test('leaves a non-nullable type unchanged', () {
      final field = ParsedField(name: 'title', dartType: 'String');
      expect(field.nonNullDartType, 'String');
    });

    test('only strips the outer "?", not one inside a generic argument', () {
      final field = ParsedField(name: 'items', dartType: 'List<int?>');
      expect(field.nonNullDartType, 'List<int?>');
    });
  });
}
