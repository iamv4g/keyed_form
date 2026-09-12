@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'packing_schema.kfg.dart';

final _packingSchema = ks.object({
  'items': ks
      .list(
        ks.object(className: 'PackingItemSchema', {
          'label': ks.string(error: .text('Give it a name')).min(1),
          'packed': ks.boolean().defaultTo(false),
        }),
      )
      .min(1, error: .text('Add at least one item')),
});
