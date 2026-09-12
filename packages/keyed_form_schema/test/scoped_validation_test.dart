import 'package:keyed_form_schema/keyed_form_schema.dart';
import 'package:test/test.dart';

/// `validateMap(scope:)` / `validateValues(scope:)` must re-check only the
/// subtree at `scope` and return errors *only* at or under it — the contract
/// `KeyedFormController._spliceScope` asserts.
void main() {
  final schema = ks
      .object({
        'title': ks.string().min(3, error: .text('title short')),
        'address': ks.object({
          'zip': ks.string().min(5, error: .text('zip short')),
          'city': ks.string().min(2, error: .text('city short')),
        }),
        'stops': ks
            .list(
              ks.object(className: 'Stop', {
                'city': ks.string(error: .text('stop city required')).min(1),
                'nights': ks.int().min(1, error: .text('nights >= 1')),
              }),
            )
            .min(1, error: .text('add a stop')),
      })
      .refine(
        (data) {
          final stops = (data['stops'] as List?) ?? const [];
          final total = stops.fold<int>(
            0,
            (sum, s) => sum + (((s as Map)['nights'] as int?) ?? 0),
          );
          return total <= 5;
        },
        path: 'stops',
        error: .text('at most 5 nights'),
      );

  Map<String, Object?> badDraft() => {
    'title': 'x',
    'address': {'zip': '1', 'city': 'y'},
    'stops': [
      {'clientId': 'a', 'city': '', 'nights': 4},
      {'clientId': 'b', 'city': '', 'nights': 4},
    ],
  };

  void assertAllUnder(FieldErrors<String> errors, FieldKey scope) {
    for (final k in errors.keys) {
      expect(scope.contains(k), isTrue, reason: '$k is outside scope $scope');
    }
  }

  test('no scope validates the whole draft', () {
    final errors = schema.validateMap(badDraft());
    expect(
      errors.keys.map((k) => k.toPath()),
      containsAll(<String>[
        'title',
        "address.zip",
        "stops.['a'].city",
        "stops.['b'].city",
        'stops', // the 8 > 5 refinement
      ]),
    );
  });

  test('scope = a flat field checks only that field', () {
    final scope = FieldKey.name('title');
    final errors = schema.validateMap(badDraft(), scope: scope);
    expect(errors.keys.single, scope);
    expect(errors.byKey(scope), 'title short');
    assertAllUnder(errors, scope);
  });

  test('scope = a nested object checks the whole subtree, nothing else', () {
    final scope = FieldKey.name('address');
    final errors = schema.validateMap(badDraft(), scope: scope);
    expect(errors.byKey(scope + FieldKey.name('zip')), 'zip short');
    expect(errors.byKey(FieldKey.name('title')), isNull);
    assertAllUnder(errors, scope);
  });

  test('scope = one nested field checks only it', () {
    final scope = FieldKey.name('address') + FieldKey.name('zip');
    final errors = schema.validateMap(badDraft(), scope: scope);
    expect(errors.keys.single, scope);
    assertAllUnder(errors, scope);
  });

  test('scope = one list row checks only that row, no list-level error', () {
    final scope = FieldKey.name('stops') + FieldKey.id('a');
    final errors = schema.validateMap(badDraft(), scope: scope);
    expect(errors.byKey(scope + FieldKey.name('city')), 'stop city required');
    expect(
      errors.byKey(FieldKey.name('stops')),
      isNull,
      reason: 'the min-items / refinement error is out of a row scope',
    );
    expect(
      errors.byKey(
        FieldKey.name('stops') + FieldKey.id('b') + FieldKey.name('city'),
      ),
      isNull,
    );
    assertAllUnder(errors, scope);
  });

  test('refinement runs when the scope is at/above its target', () {
    final scope = FieldKey.name('stops');
    final errors = schema.validateMap(badDraft(), scope: scope);
    expect(errors.byKey(scope), 'at most 5 nights');
    assertAllUnder(errors, scope);
  });

  test('validateValues threads scope like validateMap', () {
    // field order: title, address, stops
    final values = <Object?>[
      'x',
      {'zip': '1', 'city': 'y'},
      [
        {'clientId': 'a', 'city': '', 'nights': 1},
      ],
    ];
    final scope = FieldKey.name('title');
    final errors = schema.validateValues(values, scope: scope);
    expect(errors.keys.single, scope);
  });
}
