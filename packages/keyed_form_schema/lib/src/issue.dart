/// The category of a validation [KSIssue] — the coarse "what kind of failure"
/// tag that error resolvers and the code generator switch on.
enum KSIssueCode {
  /// Wrong runtime type, or missing/`null` where a value is required.
  invalidType('invalid_type'),

  /// Below a minimum length, count or numeric bound.
  tooSmall('too_small'),

  /// Above a maximum length, count or numeric bound.
  tooBig('too_big'),

  /// A string format check (email, time, regex, …) failed.
  invalidFormat('invalid_format'),

  /// Not one of an allowed set of values (e.g. an enum).
  invalidValue('invalid_value'),

  /// Produced by a user `refine` rule.
  custom('custom');

  const KSIssueCode(this.value);

  /// The stable wire string for this code (e.g. `too_small`).
  final String value;

  @override
  String toString() => value;
}

/// What kind of value a [KSTooSmallIssue] / [KSTooBigIssue] is about, so the
/// default message can read "characters" vs "items" vs a bare number.
enum KSIssueOrigin {
  /// A string's length.
  string,

  /// A general number.
  number,

  /// An integer.
  int,

  /// A double.
  double,

  /// A list's element count.
  list,

  /// A map's entry count.
  map,

  /// Anything else — a bare bound with no unit.
  custom;

  @override
  String toString() => name;
}

/// The specific string format that a [KSInvalidFormatIssue] reports.
enum KSStringFormat {
  /// Email address.
  email,

  /// Decimal number in string form.
  numeric,

  /// `HH:mm` 24-hour time.
  time,

  /// An arbitrary caller-supplied regular expression.
  regex,

  /// A caller-defined format.
  custom;

  @override
  String toString() => name;
}

/// One validation failure: a [code] category, the offending [input], the
/// [path] to it, and a default [message]. Sealed — every concrete issue is one
/// of the `final` subclasses below.
sealed class KSIssue {
  const KSIssue({
    required this.code,
    this.input,
    this.path = const [],
    required this.message,
  });

  /// The failure category.
  final KSIssueCode code;

  /// The value that failed, when available.
  final Object? input;

  /// Path segments from the validated root to the offending value.
  final List<Object> path;

  /// The default, human-readable message (before any [KSError] override).
  final String message;

  @override
  String toString() =>
      '$runtimeType(code: $code, message: $message, path: $path, input: $input)';
}

/// A value has the wrong type, or is missing / `null` where required.
final class KSInvalidTypeIssue extends KSIssue {
  const KSInvalidTypeIssue({
    required this.expected,
    super.input,
    super.path,
    String? message,
  }) : super(
         code: .invalidType,
         message:
             message ?? (input == null ? 'Required' : 'Expected $expected'),
       );

  /// The type that was expected (e.g. `string`, `int`).
  final String expected;
}

/// A string length, number value, or list/map count is below the minimum.
final class KSTooSmallIssue extends KSIssue {
  const KSTooSmallIssue({
    required this.origin,
    required this.minimum,
    this.inclusive = true,
    this.exact = false,
    super.input,
    super.path,
    String? message,
  }) : super(
         code: .tooSmall,
         message:
             message ??
             (exact
                 ? (origin == .string
                       ? 'Must be exactly $minimum characters'
                       : 'Must be exactly $minimum')
                 : (origin == .string
                       ? 'Must be at least $minimum characters'
                       : (origin == .list
                             ? 'Must have at least $minimum items'
                             : 'Must be at least $minimum'))),
       );

  /// What the bound measures — drives the default message wording.
  final KSIssueOrigin origin;

  /// The minimum the value fell short of.
  final num minimum;

  /// Whether [minimum] itself is allowed.
  final bool inclusive;

  /// Whether the constraint is an exact match rather than a lower bound.
  final bool exact;
}

/// A string length, number value, or list/map count exceeds the maximum.
final class KSTooBigIssue extends KSIssue {
  const KSTooBigIssue({
    required this.origin,
    required this.maximum,
    this.inclusive = true,
    this.exact = false,
    super.input,
    super.path,
    String? message,
  }) : super(
         code: .tooBig,
         message:
             message ??
             (exact
                 ? (origin == .string
                       ? 'Must be exactly $maximum characters'
                       : (origin == .list
                             ? 'Must have exactly $maximum items'
                             : 'Must be exactly $maximum'))
                 : (origin == .string
                       ? 'Must be at most $maximum characters'
                       : (origin == .list
                             ? 'Must have at most $maximum items'
                             : 'Must be at most $maximum'))),
       );

  /// What the bound measures — drives the default message wording.
  final KSIssueOrigin origin;

  /// The maximum the value exceeded.
  final num maximum;

  /// Whether [maximum] itself is allowed.
  final bool inclusive;

  /// Whether the constraint is an exact match rather than an upper bound.
  final bool exact;
}

/// A string format check (email, numeric, time, regex, …) failed.
final class KSInvalidFormatIssue extends KSIssue {
  const KSInvalidFormatIssue({
    required this.format,
    this.pattern,
    super.input,
    super.path,
    required super.message,
  }) : super(code: .invalidFormat);

  /// Which format was expected.
  final KSStringFormat format;

  /// The regular-expression source, when [format] is [KSStringFormat.regex].
  final String? pattern;
}

/// The input is not one of an allowed set of values (e.g. an enum).
final class KSInvalidValueIssue extends KSIssue {
  const KSInvalidValueIssue({
    required this.values,
    super.input,
    super.path,
    String? message,
  }) : super(code: .invalidValue, message: message ?? 'Invalid selection');

  /// The values that would have been accepted.
  final List<Object?> values;
}

/// Produced by a user-supplied `refine` rule.
final class KSCustomIssue extends KSIssue {
  const KSCustomIssue({
    this.params,
    super.input,
    super.path,
    required super.message,
  }) : super(code: .custom);

  /// Arbitrary data passed through from the `refine` call, for a translator
  /// to interpolate into a localized message.
  final Map<String, Object?>? params;
}
