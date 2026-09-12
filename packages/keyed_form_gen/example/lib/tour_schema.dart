// The schema — one declarative source of truth.
//
// `@keyedSchema` is a *file-level* annotation: it goes on `library;`, and the
// generator picks up every `ks.object(...)` schema declared in this file.
// Running the generator produces `tour_schema.kfg.dart` next to it, with the
// immutable data classes, field references and validators. See example/README.md.

@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'tour_schema.kfg.dart';

final _tourSchema = ks.object({
  'title': ks
      .string(error: .text('Tour title is required'))
      .min(3, error: .text('Tour title needs at least 3 characters')),
  'stops': ks
      .list(
        ks.object(className: 'StopSchema', {
          'city': ks.string(error: .text('City is required')).min(1),
          'nights': ks.int()
              .min(1, error: .text('At least one night'))
              .defaultTo(1),
          'note': ks.string().optional().nullable(),
        }),
      )
      .min(1, error: .text('Add at least one stop')),
});
