import 'dart:async';

import 'package:keyed_form_core/keyed_form_core.dart';
import 'package:listen/listen.dart';
import 'package:meta/meta.dart';

import 'keyed_form_list.dart';
import 'keyed_form_mode.dart';
import 'keyed_form_resolver.dart';
import 'keyed_form_snapshot.dart';

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
    this.mode = .onTouched,
    this.scopeOf,
  }) : _value = initialValue,
       _original = initialValue;

  /// Validates a draft (or one subtree of it) — see [KeyedFormResolver].
  final KeyedFormResolver<Root> resolver;

  /// When a field's error becomes visible — see [KeyedFormMode].
  final KeyedFormMode mode;

  /// Maps a written field to the subtree to re-validate; `null` for
  /// whole-draft validation on every write.
  final KeyedFormScopeOf? scopeOf;

  Root _value;
  Root _original;
  FieldErrors<String> _errors = const FieldErrors.empty();
  final Set<FieldKey> _touched = {};
  final Set<FieldKey> _revealed = {};
  final Set<FieldKey> _validating = {};
  final Set<FieldKey> _failed = {};
  final Set<FieldKey> _readOnly = {};
  final Map<FieldKey, int> _validationGeneration = {};
  bool _submitted = false;
  bool _submitting = false;

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

  /// Whether [key] is currently mid-async-validation — see
  /// [setFieldValidating] / [validateFieldAsync].
  bool isValidating(FieldKey key) => _validating.contains(key);

  /// Whether [key]'s async validation last ended in a technical failure (the
  /// check threw, or exceeded its timeout) rather than a verdict about the
  /// value — see [validateFieldAsync]. Orthogonal to [errors]: this reports
  /// "the check couldn't run", not "the value is invalid". Not sticky — the
  /// next [validateFieldAsync] call on the same key clears it, win or lose.
  bool isFailedValidation(FieldKey key) => _failed.contains(key);

  /// Whether [key] is frozen against [setField] / [updateField] / list
  /// mutation — see [markReadOnly]. Covers a key nested under a read-only
  /// scope the same way [_revealedCovers] covers a nested error.
  bool isReadOnly(FieldKey key) => _readOnly.any((scope) => scope.contains(key));

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
    .onSubmit => _submitted || _revealedCovers(key),
    .onChange ||
    .onBlur ||
    .onTouched => _touched.contains(key) || _submitted || _revealedCovers(key),
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
    if (mode == .onChange) _touched.add(writtenKey);
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

    final survivingIds = {for (final row in after) row.clientId};
    for (final row in before) {
      if (!survivingIds.contains(row.clientId)) {
        final rowKey = field.key + FieldKey.id(row.clientId);
        _errors = _errors.removeSubtree(rowKey);
        _revealed.removeWhere(rowKey.contains);
      }
    }

    if (mode == .onChange) _touched.add(field.key);
    _revalidateForWrite(field.key);
    notifyListeners();
  }

  // --- validation / touch / reveal --------------------------------------

  /// Marks [key] touched and re-validates the subtree it belongs to (the whole
  /// draft for an unscoped controller).
  void touch(FieldKey key) {
    _touched.add(key);
    _revalidateScopeOf(key);
    notifyListeners();
  }

  /// Whole-draft validation. Sets [submitted] so every error becomes visible.
  /// Returns whether the draft is valid.
  bool validate() {
    _errors = resolver(_value, null);
    _submitted = true;
    notifyListeners();
    return _errors.isEmpty;
  }

  /// Re-validates each subtree in [scopes], force-reveals all of them, and
  /// returns the ones that still carry an error — the "validate my dirty days
  /// before saving" operation. Only meaningful on a scoped controller.
  List<FieldKey> validateScopes(Iterable<FieldKey> scopes) {
    final failing = <FieldKey>[];
    for (final scope in scopes) {
      _errors = _spliceScope(scope, resolver(_value, scope));
      _revealed.add(scope);
      if (_errors.keys.any(scope.contains)) failing.add(scope);
    }
    notifyListeners();
    return failing;
  }

  /// Force every error under each of [scopes] visible, without re-validating.
  void reveal(Iterable<FieldKey> scopes) {
    _revealed.addAll(scopes);
    notifyListeners();
  }

  /// Validates the draft. If valid, runs [onValid] with the current [value],
  /// toggling [submitting] around it. If invalid, runs [onInvalid] (if given)
  /// with [visibleErrorKeys] — [validate] has already made every error
  /// visible. Returns whether [onValid] ran.
  ///
  /// In `keyed_form_flutter`, `form.handleSubmit(context, onValid)` is the
  /// Flutter-aware wrapper: same shape, but its default [onInvalid] scrolls
  /// to the first error via the ambient `KeyedFieldRegistry`.
  Future<bool> submit(
    FutureOr<void> Function(Root value) onValid, {
    FutureOr<void> Function(Iterable<FieldKey> errorKeys)? onInvalid,
  }) async {
    if (!validate()) {
      if (onInvalid != null) await onInvalid(visibleErrorKeys);
      return false;
    }
    setSubmitting(true);
    try {
      await onValid(value);
      return true;
    } finally {
      setSubmitting(false);
    }
  }

  void _revalidateForWrite(FieldKey writtenKey) =>
      _revalidateScopeOf(writtenKey);

  void _revalidateScopeOf(FieldKey key) {
    final scopeOf = this.scopeOf;
    if (scopeOf == null) {
      _errors = resolver(_value, null);
      return;
    }
    final scope = scopeOf(key);
    if (scope == null) return; // scoped controller, key outside any subtree
    _errors = _spliceScope(scope, resolver(_value, scope));
  }

  /// Drops the existing errors under [scope] and appends [replacement],
  /// keeping the surviving entries in their original order. Mirrors the
  /// hand-rolled `replace<X>DayErrors` the app editors used to carry.
  FieldErrors<String> _spliceScope(
    FieldKey scope,
    FieldErrors<String> replacement,
  ) {
    final kept = _errors.removeSubtree(scope);
    final merged = <FieldKey, String>{
      for (final key in kept.keys) key: kept.byKey(key)!,
    };
    for (final key in replacement.keys) {
      assert(
        scope.contains(key),
        'resolver returned $key outside its scope $scope',
      );
      merged[key] = replacement.byKey(key)!;
    }
    return FieldErrors(merged);
  }

  // --- seed / reset / server errors ------------------------------------

  /// Re-baselines the form to [value] (both draft and [original]) and clears
  /// all bookkeeping — unless the draft is dirty and [force] is false, so a
  /// background refresh cannot clobber in-progress edits.
  void seed(Root value, {bool force = false}) {
    if (isDirty && !force) return;
    _value = value;
    _original = value;
    _resetBookkeeping();
    notifyListeners();
  }

  /// Discards edits back to [original] and clears all bookkeeping.
  void reset() {
    _value = _original;
    _resetBookkeeping();
    notifyListeners();
  }

  void _resetBookkeeping() {
    _errors = const FieldErrors.empty();
    _touched.clear();
    _revealed.clear();
    _validating.clear();
    _failed.clear();
    _validationGeneration.clear();
    _submitted = false;
    _submitting = false;
    // _readOnly is deliberately left alone: it is configuration (like a
    // field's frozen state), not draft bookkeeping, so seed()/reset() must
    // not clear it.
  }

  /// Merges server-reported errors into the map and force-reveals them (they
  /// come back from a submit, so the user must see them regardless of touched
  /// state). Also sets [submitted].
  void setServerErrors(Map<FieldKey, String> errors) {
    if (errors.isEmpty) return;
    final merged = <FieldKey, String>{
      for (final key in _errors.keys) key: _errors.byKey(key)!,
    };
    errors.forEach((key, message) {
      merged[key] = message;
      _revealed.add(key);
    });
    _errors = FieldErrors(merged);
    _submitted = true;
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

  /// Toggles whether [key] is mid-async-validation (drives a per-field
  /// spinner via [FieldHandle.isValidating] / `KeyedFieldState.isValidating`).
  /// The resolver itself stays synchronous — call this around your own async
  /// check (a server round-trip); [validateFieldAsync] does it for you.
  void setFieldValidating(FieldKey key, bool value) {
    final changed = value ? _validating.add(key) : _validating.remove(key);
    if (!changed) return;
    notifyListeners();
  }

  /// Runs [check] as [key]'s async validation, toggling [isValidating] around
  /// it. A non-null result is merged in as a server error on [key] (see
  /// [setServerErrors]) — `null` leaves existing errors on [key] alone, since
  /// the sync [resolver] stays authoritative for the field's own format/
  /// required checks.
  ///
  /// A thrown error, or a run that exceeds [timeout], is a technical failure,
  /// not a verdict about the value: [key] lands on [isFailedValidation]
  /// instead of [errors], [onFailure] (if given) is called with the error and
  /// stack trace, and the call still completes normally rather than
  /// propagating. Not sticky — a later call on the same [key] clears it,
  /// whether that call succeeds or fails in turn.
  ///
  /// Safe against overlapping calls on the same [key]: if a newer call starts
  /// before an older one resolves, the older one's result — success or
  /// failure — is discarded; only the latest call can settle it.
  Future<void> validateFieldAsync(
    FieldKey key,
    FutureOr<String?> Function() check, {
    Duration? timeout,
    void Function(Object error, StackTrace stackTrace)? onFailure,
  }) async {
    final generation = (_validationGeneration[key] ?? 0) + 1;
    _validationGeneration[key] = generation;
    final hadFailure = _failed.remove(key);
    final startedValidating = _validating.add(key);
    if (hadFailure || startedValidating) notifyListeners();
    try {
      final result = timeout == null
          ? await check()
          : await Future<String?>.sync(check).timeout(timeout);
      if (_validationGeneration[key] != generation) return; // superseded
      if (result != null) setServerErrors({key: result});
    } catch (error, stackTrace) {
      if (_validationGeneration[key] != generation) return; // superseded
      _failed.add(key);
      onFailure?.call(error, stackTrace);
      notifyListeners();
    } finally {
      if (_validationGeneration[key] == generation) {
        setFieldValidating(key, false);
      }
    }
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
}
