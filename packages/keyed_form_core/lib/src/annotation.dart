/// File-level annotation (`@keyedSchema library;`) that marks a library whose
/// top-level `ks.object(...)` schemas `keyed_form_gen` should generate models,
/// field references and validators for.
class KeyedSchema {
  /// Marks the annotated library for generation, appending [suffix] to
  /// generated class names.
  const KeyedSchema({this.suffix = 'Schema'});

  /// Suffix appended to generated class names (defaults to `'Schema'`).
  final String suffix;
}

/// Shorthand marker annotation with default suffix `'Schema'`: `@keyedSchema`
const keyedSchema = KeyedSchema();
