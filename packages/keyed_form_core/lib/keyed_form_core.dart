/// Shared vocabulary for the keyed_form family.
///
/// Sits on top of `keyed_lens` and below `keyed_form_schema` / `keyed_form`.
/// It gives the form layers a single "field reference" vocabulary —
/// [FieldRef], [StrictFieldRef], [VariantRef] — over the raw optics, plus
/// [FieldErrors], [DelegatingFieldRef] (the base generated wrappers extend),
/// and the [KeyedSchema] annotation.
///
/// The raw optic names (`Lens` / `AffineLens` / `Prism` / `ListItemLens`) are
/// deliberately not re-exported here — the aliases are complete substitutes.
/// Reach for `package:keyed_lens/keyed_lens.dart` directly only for
/// standalone optics work.
library;

export 'package:keyed_lens/keyed_lens.dart'
    show FieldKey, Segment, NameSegment, IdSegment, Opt, Some, None, KeyedRow;

export 'src/annotation.dart';
export 'src/field_errors.dart';
export 'src/field_ref.dart';
