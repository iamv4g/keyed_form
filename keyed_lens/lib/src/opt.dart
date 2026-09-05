/// Minimal Some/None container used by [AffineLens.find] so that "path does
/// not resolve" (a row was removed) stays distinguishable from "field is
/// present and holds null" (a nullable field like `String? note`).
///
/// This is deliberately not a general functional Option type — it exists
/// only for that one distinction and should stay out of application code;
/// prefer `getOrNull`/`update` on the lens for everyday reads.
sealed class Opt<T> {
  const Opt();
}

final class Some<T> extends Opt<T> {
  const Some(this.value);

  final T value;

  @override
  bool operator ==(Object other) => other is Some<T> && other.value == value;

  @override
  int get hashCode => Object.hash(Some, value);

  @override
  String toString() => 'Some($value)';
}

final class None<T> extends Opt<T> {
  const None();

  @override
  bool operator ==(Object other) => other is None<T>;

  @override
  int get hashCode => (None).hashCode;

  @override
  String toString() => 'None';
}
