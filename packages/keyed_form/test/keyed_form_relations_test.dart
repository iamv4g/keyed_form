import 'package:keyed_form/keyed_form.dart';
import 'package:test/test.dart';

import 'support/tour_fixture.dart';

KeyedFormController<Trip> flatForm({
  Trip initial = const Trip(),
  KeyedFormMode mode = KeyedFormMode.onChange,
}) => KeyedFormController<Trip>(
  initialValue: initial,
  mode: mode,
  resolver: validateTrip,
);

KeyedFormController<Trip> scopedForm({Trip initial = const Trip()}) =>
    KeyedFormController<Trip>(
      initialValue: initial,
      mode: KeyedFormMode.onTouched,
      scopeOf: stopScopeOf,
      resolver: validateTrip,
    );

void main() {
  group('addRelation', () {
    test('onChange fires with the selected value when source changes', () {
      final form = flatForm(initial: const Trip(days: 2));
      final calls = <int>[];
      form.addRelation(TripFields.days, (d) => d, calls.add);

      form.setField(TripFields.days, 3);

      expect(calls, [3]);
    });

    test('registering a relation does not itself call onChange', () {
      final form = flatForm(initial: const Trip(days: 2));
      final calls = <int>[];

      form.addRelation(TripFields.days, (d) => d, calls.add);

      expect(calls, isEmpty);
    });

    test('does not fire when an unrelated field changes', () {
      final form = flatForm(initial: const Trip(days: 2, name: 'A'));
      final calls = <int>[];
      form.addRelation(TripFields.days, (d) => d, calls.add);

      form.setField(TripFields.name, 'B');

      expect(calls, isEmpty);
    });

    test('does not fire when the selected value is unchanged', () {
      final form = flatForm(initial: const Trip(days: 2));
      final calls = <String>[];
      form.addRelation(
        TripFields.days,
        (d) => d.isEven ? 'even' : 'odd',
        calls.add,
      );

      form.setField(TripFields.days, 4); // still even

      expect(calls, isEmpty);
    });

    test('the returned callback unsubscribes the relation', () {
      final form = flatForm(initial: const Trip(days: 2));
      final calls = <int>[];
      final unsubscribe = form.addRelation(
        TripFields.days,
        (d) => d,
        calls.add,
      );

      form.setField(TripFields.days, 3);
      unsubscribe();
      form.setField(TripFields.days, 4);

      expect(calls, [3]);
    });

    test('a relation whose source is unresolved does not fire', () {
      final form = scopedForm(
        initial: const Trip(
          stops: [Stop(clientId: 'a', label: 'A')],
        ),
      );
      final calls = <String>[];
      form.addRelation(TripFields.stopLabel('a'), (v) => v, calls.add);

      form.list(TripFields.stops).removeById('a');

      expect(calls, isEmpty);
    });
  });
}
