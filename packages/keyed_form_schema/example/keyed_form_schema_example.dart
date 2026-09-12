// Declarative validation with the `ks.*` DSL — pure runtime, no codegen.
//
// A schema is a value: compose field validators into `ks.object({...})`, add
// cross-field `.refine(...)` checks, then `validateMap(json)` to get back
// `FieldErrors` keyed by `FieldKey` — the same identity the optics and the
// form controller use, so an error drops straight onto the right widget.
//
//   dart run example/keyed_form_schema_example.dart
//
// Pair this with `keyed_form_gen` to also get the immutable data classes and
// field references generated from the very same schema.

import 'package:keyed_form_schema/keyed_form_schema.dart';

final _tourSchema = ks
    .object({
      'title': ks.string().min(
        3,
        error: .text('Tour title needs at least 3 characters'),
      ),
      'stops': ks
          .list(
            ks.object({
              'city': ks.string(error: .text('City is required')).min(1),
              'nights': ks.int().min(1, error: .text('At least one night')),
            }),
          )
          .min(1, error: .text('Add at least one stop')),
      'notes': ks.string().optional().nullable(),
    })
    .refine(
      (data) => _totalNights(data) <= 14,
      error: .text('A tour can be at most 14 nights'),
      path: 'stops',
    );

int _totalNights(Map<String, Object?> data) {
  final stops = (data['stops'] as List?) ?? const [];
  return stops.fold<int>(
    0,
    (sum, stop) => sum + (((stop as Map)['nights'] as int?) ?? 0),
  );
}

void _printErrors(FieldErrors<String> errors) {
  print('${errors.length} error(s):');
  for (final key in errors.keys) {
    final path = key.toPath();
    print('  ${path.isEmpty ? '<root>' : path}: ${errors.byKey(key)}');
  }
}

void main() {
  // A draft straight off a form — several fields still bad. Each list row
  // carries a `clientId`, so its errors are keyed by that id, not by index.
  final draft = {
    'title': 'Ky',
    'stops': [
      {'clientId': 'a', 'city': 'Kyoto', 'nights': 10},
      {'clientId': 'b', 'city': '', 'nights': 7},
    ],
    'notes': null,
  };

  _printErrors(_tourSchema.validateMap(draft));
  //   title: Tour title needs at least 3 characters
  //   stops.['b'].city: City is required
  //   stops: A tour can be at most 14 nights        (10 + 7 = 17 nights)

  // Fix the draft and revalidate.
  final fixed = {
    'title': 'Kyoto in autumn',
    'stops': [
      {'clientId': 'a', 'city': 'Kyoto', 'nights': 4},
      {'clientId': 'b', 'city': 'Nara', 'nights': 2},
    ],
    'notes': 'Bring a warm coat',
  };
  print(
    'fixed draft is valid: ${_tourSchema.validateMap(fixed).isEmpty}',
  ); // true
}
