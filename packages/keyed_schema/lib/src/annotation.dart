/// Annotation placed at the file level (`@keyedSchema library;`) or on top-level schema declarations.
class KeyedSchema {
  const KeyedSchema({this.suffix = 'Schema'});

  /// Suffix appended to generated class names (defaults to `'Schema'`).
  final String suffix;
}

/// Shorthand marker annotation with default suffix `'Schema'`: `@keyedSchema`
const keyedSchema = KeyedSchema();
