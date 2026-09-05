import 'dart:math';

import 'package:keyed_lens/keyed_lens.dart';
import 'package:test/test.dart';

// A domain id modeled as an extension type over String — the pattern the
// itinerary demo uses (DayId/GroupId). It erases to String at runtime, so
// keys built from it must serialize and compare exactly like a raw String id.
extension type DayId(String value) implements String {}

void main() {
  group('toPath round-trips (parse(k.toPath()) == k)', () {
    void roundTrips(String label, FieldKey key, String expectedPath) {
      test(label, () {
        expect(key.toPath(), expectedPath);
        expect(FieldKey.parse(key.toPath()), key);
        expect(FieldKey.tryParse(expectedPath), key);
      });
    }

    roundTrips('root is the empty string', FieldKey.root, '');
    roundTrips('single name', FieldKey.name('note'), 'note');
    roundTrips('single string id', FieldKey.id('d1'), "['d1']");
    roundTrips('single int id', FieldKey.id(42), '[42]');
    roundTrips('negative int id', FieldKey.id(-7), '[-7]');
    roundTrips('zero int id', FieldKey.id(0), '[0]');
    roundTrips(
      'multi-level mixed path',
      FieldKey.name('days') +
          FieldKey.id('d1') +
          FieldKey.name('groups') +
          FieldKey.id('g2') +
          FieldKey.name('name'),
      "days.['d1'].groups.['g2'].name",
    );
    roundTrips(
      'int id mid-path',
      FieldKey.name('days') + FieldKey.id(3) + FieldKey.name('note'),
      'days.[3].note',
    );
    roundTrips(
      'path starting with an id',
      FieldKey.id('d1') + FieldKey.name('name'),
      "['d1'].name",
    );
    roundTrips(
      'consecutive ids',
      FieldKey.name('days') + FieldKey.id('d1') + FieldKey.id('x'),
      "days.['d1'].['x']",
    );
    roundTrips('empty-string id is legal', FieldKey.id(''), "['']");
    roundTrips(
      'reserved chars in a name are percent-encoded',
      FieldKey.name('a.b[c]%d'),
      'a%2Eb%5Bc%5D%25d',
    );
    roundTrips(
      'dots inside a quoted string id need no escaping',
      FieldKey.name('days') + FieldKey.id('a.b') + FieldKey.name('name'),
      "days.['a.b'].name",
    );
    roundTrips(
      'brackets inside a quoted string id need no escaping',
      FieldKey.id('a[0]'),
      "['a[0]']",
    );
    roundTrips(
      'quotes and backslashes inside a string id are escaped',
      FieldKey.id(r"a'b\c"),
      r"['a\'b\\c']",
    );
    roundTrips('unicode in a name passes through', FieldKey.name('祇園'), '祇園');
    roundTrips(
      'unicode in a string id passes through',
      FieldKey.id('京都🗾'),
      "['京都🗾']",
    );
  });

  group('distinctness survives the round trip', () {
    test('name vs id with the same text encode differently', () {
      expect(FieldKey.name('d1').toPath(), 'd1');
      expect(FieldKey.id('d1').toPath(), "['d1']");
      expect(
        FieldKey.parse(FieldKey.name('d1').toPath()),
        isNot(FieldKey.parse(FieldKey.id('d1').toPath())),
      );
    });

    test('string id vs int id with the same digits are distinct', () {
      expect(FieldKey.id('42').toPath(), "['42']");
      expect(FieldKey.id(42).toPath(), '[42]');
      expect(FieldKey.id('42'), isNot(FieldKey.id(42)));
      expect(FieldKey.parse("['42']"), FieldKey.id('42'));
      expect(FieldKey.parse('[42]'), FieldKey.id(42));
      expect(FieldKey.parse("['42']"), isNot(FieldKey.parse('[42]')));
    });
  });

  group('typed-id erasure law', () {
    test('an extension-type id encodes and compares like its String rep', () {
      final typed = FieldKey.id(DayId('d1'));
      expect(typed.toPath(), "['d1']");
      expect(typed, FieldKey.id('d1'));
      expect(IdSegment(DayId('d1')), const IdSegment('d1'));
      expect(FieldKey.parse(typed.toPath()), FieldKey.id('d1'));
    });
  });

  group(
    'malformed input fails (FormatException in parse, null in tryParse)',
    () {
      const malformed = <String, String>{
        'unterminated bracket': 'days.[',
        'unterminated quote': "days.['d1",
        'non-numeric int id': '[42x]',
        'leading-zero int id': '[042]',
        'negative-zero int id': '[-0]',
        'empty bracket': '[]',
        'unescaped quote in string id': "['a'b']",
        'bad escape in string id': r"['a\xb']",
        'raw open bracket in a name': 'da[ys',
        'raw close bracket in a name': 'da]ys',
        'attached bracket (no separator)': "days['d1']",
        'bad percent escape (too short)': 'a%2',
        'bad percent escape (non-hex)': 'a%2Gb',
        'leading separator': '.days',
        'trailing separator': 'days.',
        'empty segment between dots': 'a..b',
        'token not followed by separator': "['d1']name",
      };

      malformed.forEach((label, path) {
        test(label, () {
          expect(() => FieldKey.parse(path), throwsFormatException);
          expect(FieldKey.tryParse(path), isNull);
        });
      });
    },
  );

  group('encode-time programmer errors throw ArgumentError', () {
    test('empty name segment', () {
      expect(FieldKey.name('').toPath, throwsArgumentError);
    });

    test('non-String/int id', () {
      expect(FieldKey.id(3.5).toPath, throwsArgumentError);
      expect(FieldKey.id(#sym).toPath, throwsArgumentError);
    });
  });

  group('seeded-random fuzz: parse(k.toPath()) == k', () {
    // Hand-rolled generator over the reserved charset + unicode; a fixed seed
    // keeps failures reproducible and adds no dev dependency.
    const nameAlphabet =
        r'ab.[]%\ '
        '祇0-';
    const idAlphabet = r"ab'\.[]% 京-0";

    FieldKey randomKey(Random rng) {
      final depth = rng.nextInt(5); // 0..4 → also exercises root
      final segments = <Segment>[];
      for (var d = 0; d < depth; d++) {
        switch (rng.nextInt(3)) {
          case 0:
            segments.add(NameSegment(_randomNonEmpty(rng, nameAlphabet)));
          case 1:
            segments.add(IdSegment(_randomString(rng, idAlphabet)));
          default:
            segments.add(IdSegment(rng.nextInt(2000000) - 1000000));
        }
      }
      return FieldKey(segments);
    }

    test('1000 random keys survive encode/decode', () {
      final rng = Random(0xC0DEC);
      for (var n = 0; n < 1000; n++) {
        final key = randomKey(rng);
        final path = key.toPath();
        expect(
          FieldKey.parse(path),
          key,
          reason: 'round trip failed for path <$path>',
        );
        expect(FieldKey.tryParse(path), key);
      }
    });
  });
}

String _randomString(Random rng, String alphabet) {
  final len = rng.nextInt(6); // 0..5, includes empty (legal for string ids)
  final buf = StringBuffer();
  for (var i = 0; i < len; i++) {
    buf.write(alphabet[rng.nextInt(alphabet.length)]);
  }
  return buf.toString();
}

String _randomNonEmpty(Random rng, String alphabet) {
  final s = _randomString(rng, alphabet);
  return s.isEmpty ? alphabet[rng.nextInt(alphabet.length)] : s;
}
