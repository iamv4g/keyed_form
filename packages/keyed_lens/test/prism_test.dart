import 'package:keyed_lens/keyed_lens.dart';
import 'package:test/test.dart';

// Minimal sealed hierarchy fixture to test Prism with Dart 3 pattern matching.
sealed class Shape {
  const Shape({required this.id});
  final String id;
}

final class Circle extends Shape {
  const Circle({required super.id, required this.radius});
  final double radius;

  Circle copyWith({double? radius}) =>
      Circle(id: id, radius: radius ?? this.radius);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Circle && other.id == id && other.radius == radius;

  @override
  int get hashCode => Object.hash(id, radius);
}

final class Square extends Shape {
  const Square({required super.id, required this.side});
  final double side;

  Square copyWith({double? side}) => Square(id: id, side: side ?? this.side);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Square && other.id == id && other.side == side;

  @override
  int get hashCode => Object.hash(id, side);
}

class Canvas {
  const Canvas({required this.shape});
  final Shape shape;

  Canvas copyWith({Shape? shape}) => Canvas(shape: shape ?? this.shape);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Canvas && other.shape == shape;

  @override
  int get hashCode => shape.hashCode;
}

void main() {
  group('Prism unit & optic laws', () {
    final circlePrism = Prism<Shape, Circle>.type();
    final squarePrism = Prism<Shape, Square>.type();

    const circle = Circle(id: 'c1', radius: 10.0);
    const square = Square(id: 's1', side: 20.0);

    test('Prism.type matches correct variant and rejects others', () {
      expect(circlePrism.matches(circle), isTrue);
      expect(circlePrism.matches(square), isFalse);

      expect(squarePrism.matches(square), isTrue);
      expect(squarePrism.matches(circle), isFalse);

      expect(circlePrism.preview(circle), equals(circle));
      expect(circlePrism.preview(square), isNull);
    });

    test(
      'Law 1: Set-Get (writing variant to matching source yields that variant)',
      () {
        const updatedCircle = Circle(id: 'c1', radius: 15.0);
        final result = circlePrism.set(circle, updatedCircle);

        expect(circlePrism.find(result), equals(const Some(updatedCircle)));
        expect(circlePrism.preview(result), equals(updatedCircle));
      },
    );

    test('Law 2: Get-Set (setting what was read is an identity no-op)', () {
      final found = circlePrism.preview(circle);
      expect(found, isNotNull);

      final result = circlePrism.set(circle, found!);
      expect(result, equals(circle));
    });

    test(
      'Law 3: No-op on Mismatch (setting on non-matching variant returns source unchanged)',
      () {
        const newCircle = Circle(id: 'c2', radius: 99.0);
        final result = circlePrism.set(square, newCircle);

        // Must return the exact instance unchanged
        expect(identical(result, square), isTrue);
        expect(result, equals(square));
      },
    );

    test('Law 4: Review-Preview (preview of review is Some)', () {
      final reviewed = circlePrism.review(circle);
      expect(circlePrism.preview(reviewed), equals(circle));
    });

    test(
      'Law 5: Review identity (reviewing a subtype yields the subtype instance)',
      () {
        expect(circlePrism.review(circle), equals(circle));
      },
    );

    test('Prism.of custom preview and review', () {
      final customCirclePrism = Prism<Shape, Circle>.of(
        preview: (s) => switch (s) {
          Circle c => Some(c),
          Square _ => const None(),
        },
        review: (c) => c,
      );

      expect(customCirclePrism.matches(circle), isTrue);
      expect(customCirclePrism.matches(square), isFalse);
      expect(customCirclePrism.preview(circle), equals(circle));
      expect(customCirclePrism.preview(square), isNull);

      const updatedCircle = Circle(id: 'c1', radius: 25.0);
      expect(
        customCirclePrism.set(circle, updatedCircle),
        equals(updatedCircle),
      );
      expect(
        identical(customCirclePrism.set(square, updatedCircle), square),
        isTrue,
      );
    });
  });

  group('Prism composition & FieldKey', () {
    final circlePrism = Prism<Shape, Circle>.type();
    final radiusLens = Lens<Circle, double>.of(
      key: FieldKey.name('radius'),
      get: (c) => c.radius,
      set: (c, v) => c.copyWith(radius: v),
    );
    final canvasShapeLens = Lens<Canvas, Shape>.of(
      key: FieldKey.name('shape'),
      get: (c) => c.shape,
      set: (c, v) => c.copyWith(shape: v),
    );

    test(
      'Prism carries FieldKey.empty by default and does not corrupt path',
      () {
        expect(circlePrism.key.isRoot, isTrue);

        final composed = canvasShapeLens.then(circlePrism).then(radiusLens);
        expect(composed.key.toPath(), equals('shape.radius'));
      },
    );

    test('narrow() extension composes cleanly as an alias for then()', () {
      final composed = canvasShapeLens.narrow(circlePrism).then(radiusLens);
      expect(composed.key.toPath(), equals('shape.radius'));

      const canvasWithCircle = Canvas(shape: Circle(id: 'c1', radius: 12.0));
      const canvasWithSquare = Canvas(shape: Square(id: 's1', side: 30.0));

      // Reading through composition
      expect(composed.getOrNull(canvasWithCircle), equals(12.0));
      expect(composed.getOrNull(canvasWithSquare), isNull);

      // Writing through composition on matching variant
      final updatedCanvas = composed.set(canvasWithCircle, 18.0);
      expect(updatedCanvas.shape, equals(const Circle(id: 'c1', radius: 18.0)));

      // Writing through composition on mismatch is an identical no-op
      final noopCanvas = composed.set(canvasWithSquare, 99.0);
      expect(identical(noopCanvas, canvasWithSquare), isTrue);
    });

    test(
      'update() modifies matching variant and leaves mismatch untouched',
      () {
        final composed = canvasShapeLens.narrow(circlePrism).then(radiusLens);

        const canvasWithCircle = Canvas(shape: Circle(id: 'c1', radius: 10.0));
        const canvasWithSquare = Canvas(shape: Square(id: 's1', side: 20.0));

        final updated = composed.update(canvasWithCircle, (r) => r * 2);
        expect((updated.shape as Circle).radius, equals(20.0));

        final untouched = composed.update(canvasWithSquare, (r) => r * 2);
        expect(identical(untouched, canvasWithSquare), isTrue);
      },
    );
  });
}
