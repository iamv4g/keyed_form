/// Keyed optics for immutable aggregates.
///
/// Every [Lens] / [AffineLens] carries a [FieldKey] — a stable, serializable
/// identity — so one accessor addresses the same field for reading, writing,
/// diffing, and any keyed side-channel kept next to the data (validation
/// errors, dirty state, focus, undo grouping, server patches, deep links).
///
/// That identity is the distinguishing feature, not optics completeness:
/// there is no Iso/Traversal and no profunctor machinery, and the package
/// has zero dependencies.
library;

export 'src/field_errors.dart';
export 'src/field_key.dart';
export 'src/keyed_row.dart';
export 'src/lens.dart';
export 'src/list_lens.dart';
export 'src/opt.dart';
export 'src/prism.dart';
