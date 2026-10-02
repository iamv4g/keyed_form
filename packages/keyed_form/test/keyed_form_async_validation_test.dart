import 'dart:async';

import 'package:keyed_form/keyed_form.dart';
import 'package:test/test.dart';

import 'support/tour_fixture.dart';

abstract final class _StopFields {
  static final label = StrictFieldRef<Stop, String>.of(
    key: FieldKey.name('label'),
    get: (stop) => stop.label,
    set: (stop, value) => stop.copyWith(label: value),
  );
}

void main() {
  test('dot shorthand binds a typed root field rule', () async {
    final form = KeyedFormController<Trip>(
      initialValue: const Trip(name: 'taken', days: 1),
      resolver: validateTrip,
      asyncValidators: [
        .field(
          field: TripFields.name,
          validate: (_, value) async =>
              value == 'taken' ? 'already used' : null,
        ),
      ],
    );

    final result = await form.validate();

    expect(result.status, KeyedFormValidationStatus.invalid);
    expect(result.errors.byKey(TripFields.name.key), 'already used');
    expect(result.isValid, isFalse);
    form.dispose();
  });

  test('nested forEach rules receive typed row-local values', () async {
    final form = KeyedFormController<Trip>(
      initialValue: const Trip(
        name: 'Kyoto',
        days: 1,
        stops: [Stop(clientId: 'a', label: 'closed')],
      ),
      resolver: validateTrip,
      asyncValidators: [
        .forEach(
          list: TripFields.stops,
          rules: [
            .field(
              field: _StopFields.label,
              validate: (stop, label) =>
                  stop.clientId == 'a' && label == 'closed'
                  ? 'unavailable'
                  : null,
            ),
          ],
        ),
      ],
    );

    final result = await form.validate();

    expect(result.errors.byKey(TripFields.stopLabel('a').key), 'unavailable');
    form.dispose();
  });

  test(
    'technical failures remain separate and can be allowed by policy',
    () async {
      final form = KeyedFormController<Trip>(
        initialValue: const Trip(name: 'Kyoto', days: 1),
        resolver: validateTrip,
        asyncValidationFailureMode: KeyedFormAsyncFailureMode.allowSubmit,
        asyncValidators: [
          .field(
            field: TripFields.name,
            validate: (_, _) => throw StateError('offline'),
          ),
        ],
      );
      var saved = false;

      final didSubmit = await form.submit((_) => saved = true);

      expect(didSubmit, isTrue);
      expect(saved, isTrue);
      expect(
        form.validationFailures[TripFields.name.key]?.failureMode,
        KeyedFormAsyncFailureMode.allowSubmit,
      );
      form.dispose();
    },
  );

  test('submit blocks technical failures by default', () async {
    final form = KeyedFormController<Trip>(
      initialValue: const Trip(name: 'Kyoto', days: 1),
      resolver: validateTrip,
      asyncValidators: [
        .field(
          field: TripFields.name,
          validate: (_, _) => throw StateError('offline'),
        ),
      ],
    );
    var saved = false;
    KeyedFormValidationResult? unavailable;

    final didSubmit = await form.submit(
      (_) => saved = true,
      onValidationUnavailable: (result) => unavailable = result,
    );

    expect(didSubmit, isFalse);
    expect(saved, isFalse);
    expect(unavailable?.status, KeyedFormValidationStatus.unavailable);
    form.dispose();
  });
  test('sync error gates only its own async field', () async {
    var nameChecks = 0;
    var dayChecks = 0;
    final form = KeyedFormController<Trip>(
      initialValue: const Trip(name: 'bad', days: 1),
      resolver: (draft, _) => FieldErrors({
        if (draft.name == 'bad') TripFields.name.key: 'format error',
      }),
      asyncValidators: [
        .field(
          field: TripFields.name,
          validate: (_, _) {
            nameChecks++;
            return null;
          },
        ),
        .field(
          field: TripFields.days,
          validate: (_, _) {
            dayChecks++;
            return null;
          },
        ),
      ],
    );

    final result = await form.validate();

    expect(nameChecks, 0);
    expect(dayChecks, 1);
    expect(result.errors.byKey(TripFields.name.key), 'format error');
    form.dispose();
  });

  test('submit reruns a previously completed async rule', () async {
    var checks = 0;
    final form = KeyedFormController<Trip>(
      initialValue: const Trip(name: 'Kyoto', days: 1),
      resolver: validateTrip,
      asyncValidators: [
        .field(
          field: TripFields.name,
          validate: (_, _) {
            checks++;
            return null;
          },
        ),
      ],
    );

    await form.validate();
    final didSubmit = await form.submit((_) {});

    expect(didSubmit, isTrue);
    expect(checks, 2);
    form.dispose();
  });

  test(
    'new explicit run supersedes pending rule without awaiting it',
    () async {
      final gate = Completer<String?>();
      var checks = 0;
      final form = KeyedFormController<Trip>(
        initialValue: const Trip(name: 'Kyoto', days: 1),
        resolver: validateTrip,
        asyncValidators: [
          .field(
            field: TripFields.name,
            validate: (_, _) {
              checks++;
              return checks == 1 ? gate.future : null;
            },
          ),
        ],
      );

      final first = form.validateScopes([TripFields.name.key]);
      expect(form.isValidating(TripFields.name.key), isTrue);
      final second = await form.validateScopes([TripFields.name.key]);
      expect(second.isValid, isTrue);
      expect(form.isValidating(TripFields.name.key), isFalse);

      gate.complete('stale result');
      await first;
      expect(form.errors.byKey(TripFields.name.key), isNull);
      form.dispose();
    },
  );

  test('late blur during submit does not supersede the submit run', () async {
    final gate = Completer<String?>();
    var checks = 0;
    final form = KeyedFormController<Trip>(
      initialValue: const Trip(name: 'Kyoto', days: 1),
      resolver: validateTrip,
      mode: KeyedFormMode.onBlur,
      asyncValidators: [
        .field(
          field: TripFields.name,
          validate: (_, _) {
            checks++;
            return gate.future;
          },
        ),
      ],
    );

    final pending = form.submit((_) {});
    form.touch(TripFields.name.key);
    expect(checks, 1);
    gate.complete(null);

    expect(await pending, isTrue);
    form.dispose();
  });
  test(
    'independent async validators start together and preserve rule order',
    () async {
      final nameGate = Completer<String?>();
      final daysGate = Completer<String?>();
      var nameStarted = false;
      var daysStarted = false;
      final form = KeyedFormController<Trip>(
        initialValue: const Trip(name: 'Kyoto', days: 1),
        resolver: validateTrip,
        asyncValidators: [
          .field(
            field: TripFields.name,
            validate: (_, _) {
              nameStarted = true;
              return nameGate.future;
            },
          ),
          .field(
            field: TripFields.days,
            validate: (_, _) {
              daysStarted = true;
              return daysGate.future;
            },
          ),
        ],
      );

      final pending = form.validate();
      expect(nameStarted, isTrue);
      expect(daysStarted, isTrue);
      nameGate.complete('first rule failed');
      var settled = false;
      pending.then((_) => settled = true);
      await Future<void>(() {});
      expect(settled, isFalse);
      daysGate.complete('second rule failed');
      final result = await pending;

      expect(result.errors.keys.toList(), [
        TripFields.name.key,
        TripFields.days.key,
      ]);
      form.dispose();
    },
  );

  test(
    'editing the bound draft cancels a pending run and fences its result',
    () async {
      final gate = Completer<String?>();
      var checks = 0;
      var saved = false;
      final form = KeyedFormController<Trip>(
        initialValue: const Trip(name: 'Kyoto', days: 1),
        resolver: validateTrip,
        asyncValidators: [
          .field(
            field: TripFields.name,
            validate: (_, _) {
              checks++;
              return gate.future;
            },
          ),
        ],
      );

      final pending = form.submit((_) => saved = true);
      expect(checks, 1);
      expect(form.isValidating(TripFields.name.key), isTrue);
      form.field(TripFields.name).set('Nara');
      expect(await pending, isFalse);
      expect(saved, isFalse);
      gate.complete('stale verdict');
      await Future<void>(() {});
      expect(form.errors.byKey(TripFields.name.key), isNull);
      form.dispose();
    },
  );
  test('a null async verdict clears its previous async error', () async {
    var reject = true;
    final form = KeyedFormController<Trip>(
      initialValue: const Trip(name: 'Kyoto', days: 1),
      resolver: validateTrip,
      asyncValidators: [
        .field(
          field: TripFields.name,
          validate: (_, _) => reject ? 'name taken' : null,
        ),
      ],
    );

    final rejected = await form.validate();
    expect(rejected.errors.byKey(TripFields.name.key), 'name taken');
    reject = false;
    final accepted = await form.validate();

    expect(accepted.errors.byKey(TripFields.name.key), isNull);
    expect(form.errors.byKey(TripFields.name.key), isNull);
    form.dispose();
  });
  test(
    'observer exceptions propagate after every sibling is settled',
    () async {
      var secondObserverCalled = false;
      final form = KeyedFormController<Trip>(
        initialValue: const Trip(name: 'Kyoto', days: 1),
        resolver: (_, _) => const FieldErrors.empty(),
        asyncValidators: [
          .field(
            field: TripFields.name,
            validate: (_, _) => throw StateError('name service unavailable'),
            onFailure: (_, _) => throw ArgumentError('observer failed'),
          ),
          .field(
            field: TripFields.days,
            validate: (_, _) => throw StateError('days service unavailable'),
            onFailure: (_, _) => secondObserverCalled = true,
          ),
        ],
      );

      await expectLater(form.validate(), throwsArgumentError);

      expect(secondObserverCalled, isTrue);
      expect(form.isFailedValidation(TripFields.name.key), isTrue);
      expect(form.isFailedValidation(TripFields.days.key), isTrue);
      expect(form.isValidating(TripFields.name.key), isFalse);
      expect(form.isValidating(TripFields.days.key), isFalse);
      form.dispose();
    },
  );
  test(
    'empty scopes do no work and scoped results omit sibling errors',
    () async {
      var resolverCalls = 0;
      final form = KeyedFormController<Trip>(
        initialValue: const Trip(name: 'Kyoto', days: 0),
        resolver: (draft, scope) {
          resolverCalls++;
          return FieldErrors({
            if ((scope == null || scope.contains(TripFields.name.key)) &&
                draft.name.isEmpty)
              TripFields.name.key: 'name required',
            if ((scope == null || scope.contains(TripFields.days.key)) &&
                draft.days <= 0)
              TripFields.days.key: 'days required',
          });
        },
      );

      await form.validate();
      resolverCalls = 0;
      final empty = await form.validateScopes(const []);
      expect(empty.isValid, isTrue);
      expect(resolverCalls, 0);

      final scoped = await form.validateScopes([TripFields.name.key]);
      expect(scoped.isValid, isTrue);
      expect(scoped.errors.isEmpty, isTrue);
      expect(form.errors.byKey(TripFields.days.key), 'days required');
      form.dispose();
    },
  );

  test(
    'post-submit onChange revalidation runs after a successful submit',
    () async {
      var resolverCalls = 0;
      final form = KeyedFormController<Trip>(
        initialValue: const Trip(name: 'Kyoto', days: 1),
        resolver: (draft, scope) {
          resolverCalls++;
          return FieldErrors({
            if ((scope == null || scope.contains(TripFields.name.key)) &&
                draft.name.isEmpty)
              TripFields.name.key: 'name required',
          });
        },
      );

      form.field(TripFields.name).set('Nara');
      expect(resolverCalls, 0);
      expect(await form.submit((_) {}), isTrue);
      expect(resolverCalls, 1);

      form.field(TripFields.name).set('');
      expect(resolverCalls, 2);
      expect(form.errors.byKey(TripFields.name.key), 'name required');
      form.dispose();
    },
  );
  test('error sources preserve priority order and ownership', () async {
    final stopLabelKey = TripFields.stopLabel('a').key;
    final form = KeyedFormController<Trip>(
      initialValue: const Trip(
        name: '',
        days: 1,
        stops: [Stop(clientId: 'a', label: 'place')],
      ),
      resolver: (draft, scope) => FieldErrors({
        if ((scope == null || scope.contains(TripFields.name.key)) &&
            draft.name.isEmpty)
          TripFields.name.key: 'sync name',
      }),
      asyncValidators: [
        .field(field: TripFields.days, validate: (_, _) => 'async days'),
        .forEach(
          list: TripFields.stops,
          rules: [
            .field(field: _StopFields.label, validate: (_, _) => 'async label'),
          ],
        ),
      ],
    );

    await form.validate();
    form.setServerErrors({
      TripFields.name.key: 'server name',
      TripFields.stops.key: 'server parent',
      TripFields.days.key: 'server days',
    });

    expect(form.errors.keys.toList(), [
      TripFields.name.key,
      TripFields.stops.key,
      TripFields.days.key,
      stopLabelKey,
    ]);
    expect(form.errors.byKey(TripFields.name.key), 'sync name');
    expect(form.errors.byKey(TripFields.stops.key), 'server parent');
    expect(form.errors.byKey(TripFields.days.key), 'server days');
    expect(form.errors.byKey(stopLabelKey), 'async label');
    form.dispose();
  });

  test('removed row invalidates its pending async verdict', () async {
    final gate = Completer<String?>();
    final rowKey = FieldKey.name('stops') + FieldKey.id('a');
    final labelKey = rowKey + FieldKey.name('label');
    final form = KeyedFormController<Trip>(
      initialValue: const Trip(
        name: 'Kyoto',
        days: 1,
        stops: [Stop(clientId: 'a', label: 'unknown')],
      ),
      resolver: validateTrip,
      asyncValidators: [
        .forEach(
          list: TripFields.stops,
          rules: [
            .field(field: _StopFields.label, validate: (_, _) => gate.future),
          ],
        ),
      ],
    );

    final pending = form.validate();
    expect(form.isValidating(labelKey), isTrue);
    form.field(TripFields.stops).list().removeById('a');
    expect((await pending).status, KeyedFormValidationStatus.superseded);
    expect(form.isValidating(labelKey), isFalse);

    gate.complete('stale row result');
    await Future<void>(() {});
    expect(form.errors.byKey(labelKey), isNull);
    expect(form.validationFailures.containsKey(labelKey), isFalse);
    expect(form.value.stops, isEmpty);
    form.dispose();
  });

  test(
    'value errors take precedence over allowed technical failures on submit',
    () async {
      final form = KeyedFormController<Trip>(
        initialValue: const Trip(name: '', days: 1),
        resolver: validateTrip,
        asyncValidationFailureMode: KeyedFormAsyncFailureMode.allowSubmit,
        asyncValidators: [
          .field(
            field: TripFields.name,
            validate: (_, _) => throw StateError('offline'),
          ),
        ],
      );
      var invalidCalled = false;
      var unavailableCalled = false;
      var validCalled = false;

      final didSubmit = await form.submit(
        (_) => validCalled = true,
        onInvalid: (_) => invalidCalled = true,
        onValidationUnavailable: (_) => unavailableCalled = true,
      );

      expect(didSubmit, isFalse);
      expect(invalidCalled, isTrue);
      expect(unavailableCalled, isFalse);
      expect(validCalled, isFalse);
      form.dispose();
    },
  );
}
