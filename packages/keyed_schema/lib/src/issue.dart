/// Issue code categories, modeled after Zod v4.
enum KSIssueCode {
  invalidType('invalid_type'),
  tooSmall('too_small'),
  tooBig('too_big'),
  invalidFormat('invalid_format'),
  invalidValue('invalid_value'),
  custom('custom');

  const KSIssueCode(this.value);
  final String value;

  @override
  String toString() => value;
}

/// Data type origin for size/range constraints (tooSmall, tooBig).
enum KSIssueOrigin {
  string,
  number,
  int,
  double,
  list,
  map,
  custom;

  @override
  String toString() => name;
}

/// String format types for [KSInvalidFormatIssue].
enum KSStringFormat {
  email,
  numeric,
  time,
  regex,
  custom;

  @override
  String toString() => name;
}

/// Base class for all validation issues, modeled after Zod v4.
sealed class KSIssue {
  const KSIssue({
    required this.code,
    this.input,
    this.path = const [],
    required this.message,
  });

  final KSIssueCode code;
  final Object? input;
  final List<Object> path;
  final String message;

  @override
  String toString() =>
      '$runtimeType(code: $code, message: $message, path: $path, input: $input)';
}

/// Triggered when a value has an invalid type or is missing (null) when required.
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

  final String expected;
}

/// Triggered when a string length, number value, or list count is smaller than the minimum.
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

  final KSIssueOrigin origin;
  final num minimum;
  final bool inclusive;
  final bool exact;
}

/// Triggered when a string length, number value, or list count exceeds the maximum.
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

  final KSIssueOrigin origin;
  final num maximum;
  final bool inclusive;
  final bool exact;
}

/// Triggered when a string format (e.g. email, numeric, time, regex) fails.
final class KSInvalidFormatIssue extends KSIssue {
  const KSInvalidFormatIssue({
    required this.format,
    this.pattern,
    super.input,
    super.path,
    required super.message,
  }) : super(code: .invalidFormat);

  final KSStringFormat format;
  final String? pattern;
}

/// Triggered when an enum or set of allowed values does not contain the input.
final class KSInvalidValueIssue extends KSIssue {
  const KSInvalidValueIssue({
    required this.values,
    super.input,
    super.path,
    String? message,
  }) : super(code: .invalidValue, message: message ?? 'Invalid selection');

  final List<Object?> values;
}

/// Triggered by custom refinement rules.
final class KSCustomIssue extends KSIssue {
  const KSCustomIssue({
    this.params,
    super.input,
    super.path,
    required super.message,
  }) : super(code: .custom);

  final Map<String, Object?>? params;
}
