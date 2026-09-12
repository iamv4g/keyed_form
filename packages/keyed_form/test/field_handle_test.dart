import 'package:keyed_form/keyed_form.dart';
import 'package:test/test.dart';

import 'support/tour_fixture.dart';

KeyedFormController<Trip> form({
  Trip initial = const Trip(),
  KeyedFormMode mode = KeyedFormMode.onChange,
}) => KeyedFormController<Trip>(
  initialValue: initial,
  mode: mode,
  resolver: validateTrip,
);

void main() {
  group('FieldHandle — write', () {
    test('set writes the draft and notifies once', () {
      final f = form();
      var notifications = 0;
      f.addListener(() => notifications++);

      f.field(TripFields.name).set('Kyoto');

      expect(f.value.name, 'Kyoto');
      expect(notifications, 1);
    });

    test('update reads-transforms-writes in one notification', () {
      final f = form(initial: const Trip(days: 2));
      var notifications = 0;
      f.addListener(() => notifications++);

      f.field(TripFields.days).update((d) => d + 3);

      expect(f.value.days, 5);
      expect(notifications, 1);
    });

    test('touch marks the field touched', () {
      final f = form(mode: KeyedFormMode.onTouched);
      f.field(TripFields.name).touch();
      expect(f.touched, contains(TripFields.name.key));
    });
  });

  group('FieldHandle — read', () {
    test('value / key mirror the ref', () {
      final f = form(initial: const Trip(name: 'Nara'));
      final name = f.field(TripFields.name);
      expect(name.value, 'Nara');
      expect(name.key, TripFields.name.key);
    });

    test('error is gated by mode, dirty tracks the baseline', () {
      final f = form(
        initial: const Trip(name: 'Nara'),
        mode: KeyedFormMode.onTouched,
      );
      final name = f.field(TripFields.name);

      name.set('');
      expect(name.dirty, isTrue);
      expect(name.error, isNull, reason: 'not touched yet');

      name.touch();
      expect(name.error, 'name.required');
    });
  });

  group('FieldHandle — list', () {
    test('list() edits rows by id and dirtyRows() reports changes', () {
      final f = form(
        initial: const Trip(
          stops: [Stop(clientId: 'a', label: 'Kyoto')],
        ),
      );
      final stops = f.field(TripFields.stops).list();

      stops.append(const Stop(clientId: 'b', label: 'Nara'));
      expect(f.value.stops.map((s) => s.clientId), ['a', 'b']);

      stops.updateById('a', (s) => s.copyWith(label: 'Osaka'));
      expect(f.field(TripFields.stops).list().byId('a')?.label, 'Osaka');

      final dirty = f.field(TripFields.stops).dirtyRows().toList();
      expect(dirty, contains(TripFields.stops.key + FieldKey.id('a')));
      expect(dirty, contains(TripFields.stops.key + FieldKey.id('b')));
    });
  });
}
