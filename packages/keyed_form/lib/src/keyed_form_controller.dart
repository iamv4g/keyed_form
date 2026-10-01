import 'dart:async';

import 'package:keyed_form_core/keyed_form_core.dart';
import 'package:listen/listen.dart';
import 'package:meta/meta.dart';

import 'keyed_form_async_validator.dart';
import 'keyed_form_list.dart';
import 'keyed_form_mode.dart';
import 'keyed_form_resolver.dart';
import 'keyed_form_snapshot.dart';
import 'keyed_form_validation_result.dart';

typedef _ResolvedRule = ({
  FieldKey key,
  Object? draft,
  FutureOr<String?> Function() validate,
  Duration? timeout,
  KeyedFormAsyncFailureMode? failureMode,
  void Function(Object error, StackTrace stackTrace)? onFailure,
});

typedef _FailureObserver = ({
  void Function(Object, StackTrace)? callback,
  KeyedFormValidationFailure failure,
});

void _notifyFailureObservers(Iterable<_FailureObserver> observers) {
  Object? firstError;
  StackTrace? firstStackTrace;
  for (final observer in observers) {
    try {
      observer.callback?.call(
        observer.failure.error,
        observer.failure.stackTrace,
      );
    } catch (error, stackTrace) {
      firstError ??= error;
      firstStackTrace ??= stackTrace;
    }
  }
  if (firstError != null) {
    Error.throwWithStackTrace(firstError, firstStackTrace!);
  }
}

final class _RuleCollector implements KeyedFormAsyncValidatorVisitor {
  final List<_ResolvedRule> rules = [];

  @override
  void field<R, V>({
    required FieldKey key,
    required R draft,
    required V value,
    required FutureOr<String?> Function(R, V) validate,
    required Duration? timeout,
    required KeyedFormAsyncFailureMode? failureMode,
    required void Function(Object, StackTrace)? onFailure,
  }) {
    rules.add((
      key: key,
      draft: draft,
      validate: () => validate(draft, value),
      timeout: timeout,
      failureMode: failureMode,
      onFailure: onFailure,
    ));
  }
}

/// Owns one editable draft of [Root] and everything that hangs off it:
/// validation errors keyed by [FieldKey], which fields have been touched,
/// which subtrees have been force-revealed, and whether a submit has been
/// attempted.
///
/// It is a `ChangeNotifier` (`package:listen`) — every state change fires
/// [notifyListeners]. Reads, writes, validation lookups and dirty checks all
/// speak the `FieldRef` (lens) vocabulary, so UI code addresses a field the
/// same way whether it is reading it, writing it, or asking for its error.
///
/// Everyday field access goes through `form.field(ref)` — a `FieldHandle` whose
/// `set` / `update` are statically typed to the field:
///
/// ```dart
/// final form = KeyedFormController<InvoiceForm>(
///   initialValue: const InvoiceForm(),
///   mode: KeyedFormMode.onChange,
///   resolver: InvoiceForm.validateData, // generated; honours `scopeOf`
/// );
/// form.field(InvoiceFields.customerEmail).set('ada@example.com');
/// form.field(InvoiceFields.customerEmail).error; // null until touched / submitted
/// ```
///
/// [initialValue] doubles as the baseline for [isDirty] / [differs] / [reset];
/// [seed] re-baselines once the real saved value is known.
class KeyedFormController<Root> extends ChangeNotifier {
  KeyedFormController({
    required Root initialValue,
    required this.resolver,
    this.mode = KeyedFormMode.onSubmit,
    this.reValidateMode = KeyedFormReValidateMode.onChange,
    List<KeyedFormAsyncValidator<Root>> asyncValidators = const [],
    this.asyncValidationFailureMode = KeyedFormAsyncFailureMode.blockSubmit,
    this.scopeOf,
  }) : _value = initialValue,
       _original = initialValue,
       asyncValidators = List.unmodifiable(asyncValidators);

  final KeyedFormResolver<Root> resolver;
  final KeyedFormMode mode;
  final KeyedFormReValidateMode reValidateMode;
  final List<KeyedFormAsyncValidator<Root>> asyncValidators;
  final KeyedFormAsyncFailureMode asyncValidationFailureMode;
  final KeyedFormScopeOf? scopeOf;

  Root _value;
  Root _original;
  FieldErrors<String> _syncErrors = const FieldErrors.empty();
  FieldErrors<String> _serverErrors = const FieldErrors.empty();
  FieldErrors<String> _asyncErrors = const FieldErrors.empty();
  FieldErrors<String> _errors = const FieldErrors.empty();
  final Map<FieldKey, KeyedFormValidationFailure> _failures = {};
  final Set<FieldKey> _touched = {};
  final Set<FieldKey> _revealed = {};
  final Set<FieldKey> _validating = {};
  final Set<FieldKey> _failed = {};
  final Set<FieldKey> _readOnly = {};
  final Map<FieldKey, int> _validationGeneration = {};
  final Map<FieldKey, Set<Completer<void>>> _activeRunsByKey = {};
  final Map<FieldKey, Object?> _ruleSnapshots = {};
  bool _submitted = false;
  bool _submitting = false;
  int _epoch = 0;
  int _revision = 0;
  int? _submissionRevision;
  bool _disposed = false;

  // --- reads -----------------------------------------------------------------

  /// The current draft.
  Root get value => _value;

  /// The baseline the draft is diffed against — [initialValue], or the last
  /// value passed to [seed] / [reset].
  Root get original => _original;

  /// The full error map, ungated by visibility. Insertion order is the
  /// validation walk's document order.
  FieldErrors<String> get errors => _errors;

  bool get submitted => _submitted;

  bool get submitting => _submitting;

  /// Whether [key] is currently mid-async-validation.
  bool isValidating(FieldKey key) => _validating.contains(key);

  /// Whether [key]'s latest async verdict ended in a technical failure.
  bool isFailedValidation(FieldKey key) => _failed.contains(key);

  /// Current technical failures, independent of value errors.
  Map<FieldKey, KeyedFormValidationFailure> get validationFailures =>
      Map.unmodifiable(_failures);

  /// Whether [key] is frozen against [setField] / [updateField] / list
  /// mutation — see [markReadOnly]. Covers a key nested under a read-only
  /// scope the same way [_revealedCovers] covers a nested error.
  bool isReadOnly(FieldKey key) =>
      _readOnly.any((scope) => scope.contains(key));

  /// The fields the user has interacted with (write in [KeyedFormMode.onChange],
  /// blur elsewhere). Unmodifiable.
  Set<FieldKey> get touched => Set.unmodifiable(_touched);

  /// The subtrees whose errors are force-shown regardless of touched state —
  /// populated by [validateScopes] and [reveal], cleared by [seed] / [reset]
  /// and when a row is removed. A stale entry is harmless: a reverted subtree
  /// has no errors to show.
  Set<FieldKey> get revealed => Set.unmodifiable(_revealed);

  /// Whole-draft dirty: the draft differs from [original].
  bool get isDirty => _value != _original;

  /// Reads one field of the draft; `null` when its path no longer resolves.
  V? read<V>(FieldRef<Root, V> field) => field.getOrNull(_value);

  /// Per-field dirty check against [original] (missing-vs-present counts as
  /// different; equal or both-missing counts as clean).
  bool differs(FieldRef<Root, Object?> field) =>
      field.differs(_original, _value);

  /// The row keys of [listField] whose row differs from its [original]
  /// counterpart (matched by [KeyedRow.clientId]). Rows absent from the
  /// baseline count as dirty.
  Iterable<FieldKey> dirtyRows<Item extends KeyedRow>(
    FieldRef<Root, List<Item>> listField,
  ) sync* {
    final current = listField.getOrNull(_value) ?? const [];
    final originalRows = listField.getOrNull(_original) ?? const [];
    final byId = {for (final row in originalRows) row.clientId: row};
    for (final row in current) {
      if (byId[row.clientId] != row) {
        yield listField.key + .id(row.clientId);
      }
    }
  }

  /// An immutable copy of the coarse state — see [KeyedFormSnapshot].
  KeyedFormSnapshot<Root> get snapshot => KeyedFormSnapshot(
    value: _value,
    original: _original,
    errors: _errors,
    isDirty: isDirty,
    submitted: _submitted,
    submitting: _submitting,
  );

  // --- error visibility ----------------------------------------------------

  /// The error on [key], or `null` when there is none or it is not visible yet
  /// under the current [mode]. This is what a field widget renders.
  String? visibleError(FieldKey key) {
    final error = _errors.byKey(key);
    if (error == null) return null;
    return _isVisible(key) ? error : null;
  }

  /// [visibleError] addressed by lens.
  String? visibleErrorFor(FieldRef<Root, Object?> field) =>
      visibleError(field.key);

  /// The visible error keys, in document order — feed straight to a
  /// scroll-to-first-error routine.
  Iterable<FieldKey> get visibleErrorKeys => _errors.keys.where(_isVisible);

  /// Whether any *visible* error sits at or under [root] — for a day/section
  /// header badge.
  bool visibleErrorUnder(FieldKey root) =>
      _errors.keys.any((key) => root.contains(key) && _isVisible(key));

  bool _isVisible(FieldKey key) => switch (mode) {
    .all => true,
    .onChange => _submitted || _revealedCovers(key),
    .onBlur || .onTouched =>
      _touched.any((touched) => touched == key || touched.contains(key)) ||
          _submitted ||
          _revealedCovers(key),
    .onSubmit => _submitted || _revealedCovers(key),
  };

  bool _revealedCovers(FieldKey key) =>
      _revealed.any((scope) => scope.contains(key));

  // --- writes ------------------------------------------------------------

  // [setField] / [updateField] / [list] / [mutateList] below are `@internal`
  // only as a workaround for a Dart type-inference hole:
  // `setField<V>(FieldRef<Root, V>, V)` lets the compiler widen `V` to the
  // least upper bound of the field's type and the argument's type (FieldRef is
  // covariant in V by Dart's default), so `form.setField(stringField, 1)`
  // type-checks and fails only at runtime with a covariant TypeError. The
  // public, statically-checked path is `form.field(ref).set(value)` /
  // `.update(fn)` / `.list()` (see field_handle.dart), which pins `V` from the
  // ref alone.
  //
  // When the `variance` language feature stabilises, declare
  // `AffineLens<Root, inout Value>` in keyed_lens instead: these methods then
  // become statically safe as they stand — drop the `@internal` annotations
  // and this comment, and re-document them as public. `FieldHandle` stays as
  // the ergonomic facade.

  /// Writes [value] to [field] (no-op if the path no longer resolves, the
  /// draft is unchanged, or [field] is read-only and [force] is false).
  /// Internal primitive behind `form.field(field).set`.
  @internal
  void setField<V>(FieldRef<Root, V> field, V value, {bool force = false}) {
    if (!force && isReadOnly(field.key)) return;
    _commit(field.key, field.set(_value, value));
  }

  /// Reads [field], applies [transform], writes it back — one revalidation,
  /// one notification. No-op if [field] is read-only and [force] is false.
  /// Internal primitive behind `form.field(field).update`.
  @internal
  void updateField<V>(
    FieldRef<Root, V> field,
    V Function(V current) transform, {
    bool force = false,
  }) {
    if (!force && isReadOnly(field.key)) return;
    _commit(field.key, field.update(_value, transform));
  }

  /// A by-id list editor over [field] — append/insert/remove/move/update.
  /// Internal primitive behind `form.field(field).list()`.
  @internal
  KeyedFormList<Root, Item> list<Item extends KeyedRow>(
    FieldRef<Root, List<Item>> field,
  ) => KeyedFormList.forController(this, field);

  void _commit(FieldKey writtenKey, Root next) {
    if (next == _value) return;
    _value = next;
    _revision++;
    _reconcileRuleBindings();
    _revalidateForWrite(writtenKey);
    notifyListeners();
  }

  /// Applies [transform] to one list field and, for every row that the
  /// transform dropped, forgets that row's errors and reveal state before
  /// re-validating — so a removed row's error never outlives it even when the
  /// list's own key falls outside any validation scope. Used by [KeyedFormList].
  @internal
  void mutateList<Item extends KeyedRow>(
    FieldRef<Root, List<Item>> field,
    List<Item> Function(List<Item> current) transform, {
    bool force = false,
  }) {
    if (!force && isReadOnly(field.key)) return;
    final before = field.getOrNull(_value) ?? const [];
    final after = transform(List<Item>.of(before));
    final next = field.set(_value, after);
    if (next == _value) return;
    _value = next;
    _revision++;
    _reconcileRuleBindings();
    final survivingIds = {for (final row in after) row.clientId};
    for (final row in before) {
      if (!survivingIds.contains(row.clientId)) {
        final rowKey = field.key + FieldKey.id(row.clientId);
        _removeSubtree(rowKey);
        _revealed.removeWhere(rowKey.contains);
        _touched.removeWhere(rowKey.contains);
      }
    }
    _revalidateForWrite(field.key);
    notifyListeners();
  }

  void _revalidateForWrite(FieldKey key) {
    final shouldValidate = _submitted
        ? reValidateMode == KeyedFormReValidateMode.onChange ||
              mode == KeyedFormMode.all
        : switch (mode) {
            .onChange || .all => true,
            .onTouched => _touched.any((touched) => touched.contains(key)),
            .onBlur || .onSubmit => false,
          };
    if (shouldValidate) _automaticValidation(key);
  }

  void _cancelRunsForKey(FieldKey key) {
    final runs = _activeRunsByKey[key];
    if (runs == null) return;
    for (final run in runs) {
      if (!run.isCompleted) run.complete();
    }
    _validationGeneration[key] = (_validationGeneration[key] ?? 0) + 1;
    _validating.remove(key);
  }

  void _unlinkRun(List<_ResolvedRule> targets, Completer<void> run) {
    for (final target in targets) {
      final runs = _activeRunsByKey[target.key];
      runs?.remove(run);
      if (runs?.isEmpty ?? false) _activeRunsByKey.remove(target.key);
    }
  }

  void _reconcileRuleBindings() {
    final current = {
      for (final target in _resolveRules(_value)) target.key: target.draft,
    };
    for (final entry in _ruleSnapshots.entries.toList()) {
      if (current.containsKey(entry.key) && current[entry.key] == entry.value) {
        continue;
      }
      _cancelRunsForKey(entry.key);
      _removeSubtree(entry.key);
      _ruleSnapshots.remove(entry.key);
    }
  }

  void _invalidateRuns() {
    _epoch++;
    for (final key in _validating.toList()) {
      _validationGeneration[key] = (_validationGeneration[key] ?? 0) + 1;
    }
    for (final runs in _activeRunsByKey.values) {
      for (final run in runs) {
        if (!run.isCompleted) run.complete();
      }
    }
    _activeRunsByKey.clear();
    _validating.clear();
  }

  void _removeSubtree(FieldKey root) {
    for (final key in _activeRunsByKey.keys.where(root.contains).toList()) {
      _cancelRunsForKey(key);
    }
    _ruleSnapshots.removeWhere((key, _) => root.contains(key));
    _syncErrors = _syncErrors.removeSubtree(root);
    _serverErrors = _serverErrors.removeSubtree(root);
    _asyncErrors = _asyncErrors.removeSubtree(root);
    _failures.removeWhere((key, _) => root.contains(key));
    _failed.removeWhere(root.contains);
    _validating.removeWhere(root.contains);
    _mergeErrorSources();
  }

  /// Marks [key] touched and triggers validation when the configured mode
  /// schedules blur validation.
  void touch(FieldKey key) {
    _touched.add(key);
    if (_shouldValidateOnBlur(key) &&
        !(_submitting && _submissionRevision == _revision)) {
      _automaticValidation(key);
    }
    notifyListeners();
  }

  /// Validates the whole draft and its configured asynchronous rules.
  Future<KeyedFormValidationResult> validate() =>
      _runValidation(const [], revealAll: true);

  /// Validates the requested subtrees. An empty iterable performs no work.
  Future<KeyedFormValidationResult> validateScopes(Iterable<FieldKey> scopes) {
    final normalized = _normalizeScopes(scopes);
    if (normalized.isEmpty) {
      return Future.value(_result(KeyedFormValidationStatus.valid, const {}));
    }
    return _runValidation(normalized, revealAll: false);
  }

  /// Force every error under each of [scopes] visible, without re-validating.
  void reveal(Iterable<FieldKey> scopes) {
    _revealed.addAll(scopes);
    notifyListeners();
  }

  /// Validates a fresh snapshot before invoking exactly one matching callback.
  Future<bool> submit(
    FutureOr<void> Function(Root value) onValid, {
    FutureOr<void> Function(Iterable<FieldKey> errorKeys)? onInvalid,
    FutureOr<void> Function(KeyedFormValidationResult result)?
    onValidationUnavailable,
  }) async {
    if (_submitting) return false;
    _submitting = true;
    final token = _epoch;
    final revision = _revision;
    _submissionRevision = revision;
    final draft = _value;
    _revealed.add(FieldKey.root);
    notifyListeners();
    try {
      final result = await _runValidation(const [], revealAll: true);
      if (_disposed ||
          token != _epoch ||
          revision != _revision ||
          result.status == KeyedFormValidationStatus.superseded) {
        return false;
      }
      if (result.errors.isNotEmpty) {
        if (onInvalid != null) await onInvalid(result.errors.keys);
        return false;
      }
      if (result.failures.values.any(
        (failure) =>
            failure.failureMode == KeyedFormAsyncFailureMode.blockSubmit,
      )) {
        if (onValidationUnavailable != null) {
          await onValidationUnavailable(result);
        }
        return false;
      }
      await onValid(draft);
      return true;
    } finally {
      if (!_disposed && token == _epoch) {
        _submitting = false;
        _submitted = true;
        _submissionRevision = null;
        notifyListeners();
      }
    }
  }

  Future<KeyedFormValidationResult> _runValidation(
    List<FieldKey> scopes, {
    required bool revealAll,
  }) async {
    final root = _value;
    final runEpoch = _epoch;
    if (scopes.isEmpty) {
      _syncErrors = resolver(root, null);
      _serverErrors = const FieldErrors.empty();
    } else {
      for (final scope in scopes) {
        _syncErrors = _spliceInto(_syncErrors, scope, resolver(root, scope));
        _serverErrors = _serverErrors.removeSubtree(scope);
      }
    }
    _clearSyncBlockedBindings();
    _mergeErrorSources();
    if (revealAll) {
      _revealed.add(FieldKey.root);
    } else {
      _revealed.addAll(scopes);
    }
    final targets = _resolveRules(root)
        .where(
          (target) =>
              scopes.isEmpty ||
              scopes.any(
                (scope) =>
                    scope.contains(target.key) || target.key.contains(scope),
              ),
        )
        .toList(growable: false);
    final seen = <FieldKey>{};
    for (final target in targets) {
      if (!seen.add(target.key)) {
        throw ArgumentError(
          'Multiple async validators resolve to ${target.key}',
        );
      }
    }
    final eligible = <_ResolvedRule>[];
    for (final target in targets) {
      _ruleSnapshots[target.key] = target.draft;
      _asyncErrors = _replaceKey(_asyncErrors, target.key, null);
      _failures.remove(target.key);
      _failed.remove(target.key);
      if (_isSyncBlocked(target.key)) {
        _cancelRunsForKey(target.key);
        continue;
      }
      eligible.add(target);
    }
    _mergeErrorSources();
    final generations = <FieldKey, int>{};
    final cancellation = Completer<void>();
    for (final target in eligible) {
      _cancelRunsForKey(target.key);
      final generation = (_validationGeneration[target.key] ?? 0) + 1;
      _validationGeneration[target.key] = generation;
      generations[target.key] = generation;
      (_activeRunsByKey[target.key] ??= {}).add(cancellation);
      _validating.add(target.key);
    }
    notifyListeners();
    final outcomesFuture = Future.wait(
      eligible.map((target) => _executeRule(target)),
    );
    final cancelled = await Future.any([
      outcomesFuture.then((_) => false),
      cancellation.future.then((_) => true),
    ]);
    if (cancelled || _disposed || runEpoch != _epoch) {
      _unlinkRun(eligible, cancellation);
      if (!_disposed && runEpoch == _epoch) {
        unawaited(
          outcomesFuture.then(
            (lateOutcomes) =>
                _settleCurrentOutcomes(eligible, generations, lateOutcomes),
          ),
        );
      }
      return _result(KeyedFormValidationStatus.superseded, const {});
    }
    final outcomes = await outcomesFuture;
    _unlinkRun(eligible, cancellation);
    var superseded = false;
    final resultFailures = <FieldKey, KeyedFormValidationFailure>{};
    final failureObservers = <_FailureObserver>[];
    for (var i = 0; i < eligible.length; i++) {
      final target = eligible[i];
      if (_validationGeneration[target.key] != generations[target.key]) {
        superseded = true;
        continue;
      }
      _validating.remove(target.key);
      final outcome = outcomes[i];
      if (outcome.failure != null) {
        _failures[target.key] = outcome.failure!;
        _failed.add(target.key);
        resultFailures[target.key] = outcome.failure!;
        failureObservers.add((
          callback: target.onFailure,
          failure: outcome.failure!,
        ));
      } else {
        _asyncErrors = _replaceKey(_asyncErrors, target.key, outcome.error);
      }
    }
    _mergeErrorSources();
    notifyListeners();
    _notifyFailureObservers(failureObservers);
    final merged = <FieldKey, String>{
      for (final key in _errors.keys)
        if (scopes.isEmpty ||
            scopes.any((scope) => scope.contains(key) || key.contains(scope)))
          key: _errors.byKey(key)!,
    };
    final status = superseded
        ? KeyedFormValidationStatus.superseded
        : merged.isNotEmpty
        ? KeyedFormValidationStatus.invalid
        : resultFailures.isNotEmpty
        ? KeyedFormValidationStatus.unavailable
        : KeyedFormValidationStatus.valid;
    return _result(status, merged, failures: resultFailures);
  }

  Future<({String? error, KeyedFormValidationFailure? failure})> _executeRule(
    _ResolvedRule target,
  ) async {
    try {
      final value = Future<String?>.sync(target.validate);
      final message = target.timeout == null
          ? await value
          : await value.timeout(target.timeout!);
      return (error: message, failure: null);
    } catch (error, stackTrace) {
      return (
        error: null,
        failure: KeyedFormValidationFailure(
          error: error,
          stackTrace: stackTrace,
          failureMode: target.failureMode ?? asyncValidationFailureMode,
        ),
      );
    }
  }

  void _settleCurrentOutcomes(
    List<_ResolvedRule> targets,
    Map<FieldKey, int> generations,
    List<({String? error, KeyedFormValidationFailure? failure})> outcomes,
  ) {
    if (_disposed) return;
    final failureObservers = <_FailureObserver>[];
    for (var i = 0; i < targets.length; i++) {
      final target = targets[i];
      if (_validationGeneration[target.key] != generations[target.key]) {
        continue;
      }
      _validating.remove(target.key);
      final outcome = outcomes[i];
      if (outcome.failure case final failure?) {
        _failures[target.key] = failure;
        _failed.add(target.key);
        failureObservers.add((callback: target.onFailure, failure: failure));
      } else {
        _asyncErrors = _replaceKey(_asyncErrors, target.key, outcome.error);
      }
    }
    _mergeErrorSources();
    notifyListeners();
    _notifyFailureObservers(failureObservers);
  }

  List<_ResolvedRule> _resolveRules(Root root) {
    final visitor = _RuleCollector();
    for (final rule in asyncValidators) {
      rule.resolve(root, FieldKey.root, visitor);
    }
    return visitor.rules;
  }

  bool _isSyncBlocked(FieldKey key) => _syncErrors.keys.any(
    (error) => error.contains(key) || key.contains(error),
  );

  KeyedFormValidationResult _result(
    KeyedFormValidationStatus status,
    Map<FieldKey, String> errors, {
    Map<FieldKey, KeyedFormValidationFailure> failures = const {},
  }) => KeyedFormValidationResult(
    status: status,
    errors: FieldErrors(Map.unmodifiable(errors)),
    failures: Map.unmodifiable(failures),
  );

  List<FieldKey> _normalizeScopes(Iterable<FieldKey> scopes) {
    final result = <FieldKey>[];
    for (final scope in scopes) {
      if (result.any((existing) => existing.contains(scope))) continue;
      result.removeWhere(scope.contains);
      result.add(scope);
    }
    return result;
  }

  bool _shouldValidateOnBlur(FieldKey key) {
    if (mode == KeyedFormMode.all) return true;
    if (_submitted) return reValidateMode == KeyedFormReValidateMode.onBlur;
    return mode == KeyedFormMode.onBlur || mode == KeyedFormMode.onTouched;
  }

  void _automaticValidation(FieldKey key) {
    final scope = scopeOf?.call(key);
    if (scopeOf != null && scope == null) return;
    final errors = resolver(_value, scope);
    if (scope == null) {
      _syncErrors = errors;
    } else {
      _syncErrors = _spliceInto(_syncErrors, scope, errors);
    }
    _serverErrors = scope == null
        ? const FieldErrors.empty()
        : _serverErrors.removeSubtree(scope);
    _clearSyncBlockedBindings();
    _revealed.add(key);

    _mergeErrorSources();
    final targets = _resolveRules(
      _value,
    ).where((rule) => key.contains(rule.key));
    for (final target in targets) {
      unawaited(_runSingleTarget(target));
    }
  }

  void _clearSyncBlockedBindings() {
    for (final key in _ruleSnapshots.keys.toList()) {
      if (!_isSyncBlocked(key)) continue;
      _cancelRunsForKey(key);
      _asyncErrors = _replaceKey(_asyncErrors, key, null);
      _failures.remove(key);
      _failed.remove(key);
    }
    _mergeErrorSources();
  }

  Future<void> _runSingleTarget(_ResolvedRule target) async {
    if (_isSyncBlocked(target.key)) {
      _asyncErrors = _replaceKey(_asyncErrors, target.key, null);
      _failures.remove(target.key);
      _failed.remove(target.key);
      _mergeErrorSources();
      notifyListeners();
      return;
    }
    await validateScopes([target.key]);
  }

  FieldErrors<String> _spliceInto(
    FieldErrors<String> source,
    FieldKey scope,
    FieldErrors<String> replacement,
  ) {
    final values = <FieldKey, String>{
      for (final key in source.keys)
        if (!scope.contains(key)) key: source.byKey(key)!,
    };
    for (final key in replacement.keys) {
      assert(scope.contains(key));
      values[key] = replacement.byKey(key)!;
    }
    return FieldErrors(values);
  }

  FieldErrors<String> _replaceKey(
    FieldErrors<String> source,
    FieldKey key,
    String? value,
  ) {
    final values = <FieldKey, String>{
      for (final existing in source.keys)
        if (existing != key) existing: source.byKey(existing)!,
    };
    if (value != null) values[key] = value;
    return FieldErrors(values);
  }

  void _mergeErrorSources() {
    final values = <FieldKey, String>{};
    for (final source in [_syncErrors, _serverErrors, _asyncErrors]) {
      for (final key in source.keys) {
        values.putIfAbsent(key, () => source.byKey(key)!);
      }
    }
    _errors = FieldErrors(values);
  }

  // --- seed / reset / server errors ------------------------------------

  /// Re-baselines the form to [value] (both draft and [original]) and clears
  /// all bookkeeping — unless the draft is dirty and [force] is false, so a
  /// background refresh cannot clobber in-progress edits.
  void seed(Root value, {bool force = false}) {
    if (isDirty && !force) return;
    _value = value;
    _original = value;
    _revision++;
    _resetBookkeeping();
    notifyListeners();
  }

  /// Discards edits back to [original] and clears all bookkeeping.
  void reset() {
    _value = _original;
    _revision++;
    _resetBookkeeping();
    notifyListeners();
  }

  void _resetBookkeeping() {
    _invalidateRuns();
    _syncErrors = const FieldErrors.empty();
    _serverErrors = const FieldErrors.empty();
    _asyncErrors = const FieldErrors.empty();
    _errors = const FieldErrors.empty();
    _failures.clear();
    _ruleSnapshots.clear();
    _touched.clear();
    _revealed.clear();
    _validating.clear();
    _failed.clear();
    _submitted = false;
    _submitting = false;
    _submissionRevision = null;
    // Read-only configuration survives seed/reset.
  }

  /// Merges server-reported errors into the map and force-reveals them (they
  /// come back from a submit, so the user must see them regardless of touched
  /// state). Also sets [submitted].
  void setServerErrors(Map<FieldKey, String> errors) {
    if (errors.isEmpty) return;
    final values = <FieldKey, String>{
      for (final key in _serverErrors.keys) key: _serverErrors.byKey(key)!,
      ...errors,
    };
    _serverErrors = FieldErrors(values);
    _revealed.addAll(errors.keys);
    _submitted = true;
    _mergeErrorSources();
    notifyListeners();
  }

  /// [setServerErrors] keyed by the [FieldKey.toPath] wire format — the shape
  /// a JSON error body usually arrives in. Throws [FormatException] on a path
  /// that is not valid wire format.
  void setServerErrorPaths(Map<String, String> pathErrors) => setServerErrors({
    for (final entry in pathErrors.entries)
      FieldKey.parse(entry.key): entry.value,
  });

  /// Toggles the [submitting] flag (drives a disabled Save button / spinner).
  void setSubmitting(bool value) {
    if (_submitting == value) return;
    _submitting = value;
    notifyListeners();
  }

  // --- read-only -----------------------------------------------------------

  /// Freezes [key] — and, by [FieldKey] ancestor coverage, everything nested
  /// under it — against [setField] / [updateField] / list mutation, without
  /// affecting validation: a read-only field still validates normally.
  ///
  /// Configuration, not draft state: unlike [touched] / [revealed] /
  /// [isValidating] / [isFailedValidation], it survives [seed] and [reset].
  /// Pass `force: true` to [setField] / [updateField] to write through the
  /// freeze anyway.
  void markReadOnly(FieldKey key) {
    if (!_readOnly.add(key)) return;
    notifyListeners();
  }

  /// Unfreezes [key]. A no-op if it (or an ancestor scope) was not frozen —
  /// note that unmarking a leaf does not unmark an ancestor scope that covers
  /// it; unmark that scope's own key instead.
  void unmarkReadOnly(FieldKey key) {
    if (!_readOnly.remove(key)) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _invalidateRuns();
    _validating.clear();
    super.dispose();
  }
}
