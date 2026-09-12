import 'package:keyed_form/keyed_form.dart';

import 'scenario.dart';

/// The `keyed_form` draft used by the parameterised (any-N) harnesses: a
/// fixed-length `List<String>` of flat fields plus a list of rows.
///
/// A `keyed_form_gen` model is a class with N named fields; its `copyWith`
/// reads N fields and allocates one object. Backing the flat fields with an
/// indexed `List<String>` here (read = O(1) no hash, write = one list copy)
/// is the closest parameterisable analog — see
/// `codegen_calibration_test.dart` for the measured gap to a real generated
/// model.
class KfDraft {
  const KfDraft(this.values, this.rows);
  final List<String> values;
  final List<KfRow> rows;

  KfDraft withFieldAt(int i, String v) => KfDraft([...values]..[i] = v, rows);
  KfDraft withRows(List<KfRow> r) => KfDraft(values, r);

  @override
  bool operator ==(Object other) =>
      other is KfDraft &&
      _seqEq(other.values, values) &&
      _seqEq(other.rows, rows);

  @override
  int get hashCode => Object.hash(Object.hashAll(values), Object.hashAll(rows));
}

class KfRow implements KeyedRow {
  const KfRow({
    required this.clientId,
    required this.city,
    required this.nights,
  });
  @override
  final String clientId;
  final String city;
  final int nights;

  KfRow copyWith({String? city, int? nights}) => KfRow(
    clientId: clientId,
    city: city ?? this.city,
    nights: nights ?? this.nights,
  );

  @override
  bool operator ==(Object other) =>
      other is KfRow &&
      other.clientId == clientId &&
      other.city == city &&
      other.nights == nights;

  @override
  int get hashCode => Object.hash(clientId, city, nights);
}

bool _seqEq<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// A `FieldRef` to flat field [index]. Like a generated `Fields.fieldN`
/// getter, this allocates a fresh `StrictFieldRef` per call.
StrictFieldRef<KfDraft, String> kfFieldRef(int index) =>
    StrictFieldRef<KfDraft, String>.of(
      key: FieldKey.name(Scenario.fieldName(index)),
      get: (d) => d.values[index],
      set: (d, v) => d.withFieldAt(index, v),
    );

final StrictFieldRef<KfDraft, List<KfRow>> kfRowsRef =
    StrictFieldRef<KfDraft, List<KfRow>>.of(
      key: FieldKey.name('rows'),
      get: (d) => d.rows,
      set: (d, r) => d.withRows(r),
    );

KfDraft kfSeed(Scenario scenario) {
  final seeded = seedRows(scenario.rowCount);
  return KfDraft(
    [for (var i = 0; i < scenario.fieldCount; i++) 'val'],
    [
      for (var i = 0; i < seeded.length; i++)
        KfRow(clientId: 'r$i', city: seeded[i].city, nights: seeded[i].nights),
    ],
  );
}

/// The resolver: required + minLength(3) per flat field, city-required and
/// total-nights per row set. Honors [scope] so a scoped controller only
/// re-checks the written subtree.
FieldErrors<String> kfResolve(KfDraft d, FieldKey? scope, int maxNights) {
  final errors = <FieldKey, String>{};
  for (var i = 0; i < d.values.length; i++) {
    final key = FieldKey.name(Scenario.fieldName(i));
    if (scope != null && !scope.contains(key)) continue;
    if (d.values[i].trim().length < 3) errors[key] = 'min3';
  }
  final rowsKey = kfRowsRef.key;
  if (scope == null || scope.contains(rowsKey)) {
    var total = 0;
    for (final row in d.rows) {
      total += row.nights;
      if (row.city.trim().isEmpty) {
        errors[rowsKey + FieldKey.id(row.clientId) + FieldKey.name('city')] =
            'required';
      }
    }
    if (total > maxNights) errors[rowsKey] = 'tooLong';
  }
  return FieldErrors(errors);
}

KeyedFormController<KfDraft> buildKfController(
  Scenario scenario, {
  required bool scoped,
}) => KeyedFormController<KfDraft>(
  initialValue: kfSeed(scenario),
  mode: KeyedFormMode.onChange,
  resolver: (d, scope) => kfResolve(d, scope, scenario.maxNights),
  scopeOf: scoped ? (key) => key.prefix(1) : null,
);
