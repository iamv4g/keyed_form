// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_schema.dart';

// ignore_for_file: type=lint, unused_element, sort_constructors_first, avoid_equals_and_hash_code_on_mutable_classes, specify_nonobvious_property_types

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}

int _mapHash(Map<Object?, Object?>? map) {
  if (map == null) return 0;
  var hash = 0;
  for (final entry in map.entries) {
    hash ^= Object.hash(entry.key, entry.value);
  }
  return hash;
}

const _unset = Object();

abstract interface class InvoiceSchemaCopyWith<T> {
  T call({List<LineItemSchema>? lineItems, int? total});
}

class _InvoiceSchemaCopyWithImpl
    implements InvoiceSchemaCopyWith<InvoiceSchema> {
  const _InvoiceSchemaCopyWithImpl(this._value);
  final InvoiceSchema _value;

  @override
  InvoiceSchema call({List<LineItemSchema>? lineItems, int? total}) =>
      InvoiceSchema(
        lineItems: lineItems ?? _value.lineItems,
        total: total ?? _value.total,
      );
}

class InvoiceSchema {
  const InvoiceSchema({this.lineItems = const [], this.total = 0});

  final List<LineItemSchema> lineItems;
  final int total;

  /// Creates a new [InvoiceSchema] instance with auto-generated UUID if needed.
  factory InvoiceSchema.create({List<LineItemSchema>? lineItems, int? total}) {
    return InvoiceSchema(lineItems: lineItems ?? const [], total: total ?? 0);
  }

  InvoiceSchemaCopyWith<InvoiceSchema> get copyWith =>
      _InvoiceSchemaCopyWithImpl(this);

  /// Converts this [InvoiceSchema] to a Map representation.
  Map<String, Object?> toMap() => {
    'lineItems': lineItems.map((e) => e.toMap()).toList(),
    'total': total,
  };

  List<Object?> get _validationValues => [
    lineItems.map((e) => e.toMap()).toList(),
    total,
  ];

  /// Validates this [InvoiceSchema] against its schema. Pass [scope] (a `FieldKey`)
  /// to re-check only that subtree — see `KeyedFormController.scopeOf`.
  FieldErrors<String> validate([FieldKey? scope]) =>
      _invoiceSchema.validateValues(_validationValues, scope: scope);

  /// Asynchronously validates this [InvoiceSchema] against its schema.
  Future<FieldErrors<String>> validateAsync([FieldKey? scope]) =>
      _invoiceSchema.validateValuesAsync(_validationValues, scope: scope);

  /// Static validator — assignable straight to `KeyedFormController.resolver`.
  static FieldErrors<String> validateData(
    InvoiceSchema schema, [
    FieldKey? scope,
  ]) => schema.validate(scope);

  /// Static async validator for [InvoiceSchema].
  static Future<FieldErrors<String>> validateDataAsync(
    InvoiceSchema schema, [
    FieldKey? scope,
  ]) => schema.validateAsync(scope);

  /// The default `KeyedFormController.scopeOf` for [InvoiceSchema] — a write inside a
  /// list row re-validates just that row, otherwise its top-level field.
  static FieldKey? scopeOf(FieldKey writtenKey) => rowScopeOf(writtenKey);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvoiceSchema &&
        _listEquals(lineItems, other.lineItems) &&
        total == other.total;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(lineItems), total);
}

abstract final class InvoiceFields {
  static StrictFieldRef<InvoiceSchema, List<LineItemSchema>> get lineItems =>
      StrictFieldRef<InvoiceSchema, List<LineItemSchema>>.of(
        key: FieldKey.name('lineItems'),
        get: (x) => x.lineItems,
        set: (x, v) => x.copyWith(lineItems: v),
      );

  static StrictFieldRef<InvoiceSchema, int> get total =>
      StrictFieldRef<InvoiceSchema, int>.of(
        key: FieldKey.name('total'),
        get: (x) => x.total,
        set: (x, v) => x.copyWith(total: v),
      );

  /// Field references for the `lineItems` row identified by [at].
  /// Affine — reads null / writes are a no-op if that row no longer exists.
  static LineItemFieldRefs lineItem(LineItemRef at) => LineItemFieldRefs(
    lineItems.at(at.lineItem, (x) => x.clientId == at.lineItem),
  );
}

/// Identifies one `lineItems` row by its clientId path: `lineItem` = a `LineItemSchema.clientId`.
/// Build it from your row objects, e.g. `(lineItem: …)`.
typedef LineItemRef = ({String lineItem});

/// Field references for a [LineItemSchema] within [InvoiceSchema].
final class LineItemFieldRefs
    extends DelegatingFieldRef<InvoiceSchema, LineItemSchema> {
  LineItemFieldRefs(super.inner);

  /// `FieldRef` to `LineItemFields.description`.
  FieldRef<InvoiceSchema, String> get description =>
      inner.then(LineItemFields.description);

  /// `FieldRef` to `LineItemFields.quantity`.
  FieldRef<InvoiceSchema, int> get quantity =>
      inner.then(LineItemFields.quantity);

  /// `FieldRef` to `LineItemFields.unitPrice`.
  FieldRef<InvoiceSchema, int> get unitPrice =>
      inner.then(LineItemFields.unitPrice);
}

abstract interface class LineItemSchemaCopyWith<T> {
  T call({
    String? clientId,
    String? description,
    int? quantity,
    int? unitPrice,
  });
}

class _LineItemSchemaCopyWithImpl
    implements LineItemSchemaCopyWith<LineItemSchema> {
  const _LineItemSchemaCopyWithImpl(this._value);
  final LineItemSchema _value;

  @override
  LineItemSchema call({
    String? clientId,
    String? description,
    int? quantity,
    int? unitPrice,
  }) => LineItemSchema(
    clientId: clientId ?? _value.clientId,
    description: description ?? _value.description,
    quantity: quantity ?? _value.quantity,
    unitPrice: unitPrice ?? _value.unitPrice,
  );
}

class LineItemSchema implements KeyedRow {
  const LineItemSchema({
    required this.clientId,
    this.description = '',
    this.quantity = 1,
    this.unitPrice = 0,
  });

  final String clientId;
  final String description;
  final int quantity;
  final int unitPrice;

  /// Creates a new [LineItemSchema] instance with auto-generated UUID if needed.
  factory LineItemSchema.create({
    String? clientId,
    String? description,
    int? quantity,
    int? unitPrice,
  }) {
    return LineItemSchema(
      clientId: clientId ?? const Uuid().v4(),
      description: description ?? '',
      quantity: quantity ?? 1,
      unitPrice: unitPrice ?? 0,
    );
  }

  LineItemSchemaCopyWith<LineItemSchema> get copyWith =>
      _LineItemSchemaCopyWithImpl(this);

  /// Converts this [LineItemSchema] to a Map representation.
  Map<String, Object?> toMap() => {
    'clientId': clientId,
    'description': description,
    'quantity': quantity,
    'unitPrice': unitPrice,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LineItemSchema &&
        clientId == other.clientId &&
        description == other.description &&
        quantity == other.quantity &&
        unitPrice == other.unitPrice;
  }

  @override
  int get hashCode => Object.hash(clientId, description, quantity, unitPrice);
}

abstract final class LineItemFields {
  static StrictFieldRef<LineItemSchema, String> get description =>
      StrictFieldRef<LineItemSchema, String>.of(
        key: FieldKey.name('description'),
        get: (x) => x.description,
        set: (x, v) => x.copyWith(description: v),
      );

  static StrictFieldRef<LineItemSchema, int> get quantity =>
      StrictFieldRef<LineItemSchema, int>.of(
        key: FieldKey.name('quantity'),
        get: (x) => x.quantity,
        set: (x, v) => x.copyWith(quantity: v),
      );

  static StrictFieldRef<LineItemSchema, int> get unitPrice =>
      StrictFieldRef<LineItemSchema, int>.of(
        key: FieldKey.name('unitPrice'),
        get: (x) => x.unitPrice,
        set: (x, v) => x.copyWith(unitPrice: v),
      );
}
