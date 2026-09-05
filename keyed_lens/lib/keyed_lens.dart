/// Keyed optics for immutable aggregates.
///
/// Not a general-purpose optics library: every lens carries a [FieldKey] —
/// a stable, serializable identity — because the point is addressing fields
/// of an aggregate across concerns (errors, dirty, focus, patches), not
/// functional-programming completeness.
library;

export 'src/field_errors.dart';
export 'src/field_key.dart';
export 'src/keyed_row.dart';
export 'src/lens.dart';
export 'src/list_lens.dart';
export 'src/opt.dart';
export 'src/prism.dart';
