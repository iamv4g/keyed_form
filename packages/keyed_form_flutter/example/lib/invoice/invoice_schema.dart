@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'invoice_schema.kfg.dart';

final _invoiceSchema = ks.object({
  'lineItems': ks
      .list(
        ks.object(className: 'LineItemSchema', {
          'description': ks
              .string(error: .text('Description is required'))
              .min(1),
          'quantity': ks
              .int()
              .min(1, error: .text('At least 1'))
              .defaultTo(1),
          'unitPrice': ks.int().min(0, error: .text('Cannot be negative')).defaultTo(0),
        }),
      )
      .min(1, error: .text('Add at least one line item')),
  // Never typed by the user — kept in sync by `addRelation` and frozen with
  // `markReadOnly` the moment the controller is built. Still a real schema
  // field (not just app state) so it validates, serializes, and gets a
  // FieldRef like everything else.
  'total': ks.int().defaultTo(0),
});
