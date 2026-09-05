/// Class-naming helpers shared by [DataClassGenerator] and its optics-wrapper
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

String getPrismsClassName(String name, String suffix) {
  if (name.length > suffix.length && name.endsWith(suffix)) {
    return '${name.substring(0, name.length - suffix.length)}Prisms';
  }
  if (name.length > 'Schema'.length && name.endsWith('Schema')) {
    return '${name.substring(0, name.length - 'Schema'.length)}Prisms';
  }
  return '${name}Prisms';
}
