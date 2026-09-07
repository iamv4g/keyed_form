import 'package:keyed_form_schema/keyed_form_schema.dart';
import 'package:test/test.dart';

import 'fixtures/tour_schema.dart';

void main() {
  group('Generated Nested TourSchema & HotelSchema & Fields & Validator', () {
    test(
      'auto-generates clientId and navigates with lenses via TourSchema.fields',
      () {
        final hotel1 = HotelSchema.create(
          hotelName: 'Kyoto Grand Hotel',
          hotelPrice: '20000',
        );
        final hotel2 = HotelSchema.create(
          hotelName: 'Osaka Royal Hotel',
          hotelPrice: '15000',
        );

        expect(Uuid.isValidUUID(fromString: hotel1.clientId), true);
        expect(Uuid.isValidUUID(fromString: hotel2.clientId), true);
        expect(hotel1.clientId != hotel2.clientId, true);

        var tour = TourSchema.create(
          title: 'Kyoto & Osaka Tour',
          hotels: [hotel1, hotel2],
        );

        final hotel1Ref = (hotel: hotel1.clientId);
        expect(
          TourFields.hotel(hotel1Ref).hotelName.getOrNull(tour),
          'Kyoto Grand Hotel',
        );
        expect(TourFields.hotel(hotel1Ref).hotelPrice.getOrNull(tour), '20000');
        expect(HotelFields.hotelName.get(hotel1), 'Kyoto Grand Hotel');

        final hotel2Ref = (hotel: hotel2.clientId);
        expect(
          TourFields.hotel(hotel2Ref).hotelName.getOrNull(tour),
          'Osaka Royal Hotel',
        );

        // Edit via the wrapper's leaf FieldRef
        tour = TourFields.hotel(
          hotel1Ref,
        ).hotelName.set(tour, 'Kyoto Grand Hotel (Renovated)');
        expect(
          TourFields.hotel(hotel1Ref).hotelName.getOrNull(tour),
          'Kyoto Grand Hotel (Renovated)',
        );
      },
    );

    test('validates nested tour and hotel items via tour.validate()', () {
      final invalidHotel = HotelSchema.create(hotelName: ''); // Empty name
      final tour = TourSchema.create(
        title: 'Hi', // Too short (< 3)
        hotels: [invalidHotel],
      );

      final errors = tour.validate();
      expect(errors.isNotEmpty, true);
    });
  });

  // Regression coverage for the copyWith callable-interface redesign: the
  // public `TourSchemaCopyWith.call()` types every field for real, so a
  // bare `[]`/`{}` literal at a copyWith call site gets proper downward
  // inference — this is exactly what crashed `TourGuideSchema.copyWith(
  // dateIndexes: [])` from `guide_row.dart` in the app (commit 374d375,
  // patched there only at the call site). The private
  // `_TourSchemaCopyWithImpl` still uses the `Object? = _unset` sentinel,
  // so "not passed" vs. "explicitly passed null" stays distinguishable —
  // verified below against the real generated code, not just a hand-written
  // prototype.
  group('copyWith — typed interface, sentinel-based impl', () {
    final base = TourSchema.create(title: 'Base Tour', ownerNote: 'note');

    test('bare [] literal for a List<int> field does not throw', () {
      final next = base.copyWith(confirmedDays: []);
      expect(next.confirmedDays, isA<List<int>>());
      expect(next.confirmedDays, isEmpty);
    });

    test('bare {} literal for a Map<K,V> field does not throw', () {
      final next = base.copyWith(dayNotes: {});
      expect(next.dayNotes, isA<Map<String, int>>());
      expect(next.dayNotes, isEmpty);
    });

    test('bare [] literal for a List<Item> (nested data class) field '
        'does not throw', () {
      final next = base.copyWith(hotels: []);
      expect(next.hotels, isA<List<HotelSchema>>());
      expect(next.hotels, isEmpty);
    });

    test('a correctly-typed non-empty value still round-trips', () {
      final next = base.copyWith(
        confirmedDays: [1, 2, 3],
        dayNotes: {'d1': 10},
      );
      expect(next.confirmedDays, [1, 2, 3]);
      expect(next.dayNotes, {'d1': 10});
    });

    test('not passing a nullable field keeps its old value', () {
      final next = base.copyWith(title: 'Renamed');
      expect(next.ownerNote, 'note');
    });

    test('passing a real value for a nullable field sets it', () {
      final next = base.copyWith(ownerNote: 'new note');
      expect(next.ownerNote, 'new note');
    });

    test('explicitly passing null for a nullable field clears it', () {
      final next = base.copyWith(ownerNote: null);
      expect(next.ownerNote, isNull);
    });
  });

  group('Map field equality/hashCode (deep, order-independent)', () {
    test('two maps with the same entries in different order are ==', () {
      final a = TourSchema.create(title: 'Tour', dayNotes: {'d1': 1, 'd2': 2});
      final b = TourSchema.create(title: 'Tour', dayNotes: {'d2': 2, 'd1': 1});
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('maps with different content are not ==', () {
      final a = TourSchema.create(title: 'Tour', dayNotes: {'d1': 1});
      final b = TourSchema.create(title: 'Tour', dayNotes: {'d1': 2});
      expect(a, isNot(equals(b)));
    });
  });
}
