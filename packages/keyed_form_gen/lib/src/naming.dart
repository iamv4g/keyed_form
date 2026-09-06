/// Class-naming helpers shared by [DataClassGenerator] and its field-ref wrapper
/// subsystem. Not exported from the package's public API — internal to the
/// generator only.
library;

String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String uncapitalize(String s) =>
    s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);

/// Strips [suffix] (or, failing that, the literal `'Schema'`) off the end of
/// [name] — the inverse of how a generated class is named from its schema
/// field/variable name.
String getSingularName(String name, String suffix) {
  if (name.length > suffix.length && name.endsWith(suffix)) {
    return name.substring(0, name.length - suffix.length);
  }
  if (name.length > 'Schema'.length && name.endsWith('Schema')) {
    return name.substring(0, name.length - 'Schema'.length);
  }
  return name;
}

String getFieldsClassName(String name, String suffix) {
  if (name.length > suffix.length && name.endsWith(suffix)) {
    return '${name.substring(0, name.length - suffix.length)}Fields';
  }
  if (name.length > 'Schema'.length && name.endsWith('Schema')) {
    return '${name.substring(0, name.length - 'Schema'.length)}Fields';
  }
  return '${name}Fields';
}

/// The library-private holder class for a union's per-variant [VariantRef]s
/// (e.g. `_SectionVariants`). Only the generated `.asX` narrower getters
/// reference it.
String getVariantsClassName(String name, String suffix) {
  if (name.length > suffix.length && name.endsWith(suffix)) {
    return '_${name.substring(0, name.length - suffix.length)}Variants';
  }
  if (name.length > 'Schema'.length && name.endsWith('Schema')) {
    return '_${name.substring(0, name.length - 'Schema'.length)}Variants';
  }
  return '_${name}Variants';
}
