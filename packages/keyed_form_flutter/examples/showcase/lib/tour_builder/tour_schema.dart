@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'tour_schema.kfg.dart';

enum TourCategory { adventure, culture, food, nature }

final tourSchema = ks
    .object({
      'title': ks.string(error: .text('Give the tour a name')).min(3),
      'category': ks.enums(TourCategory.values).defaultTo(TourCategory.culture),
      'maxGuests': ks.int()
          .min(1, error: .text('At least one guest'))
          .max(30, error: .text('Groups cap at 30'))
          .defaultTo(8),
      'isPublic': ks.boolean().defaultTo(false),
      'stops': ks
          .list(
            ks.object({
              'city': ks.string(error: .text('Which city?')).min(1),
              'nights': ks.int()
                  .min(1, error: .text('At least one night'))
                  .defaultTo(2),
            }),
          )
          .min(1, error: .text('Add at least one stop')),
      'notes': ks.string().optional().defaultTo(''),
    })
    .refine(
      (data) => _totalNights(data) <= 14,
      error: .text('Keep the itinerary under 14 nights'),
      path: 'stops',
    )
    .refine(
      (data) => ((data['title'] as String?) ?? '').trim().length >= 10,
      when: (data) => data['isPublic'] == true,
      error: .text('Public tours need a descriptive name (10+ characters)'),
      path: 'title',
    );

int _totalNights(Map<String, Object?> data) {
  final stops = (data['stops'] as List?) ?? const [];
  return stops.fold<int>(
    0,
    (sum, stop) => sum + (((stop as Map)['nights'] as int?) ?? 0),
  );
}
