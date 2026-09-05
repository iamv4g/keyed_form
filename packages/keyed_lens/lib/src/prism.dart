import 'package:keyed_lens/src/field_key.dart';
import 'package:keyed_lens/src/lens.dart';
import 'package:keyed_lens/src/opt.dart';

/// A composable optic for sum types (discriminated unions / sealed hierarchies).
///
/// While a [Lens] focuses on a subpart that *always* exists (product type),
/// and an [AffineLens] focuses on a subpart that *may* exist, a [Prism] focuses
/// on a specific **variant** of a sum type.
///
/// In addition to the [AffineLens] operations ([find], [set], [update]), a
/// [Prism] can construct a [Source] directly from a [Variant] via [review]
/// without requiring a pre-existing [Source] instance.
///
/// When [set] is called on a [Source] that does not match this variant, it
/// returns the [Source] unchanged (identity no-op), satisfying the standard
/// prism laws.
///
/// By default, a [Prism] carries [FieldKey.empty] because type narrowing is an
/// in-place type guard on the existing entity, preserving the stable field identity
/// across the aggregate.
abstract class Prism<Source, Variant extends Source>
    extends AffineLens<Source, Variant> {
  const Prism();

  /// Creates a [Prism] leveraging Dart's type system (`source is Variant`).
  ///
  /// This requires zero boilerplate when using Dart 3 sealed class hierarchies.
  factory Prism.type({FieldKey? key}) =>
      _TypePrism<Source, Variant>(key ?? FieldKey.empty);

  /// Creates a [Prism] from explicit [preview] (narrowing) and optional [review]
  /// (widening/constructor) functions.
  ///
  /// If [review] is omitted, it defaults to identity casting since [Variant]
  /// is a subtype of [Source].
  factory Prism.of({
    FieldKey? key,
    required Opt<Variant> Function(Source source) preview,
    Source Function(Variant variant)? review,
  }) =>
      _FunctionPrism<Source, Variant>(
        key ?? FieldKey.empty,
        preview,
        review ?? (variant) => variant,
      );

  /// Constructs a [Source] containing this [Variant].
  Source review(Variant variant);

  /// Returns `true` if [source] matches this prism's variant.
  bool matches(Source source) => find(source) is Some<Variant>;

  /// Everyday extraction. Returns the [Variant] if [source] matches, or `null`.
  Variant? preview(Source source) => getOrNull(source);
}

final class _TypePrism<Source, Variant extends Source>
    extends Prism<Source, Variant> {
  const _TypePrism(this.key);

  @override
  final FieldKey key;

  @override
  Opt<Variant> find(Source source) =>
      source is Variant ? Some(source) : const None();

  @override
  Source review(Variant variant) => variant;

  @override
  Source set(Source source, Variant value) =>
      source is Variant ? value : source;
}

final class _FunctionPrism<Source, Variant extends Source>
    extends Prism<Source, Variant> {
  const _FunctionPrism(this.key, this._preview, this._review);

  @override
  final FieldKey key;
  final Opt<Variant> Function(Source source) _preview;
  final Source Function(Variant variant) _review;

  @override
  Opt<Variant> find(Source source) => _preview(source);

  @override
  Source review(Variant variant) => _review(variant);

  @override
  Source set(Source source, Variant value) => switch (find(source)) {
        Some() => _review(value),
        None() => source,
      };
}

/// Extension adding explicit type-narrowing semantics to [AffineLens].
extension AffineLensNarrowX<Root, Value> on AffineLens<Root, Value> {
  /// Narrows an [AffineLens] focusing on a [Value] (e.g. a sealed base class)
  /// to a specific [Variant] through a [Prism].
  ///
  /// This is an expressive alias for `then(prism)` that highlights the
  /// type-narrowing intent at call sites.
  AffineLens<Root, Variant> narrow<Variant extends Value>(
    Prism<Value, Variant> prism,
  ) =>
      then(prism);
}
