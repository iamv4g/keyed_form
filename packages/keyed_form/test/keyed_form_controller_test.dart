import 'dart:async';

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
  group('writes + notification', () {
    test('setField updates the draft and notifies once', () {
      final form = flatForm();
      var notifications = 0;
      form.addListener(() => notifications++);

      form.setField(TripFields.name, 'Kyoto');

      expect(form.value.name, 'Kyoto');
      expect(notifications, 1);
    });

    test('a no-op write (equal value) neither mutates nor notifies', () {
      final form = flatForm(initial: const Trip(name: 'Kyoto'));
      var notifications = 0;
      form.addListener(() => notifications++);

      form.setField(TripFields.name, 'Kyoto');

      expect(notifications, 0);
    });

    test('updateField applies a transform', () {
      final form = flatForm(initial: const Trip(days: 2));
      form.updateField(TripFields.days, (d) => d + 1);
      expect(form.value.days, 3);
    });
  });

  group('dirty tracking', () {
    test('isDirty flips on change and back on revert', () {
      final form = flatForm(initial: const Trip(name: 'A'));
      expect(form.isDirty, isFalse);

      form.setField(TripFields.name, 'B');
      expect(form.isDirty, isTrue);

      form.setField(TripFields.name, 'A');
      expect(form.isDirty, isFalse);
    });

    test('differs / dirtyRows pinpoint the changed row', () {
      final base = const Trip(
        name: 'T',
        days: 1,
        stops: [
          Stop(clientId: 'a', label: 'A'),
          Stop(clientId: 'b', label: 'B'),
        ],
      );
      final form = scopedForm(initial: base);

      form.setField(TripFields.stopLabel('b'), 'B2');

      expect(form.differs(TripFields.stop('a')), isFalse);
      expect(form.differs(TripFields.stop('b')), isTrue);
      expect(form.dirtyRows(TripFields.stops).map((k) => k.toPath()), [
        'stops.[\'b\']',
      ]);
    });
  });

  group('error visibility by mode', () {
    test('onChange: error shows immediately after the field is written', () {
      final form =
          flatForm(mode: KeyedFormMode.onChange, initial: const Trip(days: 1))
            ..setField(TripFields.name, 'x')
            ..setField(TripFields.name, '');

      expect(form.visibleErrorFor(TripFields.name), 'name.required');
    });

    test('onTouched: error hidden until touch(), then shown', () {
      final form = KeyedFormController<Trip>(
        initialValue: const Trip(name: 'seed', days: 1),
        mode: KeyedFormMode.onTouched,
        resolver: validateTrip,
      );

      // A write revalidates but does not auto-touch in onTouched mode.
      form.setField(TripFields.name, '');
      expect(form.errors.byKey(TripFields.name.key), 'name.required');
      expect(form.visibleErrorFor(TripFields.name), isNull);

      form.touch(TripFields.name.key);
      expect(form.visibleErrorFor(TripFields.name), 'name.required');
    });

    test('onSubmit: only validate() surfaces errors', () {
      final form = KeyedFormController<Trip>(
        initialValue: const Trip(),
        mode: KeyedFormMode.onSubmit,
        resolver: validateTrip,
      );
      form.setField(TripFields.name, '');
      expect(form.visibleErrorKeys, isEmpty);

      expect(form.validate(), isFalse);
      expect(
        form.visibleErrorKeys.map((k) => k.toPath()),
        containsAll(<String>['name', 'days']),
      );
    });

    test('all: errors are visible the moment they exist', () {
      final form = flatForm(mode: KeyedFormMode.all)
        ..setField(TripFields.name, 'ok')
        ..setField(TripFields.name, '');
      expect(form.visibleErrorFor(TripFields.name), 'name.required');
    });
  });

  group('submit', () {
    test('runs onValid with the current value and returns true when valid', () async {
      final form = flatForm(initial: const Trip(name: 'Kyoto', days: 3));
      Trip? received;

      final ok = await form.submit((value) {
        received = value;
      });

      expect(ok, isTrue);
      expect(received, const Trip(name: 'Kyoto', days: 3));
    });

    test(
      'does not run onValid, runs onInvalid with the visible error keys, '
      'when invalid',
      () async {
        final form = flatForm(
          mode: KeyedFormMode.onSubmit,
          initial: const Trip(),
        );
        var onValidCalled = false;
        Iterable<FieldKey>? keysSeen;

        final ok = await form.submit(
          (value) {
            onValidCalled = true;
          },
          onInvalid: (keys) {
            keysSeen = keys;
          },
        );

        expect(ok, isFalse);
        expect(onValidCalled, isFalse);
        expect(
          keysSeen?.map((k) => k.toPath()),
          containsAll(<String>['name', 'days']),
        );
        // onInvalid gets exactly what validate() already made visible.
        expect(keysSeen, form.visibleErrorKeys);
      },
    );

    test('onInvalid is optional — an invalid draft just returns false', () async {
      final form = flatForm(
        mode: KeyedFormMode.onSubmit,
        initial: const Trip(),
      );
      final ok = await form.submit((value) {});
      expect(ok, isFalse);
    });

    test('toggles submitting around an async onValid, even on error', () async {
      final valid = flatForm(initial: const Trip(name: 'Kyoto', days: 3));
      final gate = Completer<void>();

      final pending = valid.submit((value) async {
        expect(valid.submitting, isTrue);
        await gate.future;
      });
      expect(valid.submitting, isTrue);
      gate.complete();
      await pending;
      expect(valid.submitting, isFalse);

      final failing = flatForm(initial: const Trip(name: 'Kyoto', days: 3));
      await expectLater(
        failing.submit((value) => throw StateError('boom')),
        throwsStateError,
      );
      expect(failing.submitting, isFalse);
    });
  });

  group('scoped validation', () {
    test('a write only revalidates its own subtree', () {
      final form = scopedForm(
        initial: const Trip(
          name: 'T',
          days: 1,
          stops: [
            Stop(clientId: 'a'),
            Stop(clientId: 'b'),
          ],
        ),
      );

      form.setField(TripFields.stopLabel('a'), 'A');
      form.setField(TripFields.stopLabel('a'), '');

      // 'a' is now invalid; 'b' was never validated (still no error recorded).
      expect(
        form.errors.byKey(TripFields.stopLabel('a').key),
        'label.required',
      );
      expect(form.errors.byKey(TripFields.stopLabel('b').key), isNull);
    });

    test('splice preserves document order of surviving keys', () {
      final form = scopedForm(
        initial: const Trip(
          name: 'T',
          days: 1,
          stops: [
            Stop(clientId: 'a'),
            Stop(clientId: 'b'),
            Stop(clientId: 'c'),
          ],
        ),
      );

      form.validateScopes([
        TripFields.stop('a').key,
        TripFields.stop('b').key,
        TripFields.stop('c').key,
      ]);
      // a, b, c all empty-label → three errors in order.
      expect(form.errors.keys.map((k) => k.toPath()).toList(), [
        for (final id in ['a', 'b', 'c']) "stops.['$id'].label",
      ]);

      // Re-validate 'a' only: its key moves to the end, b/c keep their order.
      form.setField(TripFields.stopLabel('a'), 'A');
      expect(form.errors.keys.map((k) => k.toPath()).toList(), [
        "stops.['b'].label",
        "stops.['c'].label",
      ]);
    });

    test('validateScopes reveals scopes and returns only failing ones', () {
      final form = scopedForm(
        initial: const Trip(
          name: 'T',
          days: 1,
          stops: [
            Stop(clientId: 'a', label: 'A'),
            Stop(clientId: 'b'),
          ],
        ),
      );

      final failing = form.validateScopes([
        TripFields.stop('a').key,
        TripFields.stop('b').key,
      ]);

      expect(failing.map((k) => k.toPath()), ["stops.['b']"]);
      expect(form.visibleErrorFor(TripFields.stopLabel('b')), 'label.required');
      // Every passed scope is revealed (parity with `validateDirtyDays`).
      expect(
        form.revealed.map((k) => k.toPath()),
        containsAll(<String>["stops.['a']", "stops.['b']"]),
      );
    });

    test('a revealed subtree stops showing errors once it is valid again', () {
      final form = scopedForm(
        initial: const Trip(
          name: 'T',
          days: 1,
          stops: [Stop(clientId: 'a')],
        ),
      );
      form.validateScopes([TripFields.stop('a').key]);
      expect(form.visibleErrorFor(TripFields.stopLabel('a')), 'label.required');

      form.setField(TripFields.stopLabel('a'), 'A');
      expect(form.visibleErrorFor(TripFields.stopLabel('a')), isNull);
      expect(form.visibleErrorUnder(TripFields.stop('a').key), isFalse);
    });
  });

  group('seed / reset', () {
    test('seed re-baselines when clean', () {
      final form = flatForm(initial: const Trip(name: 'A'));
      form.seed(const Trip(name: 'B', days: 3));
      expect(form.value.name, 'B');
      expect(form.isDirty, isFalse);
    });

    test('seed is ignored while dirty, unless forced', () {
      final form = flatForm(initial: const Trip(name: 'A'))
        ..setField(TripFields.name, 'edited');

      form.seed(const Trip(name: 'server'));
      expect(form.value.name, 'edited');

      form.seed(const Trip(name: 'server'), force: true);
      expect(form.value.name, 'server');
      expect(form.isDirty, isFalse);
    });

    test('reset discards edits and bookkeeping', () {
      final form = flatForm(initial: const Trip(name: 'A', days: 1))
        ..setField(TripFields.name, '')
        ..validate();
      expect(form.visibleErrorKeys, isNotEmpty);

      form.reset();
      expect(form.value.name, 'A');
      expect(form.submitted, isFalse);
      expect(form.visibleErrorKeys, isEmpty);
    });
  });

  group('server errors', () {
    test('setServerErrorPaths parses paths and force-reveals', () {
      final form = KeyedFormController<Trip>(
        initialValue: const Trip(name: 'T', days: 1),
        mode: KeyedFormMode.onTouched,
        resolver: validateTrip,
      );

      form.setServerErrorPaths({'name': 'name.taken'});

      expect(form.visibleErrorFor(TripFields.name), 'name.taken');
      expect(form.submitted, isTrue);
    });
  });

  group('KeyedFormList', () {
    KeyedFormController<Trip> withStops(List<String> ids) => scopedForm(
      initial: Trip(
        name: 'T',
        days: 1,
        stops: [for (final id in ids) Stop(clientId: id, label: id)],
      ),
    );

    test('append / prepend / insertAfter', () {
      final form = withStops(['a', 'c']);
      final list = form.list(TripFields.stops);

      list.append(const Stop(clientId: 'd', label: 'd'));
      list.prepend(const Stop(clientId: 'z', label: 'z'));
      list.insertAfter('a', const Stop(clientId: 'b', label: 'b'));

      expect(list.items.map((s) => s.clientId), ['z', 'a', 'b', 'c', 'd']);
    });

    test('removeById returns the row and drops its errors', () {
      final form = withStops(['a', 'b']);
      form.validateScopes([TripFields.stop('a').key, TripFields.stop('b').key]);
      // labels equal their ids, so no errors — make 'b' invalid first.
      form.setField(TripFields.stopLabel('b'), '');
      form.touch(TripFields.stopLabel('b').key);
      expect(form.errors.byKey(TripFields.stopLabel('b').key), isNotNull);

      final removed = form.list(TripFields.stops).removeById('b');
      expect(removed?.clientId, 'b');
      expect(
        form.errors.byKey(TripFields.stopLabel('b').key),
        isNull,
        reason: 'removeSubtree runs on the write',
      );
    });

    test('move / swap reorder by position', () {
      final form = withStops(['a', 'b', 'c']);
      final list = form.list(TripFields.stops);

      list.move(0, 2);
      expect(list.items.map((s) => s.clientId), ['b', 'c', 'a']);

      list.swap(0, 2);
      expect(list.items.map((s) => s.clientId), ['a', 'c', 'b']);
    });

    test('updateById edits one row immutably', () {
      final form = withStops(['a', 'b']);
      form.list(TripFields.stops).updateById('b', (s) => s.copyWith(nights: 4));
      expect(form.value.stops[1].nights, 4);
      expect(form.value.stops[0].nights, 1);
    });

    test('an out-of-range positional op is a no-op', () {
      final form = withStops(['a']);
      final list = form.list(TripFields.stops);
      list.move(0, 5);
      list.removeAt(9);
      expect(list.items.map((s) => s.clientId), ['a']);
    });
  });
}
