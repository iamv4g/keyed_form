@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'itinerary_schema.kfg.dart';

final _itinerarySchema = ks.object({
  'days': ks
      .list(
        ks.object(className: 'DaySchema', {
          'label': ks.string(error: .text('Give the day a label')).min(1),
          'activities': ks
              .list(
                ks.discriminatedUnion(
                  'kind',
                  {
                    'sightseeing': ks.object({
                      'place': ks
                          .string(error: .text('Where to?'))
                          .min(1),
                    }),
                    'meal': ks.object({
                      'restaurant': ks
                          .string(error: .text('Which restaurant?'))
                          .min(1),
                    }),
                  },
                  className: 'ActivitySchema',
                ),
              )
              .min(1, error: .text('Add at least one activity')),
        }),
      )
      .min(1, error: .text('Add at least one day')),
});
