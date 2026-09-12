/// The one form shape every harness builds, parameterised by size.
///
/// * [fieldCount] flat text fields, named `field0 … field{n-1}`, each
///   **required** and **min length 3**.
/// * [rowCount] rows in one dynamic list, each row a `{ city (required),
///   nights (int >= 1) }`.
/// * one cross-field rule: the sum of `nights` across all rows must be
///   `<= `[maxNights].
///
/// Keeping the rules trivial keeps the benchmark about the *library's*
/// bookkeeping (copy, diff, notify, rebuild), not about validator cost.
class Scenario {
  const Scenario({
    required this.fieldCount,
    this.rowCount = 0,
    this.maxNights = 1 << 30,
  });

  final int fieldCount;
  final int rowCount;
  final int maxNights;

  static String fieldName(int i) => 'field$i';

  /// The sizes swept by the default runs.
  static const List<Scenario> sweep = [
    Scenario(fieldCount: 10),
    Scenario(fieldCount: 50),
    Scenario(fieldCount: 100),
    Scenario(fieldCount: 250),
    Scenario(fieldCount: 20, rowCount: 20, maxNights: 30),
    Scenario(fieldCount: 20, rowCount: 100, maxNights: 150),
  ];

  String get label =>
      rowCount == 0 ? '${fieldCount}f' : '${fieldCount}f+${rowCount}r';

  @override
  String toString() => 'Scenario($label, maxNights=$maxNights)';
}

/// A row of the dynamic list, shared by the harnesses that model rows as data.
class RowData {
  const RowData({required this.city, required this.nights});
  final String city;
  final int nights;

  RowData copyWith({String? city, int? nights}) =>
      RowData(city: city ?? this.city, nights: nights ?? this.nights);

  @override
  bool operator ==(Object other) =>
      other is RowData && other.city == city && other.nights == nights;

  @override
  int get hashCode => Object.hash(city, nights);
}

/// The initial rows for a scenario: `City0…`, 1 night each.
List<RowData> seedRows(int rowCount) => [
  for (var i = 0; i < rowCount; i++) RowData(city: 'City$i', nights: 1),
];
