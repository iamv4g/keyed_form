/// Declarative, schema-driven validation and type-safe form models.
///
/// Compose field validators (`ks.string()`, `ks.int()`, …) into object schemas
/// (`ks.object({...})`) that yield [FieldKey]-addressed [FieldErrors]. Combine
/// with `keyed_form_gen` to generate the immutable data classes and field
/// references. Re-exports `keyed_form_core` (and thus `@keyedSchema`).
library;

export 'package:keyed_form_core/keyed_form_core.dart';
export 'package:uuid/uuid.dart';

export 'src/error.dart';
export 'src/issue.dart';
export 'src/ks.dart';
export 'src/validators/bool_validator.dart';
export 'src/validators/enum_validator.dart';
export 'src/validators/list_validator.dart';
export 'src/validators/map_validator.dart';
export 'src/validators/num_validator.dart';
export 'src/validators/object_validator.dart';
export 'src/validators/string_validator.dart';
export 'src/validators/union_validator.dart';
export 'src/validators/validator.dart';
