import 'package:meta/meta.dart';

import 'dart:async';

import 'package:keyed_form_core/keyed_form_core.dart';

import 'keyed_form_mode.dart';

/// A declarative asynchronous validation rule bound to typed field references.
sealed class KeyedFormAsyncValidator<S> {
  const KeyedFormAsyncValidator._();

  /// Resolves this rule against one local draft.
  @internal
  void resolve(
    S draft,
    FieldKey prefix,
    KeyedFormAsyncValidatorVisitor visitor,
  );

  /// Validates a field in the current local scope.
  static KeyedFormAsyncValidator<R> field<R, V>({
    required FieldRef<R, V> field,
    required FutureOr<String?> Function(R draft, V value) validate,
    Duration? timeout,
    KeyedFormAsyncFailureMode? failureMode,
    void Function(Object error, StackTrace stackTrace)? onFailure,
  }) => _FieldAsyncValidator<R, V>(
    field: field,
    validate: validate,
    timeout: timeout,
    failureMode: failureMode,
    onFailure: onFailure,
  );

  /// Applies [rules] independently to every row in [list].
  static KeyedFormAsyncValidator<R> forEach<R, Item extends KeyedRow>({
    required FieldRef<R, List<Item>> list,
    required List<KeyedFormAsyncValidator<Item>> rules,
  }) => _ForEachAsyncValidator<R, Item>(
    list: list,
    rules: List.unmodifiable(rules),
  );
}

/// Typed visitor used by the controller to make closures over each local draft.
abstract interface class KeyedFormAsyncValidatorVisitor {
  void field<R, V>({
    required FieldKey key,
    required R draft,
    required V value,
    required FutureOr<String?> Function(R, V) validate,
    required Duration? timeout,
    required KeyedFormAsyncFailureMode? failureMode,
    required void Function(Object, StackTrace)? onFailure,
  });
}

final class _FieldAsyncValidator<R, V> extends KeyedFormAsyncValidator<R> {
  const _FieldAsyncValidator({
    required this.field,
    required this.validate,
    required this.timeout,
    required this.failureMode,
    required this.onFailure,
  }) : super._();

  final FieldRef<R, V> field;
  final FutureOr<String?> Function(R draft, V value) validate;
  final Duration? timeout;
  final KeyedFormAsyncFailureMode? failureMode;
  final void Function(Object error, StackTrace stackTrace)? onFailure;

  @override
  void resolve(
    R draft,
    FieldKey prefix,
    KeyedFormAsyncValidatorVisitor visitor,
  ) {
    final found = field.find(draft);
    if (found case Some(:final value)) {
      visitor.field(
        key: prefix + field.key,
        draft: draft,
        value: value,
        validate: validate,
        timeout: timeout,
        failureMode: failureMode,
        onFailure: onFailure,
      );
    }
  }
}

final class _ForEachAsyncValidator<R, Item extends KeyedRow>
    extends KeyedFormAsyncValidator<R> {
  const _ForEachAsyncValidator({required this.list, required this.rules})
    : super._();

  final FieldRef<R, List<Item>> list;
  final List<KeyedFormAsyncValidator<Item>> rules;

  @override
  void resolve(
    R draft,
    FieldKey prefix,
    KeyedFormAsyncValidatorVisitor visitor,
  ) {
    final found = list.find(draft);
    if (found case Some(:final value)) {
      final ids = <String>{};
      for (final row in value) {
        if (!ids.add(row.clientId)) {
          throw ArgumentError.value(
            row.clientId,
            'clientId',
            'Duplicate row id in ${list.key}',
          );
        }
        final rowPrefix = prefix + list.key + .id(row.clientId);
        for (final rule in rules) {
          rule.resolve(row, rowPrefix, visitor);
        }
      }
    }
  }
}
