import 'package:keyed_form/keyed_form.dart';

import 'scenario.dart';

/// The `keyed_form` draft used by both the model and widget harnesses: a map
/// of flat fields plus a list of rows. A generated `keyed_form` model is a
/// class with N typed fields whose `copyWith` also rebuilds the whole object,
/// so the map copy here is representative of the per-write allocation.
class KfDraft {
  const KfDraft(this.fields, this.rows);
  final Map<String, String> fields;
  final List<KfRow> rows;

  KfDraft withField(String k, String v) => KfDraft({...fields, k: v}, rows);
  KfDraft withRows(List<KfRow> r) => KfDraft(fields, r);

  @override
  bool operator ==(Object other) =>
      other is KfDraft &&
      _mapEq(other.fields, fields) &&
      _listEq(other.rows, rows);

  @override
  int get hashCode => Object.hash(
        Object.hashAllUnordered(
          [for (final e in fields.entries) Object.hash(e.key, e.value)],
        ),
        Object.hashAll(rows),
      );
}

class KfRow implements KeyedRow {
  const KfRow({required this.clientId, required this.city, required this.nights});
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

bool _mapEq(Map<String, String> a, Map<String, String> b) {
  if (a.length != b.length) return false;
  for (final e in a.entries) {
    if (b[e.key] != e.value) return false;
  }
  return true;
}

bool _listEq(List<KfRow> a, List<KfRow> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

StrictFieldRef<KfDraft, String> kfFieldRef(String name) =>
    StrictFieldRef<KfDraft, String>.of(
      key: FieldKey.name(name),
      get: (d) => d.fields[name] ?? '',
      set: (d, v) => d.withField(name, v),
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
    {for (var i = 0; i < scenario.fieldCount; i++) Scenario.fieldName(i): 'val'},
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
  d.fields.forEach((name, value) {
    final key = FieldKey.name(name);
    if (scope != null && !scope.contains(key)) return;
    if (value.trim().length < 3) errors[key] = 'min3';
  });
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
}) =>
    KeyedFormController<KfDraft>(
      initialValue: kfSeed(scenario),
      mode: KeyedFormMode.onChange,
      resolver: (d, scope) => kfResolve(d, scope, scenario.maxNights),
      scopeOf: scoped ? (key) => key.prefix(1) : null,
    );
