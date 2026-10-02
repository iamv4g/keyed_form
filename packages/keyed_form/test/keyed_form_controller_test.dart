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

    test(
      'onTouched validates on blur and only after change following blur',
      () async {
        final form = KeyedFormController<Trip>(
          initialValue: const Trip(name: 'seed', days: 1),
          mode: KeyedFormMode.onTouched,
          resolver: validateTrip,
        );

        form.setField(TripFields.name, '');
        expect(form.errors.byKey(TripFields.name.key), isNull);
        form.touch(TripFields.name.key);
        expect(form.visibleErrorFor(TripFields.name), 'name.required');

        form.setField(TripFields.name, 'fixed');
        expect(form.errors.byKey(TripFields.name.key), isNull);
      },
    );
    test(
      'onTouched reveals only the blurred field in a wide resolver scope',
      () {
        final form = KeyedFormController<Trip>(
          initialValue: const Trip(),
          mode: KeyedFormMode.onTouched,
          resolver: validateTrip,
        );

        form.touch(TripFields.name.key);

        expect(form.errors.keys.map((key) => key.toPath()), ['name', 'days']);
        expect(form.visibleErrorKeys.map((key) => key.toPath()), ['name']);
      },
    );

    test('onSubmit: only submit surfaces errors', () async {
      final form = KeyedFormController<Trip>(
        initialValue: const Trip(),
        mode: KeyedFormMode.onSubmit,
        resolver: validateTrip,
      );
      form.setField(TripFields.name, '');
      form.touch(TripFields.name.key);
      expect(form.visibleErrorKeys, isEmpty);

      final result = await form.validate();
      expect(result.isValid, isFalse);
      expect(
        form.visibleErrorKeys.map((k) => k.toPath()),
        containsAll(<String>['name', 'days']),
      );
      expect(form.submitted, isFalse);
    });
    test('onSubmit waits for submit, then uses reValidateMode', () async {
      var resolverCalls = 0;
      final form = KeyedFormController<Trip>(
        initialValue: const Trip(name: 'ready', days: 1),
        mode: KeyedFormMode.onSubmit,
        resolver: (_, _) {
          resolverCalls++;
          return const FieldErrors.empty();
        },
      );

      form.setField(TripFields.name, 'edit');
      form.touch(TripFields.name.key);
      expect(resolverCalls, 0);

      await form.validate();
      expect(resolverCalls, 1);
      expect(form.submitted, isFalse);

      form.setField(TripFields.name, 'before submit');
      expect(resolverCalls, 1);

      await form.submit((_) {});
      expect(resolverCalls, 2);
      expect(form.submitted, isTrue);

      form.setField(TripFields.name, 'after submit');
      expect(resolverCalls, 3);
    });

    test('all: errors are visible the moment they exist', () {
      final form = flatForm(mode: KeyedFormMode.all)
        ..setField(TripFields.name, 'ok')
        ..setField(TripFields.name, '');
      expect(form.visibleErrorFor(TripFields.name), 'name.required');
    });
  });

  group('submit', () {
    test(
      'runs onValid with the current value and returns true when valid',
      () async {
        final form = flatForm(initial: const Trip(name: 'Kyoto', days: 3));
        Trip? received;

        final ok = await form.submit((value) {
          received = value;
        });

        expect(ok, isTrue);
        expect(received, const Trip(name: 'Kyoto', days: 3));
      },
    );

    test('does not run onValid, runs onInvalid with the visible error keys, '
        'when invalid', () async {
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
    });

    test(
      'onInvalid is optional — an invalid draft just returns false',
      () async {
        final form = flatForm(
          mode: KeyedFormMode.onSubmit,
          initial: const Trip(),
        );
        final ok = await form.submit((value) {});
        expect(ok, isFalse);
      },
    );

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

  group('read-only fields', () {
    test('set() is a no-op on a read-only field', () {
      final form = flatForm(initial: const Trip(name: 'A'));
      form.markReadOnly(TripFields.name.key);

      form.setField(TripFields.name, 'B');

      expect(form.value.name, 'A');
    });

    test('set(force: true) writes through a read-only field', () {
      final form = flatForm(initial: const Trip(name: 'A'));
      form.markReadOnly(TripFields.name.key);

      form.setField(TripFields.name, 'B', force: true);

      expect(form.value.name, 'B');
    });

    test('marking a parent scope read-only freezes a descendant field', () {
      final form = scopedForm(
        initial: const Trip(
          name: 'T',
          days: 1,
          stops: [Stop(clientId: 'a', label: 'A')],
        ),
      );
      form.markReadOnly(TripFields.stop('a').key);

      expect(form.isReadOnly(TripFields.stopLabel('a').key), isTrue);
      form.setField(TripFields.stopLabel('a'), 'Changed');
      expect(form.value.stops.single.label, 'A');
    });

    test('validate() still reports errors on a read-only field', () async {
      final form = flatForm(initial: const Trip(name: '', days: 1));
      form.markReadOnly(TripFields.name.key);

      final result = await form.validate();
      expect(result.isValid, isFalse);
      expect(result.errors.byKey(TripFields.name.key), 'name.required');
    });

    test('reset() does not clear read-only status', () {
      final form = flatForm(initial: const Trip(name: 'A'));
      form.markReadOnly(TripFields.name.key);

      form.reset();

      expect(form.isReadOnly(TripFields.name.key), isTrue);
    });

    test(
      'markReadOnly / unmarkReadOnly are no-ops when already in that state',
      () {
        final form = flatForm();
        var notifications = 0;
        form.addListener(() => notifications++);

        form.markReadOnly(TripFields.name.key);
        expect(notifications, 1);
        form.markReadOnly(TripFields.name.key);
        expect(notifications, 1);

        form.unmarkReadOnly(TripFields.name.key);
        expect(notifications, 2);
        form.unmarkReadOnly(TripFields.name.key);
        expect(notifications, 2);
      },
    );
  });

  group('scoped validation', () {
    test('an onChange write validates only its mapped subtree', () {
      final form = KeyedFormController<Trip>(
        initialValue: const Trip(
          name: 'T',
          days: 1,
          stops: [
            Stop(clientId: 'a'),
            Stop(clientId: 'b'),
          ],
        ),
        resolver: validateTrip,
        mode: KeyedFormMode.onChange,
        scopeOf: stopScopeOf,
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
    test('an unmapped write skips automatic validation', () {
      final form = KeyedFormController<Trip>(
        initialValue: const Trip(
          name: 'T',
          days: 1,
          stops: [Stop(clientId: 'a')],
        ),
        resolver: validateTrip,
        mode: KeyedFormMode.onChange,
        scopeOf: stopScopeOf,
      );

      form.field(TripFields.name).set('Updated');

      expect(form.errors, isEmpty);
    });

    test('scoped revalidation keeps surviving key order', () async {
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

      await form.validateScopes([
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
      form.touch(TripFields.stopLabel('a').key);
      expect(form.errors.keys.map((k) => k.toPath()).toList(), [
        "stops.['b'].label",
        "stops.['c'].label",
      ]);
    });

    test('validateScopes returns scoped structured errors', () async {
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

      final result = await form.validateScopes([
        TripFields.stop('a').key,
        TripFields.stop('b').key,
      ]);

      expect(result.status, KeyedFormValidationStatus.invalid);
      expect(result.errors.keys.map((key) => key.toPath()), [
        "stops.['b'].label",
      ]);
      expect(form.visibleErrorFor(TripFields.stopLabel('b')), 'label.required');
      expect(
        form.revealed.map((key) => key.toPath()),
        containsAll(<String>["stops.['a']", "stops.['b']"]),
      );
    });

    test(
      'a revealed subtree stops showing errors once it becomes valid',
      () async {
        final form = KeyedFormController<Trip>(
          initialValue: const Trip(
            name: 'T',
            days: 1,
            stops: [Stop(clientId: 'a')],
          ),
          resolver: validateTrip,
          mode: KeyedFormMode.onChange,
          scopeOf: stopScopeOf,
        );
        await form.validateScopes([TripFields.stop('a').key]);
        expect(
          form.visibleErrorFor(TripFields.stopLabel('a')),
          'label.required',
        );

        form.setField(TripFields.stopLabel('a'), 'A');
        expect(form.visibleErrorFor(TripFields.stopLabel('a')), isNull);
        expect(form.visibleErrorUnder(TripFields.stop('a').key), isFalse);
      },
    );
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

    test('reset discards edits and bookkeeping', () async {
      final form = flatForm(initial: const Trip(name: 'A', days: 1));
      form.setField(TripFields.name, '');
      await form.validate();
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

    test('removeById returns the row and drops its errors', () async {
      final form = withStops(['a', 'b']);
      await form.validateScopes([
        TripFields.stop('a').key,
        TripFields.stop('b').key,
      ]);
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
