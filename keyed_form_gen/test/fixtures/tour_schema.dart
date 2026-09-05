import 'package:keyed_schema/keyed_schema.dart';

part 'tour_schema.kfg.dart';

@keyedSchema
final tourSchema = ks.object({
  'title': ks.string().min(
    3,
    error: .text('Tour title must be at least 3 characters'),
  ),
  'hotels': ks
      .list(
        ks.object(className: 'HotelSchema', {
          'hotelName': ks.string().min(
            1,
            error: .text('Hotel name is required'),
          ),
          'hotelPrice': ks.string().optional(),
          'prefectureId': ks.int().optional(),
        }),
      )
      .min(1, error: .text('At least 1 hotel required')),
  // A scalar-item List, a Map, and a genuinely nullable field — regression
  // coverage for the copyWith callable-interface redesign: bare `[]`/`{}`
  // literals for the non-nullable collection fields (the original crash),
  // and not-passed vs. explicit-null for the nullable field.
  'confirmedDays': ks.list(ks.int()).defaultTo(const []),
  'dayNotes': ks.map(ks.string(), ks.int()).defaultTo(const {}),
  'ownerNote': ks.string().optional().nullable(),
});
