## 0.1.0

- Initial extracted snapshot: `build_runner` codegen from a `keyed_schema`
  declaration to an immutable data class, `Fields`/`FieldRefs` keyed
  optics, and sync/async validation methods.
- Generated `copyWith` hardened to a typed public interface backed by a
  private sentinel-based implementation (nullable fields use the sentinel,
  non-nullable fields never do), fixing type-inference failures on bare
  collection literals at call sites.
