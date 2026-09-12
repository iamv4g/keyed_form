// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bench_schema.dart';

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

abstract interface class Bench100SchemaCopyWith<T> {
  T call({
    String? field0,
    String? field1,
    String? field2,
    String? field3,
    String? field4,
    String? field5,
    String? field6,
    String? field7,
    String? field8,
    String? field9,
    String? field10,
    String? field11,
    String? field12,
    String? field13,
    String? field14,
    String? field15,
    String? field16,
    String? field17,
    String? field18,
    String? field19,
    String? field20,
    String? field21,
    String? field22,
    String? field23,
    String? field24,
    String? field25,
    String? field26,
    String? field27,
    String? field28,
    String? field29,
    String? field30,
    String? field31,
    String? field32,
    String? field33,
    String? field34,
    String? field35,
    String? field36,
    String? field37,
    String? field38,
    String? field39,
    String? field40,
    String? field41,
    String? field42,
    String? field43,
    String? field44,
    String? field45,
    String? field46,
    String? field47,
    String? field48,
    String? field49,
    String? field50,
    String? field51,
    String? field52,
    String? field53,
    String? field54,
    String? field55,
    String? field56,
    String? field57,
    String? field58,
    String? field59,
    String? field60,
    String? field61,
    String? field62,
    String? field63,
    String? field64,
    String? field65,
    String? field66,
    String? field67,
    String? field68,
    String? field69,
    String? field70,
    String? field71,
    String? field72,
    String? field73,
    String? field74,
    String? field75,
    String? field76,
    String? field77,
    String? field78,
    String? field79,
    String? field80,
    String? field81,
    String? field82,
    String? field83,
    String? field84,
    String? field85,
    String? field86,
    String? field87,
    String? field88,
    String? field89,
    String? field90,
    String? field91,
    String? field92,
    String? field93,
    String? field94,
    String? field95,
    String? field96,
    String? field97,
    String? field98,
    String? field99,
  });
}

class _Bench100SchemaCopyWithImpl
    implements Bench100SchemaCopyWith<Bench100Schema> {
  const _Bench100SchemaCopyWithImpl(this._value);
  final Bench100Schema _value;

  @override
  Bench100Schema call({
    String? field0,
    String? field1,
    String? field2,
    String? field3,
    String? field4,
    String? field5,
    String? field6,
    String? field7,
    String? field8,
    String? field9,
    String? field10,
    String? field11,
    String? field12,
    String? field13,
    String? field14,
    String? field15,
    String? field16,
    String? field17,
    String? field18,
    String? field19,
    String? field20,
    String? field21,
    String? field22,
    String? field23,
    String? field24,
    String? field25,
    String? field26,
    String? field27,
    String? field28,
    String? field29,
    String? field30,
    String? field31,
    String? field32,
    String? field33,
    String? field34,
    String? field35,
    String? field36,
    String? field37,
    String? field38,
    String? field39,
    String? field40,
    String? field41,
    String? field42,
    String? field43,
    String? field44,
    String? field45,
    String? field46,
    String? field47,
    String? field48,
    String? field49,
    String? field50,
    String? field51,
    String? field52,
    String? field53,
    String? field54,
    String? field55,
    String? field56,
    String? field57,
    String? field58,
    String? field59,
    String? field60,
    String? field61,
    String? field62,
    String? field63,
    String? field64,
    String? field65,
    String? field66,
    String? field67,
    String? field68,
    String? field69,
    String? field70,
    String? field71,
    String? field72,
    String? field73,
    String? field74,
    String? field75,
    String? field76,
    String? field77,
    String? field78,
    String? field79,
    String? field80,
    String? field81,
    String? field82,
    String? field83,
    String? field84,
    String? field85,
    String? field86,
    String? field87,
    String? field88,
    String? field89,
    String? field90,
    String? field91,
    String? field92,
    String? field93,
    String? field94,
    String? field95,
    String? field96,
    String? field97,
    String? field98,
    String? field99,
  }) => Bench100Schema(
    field0: field0 ?? _value.field0,
    field1: field1 ?? _value.field1,
    field2: field2 ?? _value.field2,
    field3: field3 ?? _value.field3,
    field4: field4 ?? _value.field4,
    field5: field5 ?? _value.field5,
    field6: field6 ?? _value.field6,
    field7: field7 ?? _value.field7,
    field8: field8 ?? _value.field8,
    field9: field9 ?? _value.field9,
    field10: field10 ?? _value.field10,
    field11: field11 ?? _value.field11,
    field12: field12 ?? _value.field12,
    field13: field13 ?? _value.field13,
    field14: field14 ?? _value.field14,
    field15: field15 ?? _value.field15,
    field16: field16 ?? _value.field16,
    field17: field17 ?? _value.field17,
    field18: field18 ?? _value.field18,
    field19: field19 ?? _value.field19,
    field20: field20 ?? _value.field20,
    field21: field21 ?? _value.field21,
    field22: field22 ?? _value.field22,
    field23: field23 ?? _value.field23,
    field24: field24 ?? _value.field24,
    field25: field25 ?? _value.field25,
    field26: field26 ?? _value.field26,
    field27: field27 ?? _value.field27,
    field28: field28 ?? _value.field28,
    field29: field29 ?? _value.field29,
    field30: field30 ?? _value.field30,
    field31: field31 ?? _value.field31,
    field32: field32 ?? _value.field32,
    field33: field33 ?? _value.field33,
    field34: field34 ?? _value.field34,
    field35: field35 ?? _value.field35,
    field36: field36 ?? _value.field36,
    field37: field37 ?? _value.field37,
    field38: field38 ?? _value.field38,
    field39: field39 ?? _value.field39,
    field40: field40 ?? _value.field40,
    field41: field41 ?? _value.field41,
    field42: field42 ?? _value.field42,
    field43: field43 ?? _value.field43,
    field44: field44 ?? _value.field44,
    field45: field45 ?? _value.field45,
    field46: field46 ?? _value.field46,
    field47: field47 ?? _value.field47,
    field48: field48 ?? _value.field48,
    field49: field49 ?? _value.field49,
    field50: field50 ?? _value.field50,
    field51: field51 ?? _value.field51,
    field52: field52 ?? _value.field52,
    field53: field53 ?? _value.field53,
    field54: field54 ?? _value.field54,
    field55: field55 ?? _value.field55,
    field56: field56 ?? _value.field56,
    field57: field57 ?? _value.field57,
    field58: field58 ?? _value.field58,
    field59: field59 ?? _value.field59,
    field60: field60 ?? _value.field60,
    field61: field61 ?? _value.field61,
    field62: field62 ?? _value.field62,
    field63: field63 ?? _value.field63,
    field64: field64 ?? _value.field64,
    field65: field65 ?? _value.field65,
    field66: field66 ?? _value.field66,
    field67: field67 ?? _value.field67,
    field68: field68 ?? _value.field68,
    field69: field69 ?? _value.field69,
    field70: field70 ?? _value.field70,
    field71: field71 ?? _value.field71,
    field72: field72 ?? _value.field72,
    field73: field73 ?? _value.field73,
    field74: field74 ?? _value.field74,
    field75: field75 ?? _value.field75,
    field76: field76 ?? _value.field76,
    field77: field77 ?? _value.field77,
    field78: field78 ?? _value.field78,
    field79: field79 ?? _value.field79,
    field80: field80 ?? _value.field80,
    field81: field81 ?? _value.field81,
    field82: field82 ?? _value.field82,
    field83: field83 ?? _value.field83,
    field84: field84 ?? _value.field84,
    field85: field85 ?? _value.field85,
    field86: field86 ?? _value.field86,
    field87: field87 ?? _value.field87,
    field88: field88 ?? _value.field88,
    field89: field89 ?? _value.field89,
    field90: field90 ?? _value.field90,
    field91: field91 ?? _value.field91,
    field92: field92 ?? _value.field92,
    field93: field93 ?? _value.field93,
    field94: field94 ?? _value.field94,
    field95: field95 ?? _value.field95,
    field96: field96 ?? _value.field96,
    field97: field97 ?? _value.field97,
    field98: field98 ?? _value.field98,
    field99: field99 ?? _value.field99,
  );
}

class Bench100Schema {
  const Bench100Schema({
    this.field0 = '',
    this.field1 = '',
    this.field2 = '',
    this.field3 = '',
    this.field4 = '',
    this.field5 = '',
    this.field6 = '',
    this.field7 = '',
    this.field8 = '',
    this.field9 = '',
    this.field10 = '',
    this.field11 = '',
    this.field12 = '',
    this.field13 = '',
    this.field14 = '',
    this.field15 = '',
    this.field16 = '',
    this.field17 = '',
    this.field18 = '',
    this.field19 = '',
    this.field20 = '',
    this.field21 = '',
    this.field22 = '',
    this.field23 = '',
    this.field24 = '',
    this.field25 = '',
    this.field26 = '',
    this.field27 = '',
    this.field28 = '',
    this.field29 = '',
    this.field30 = '',
    this.field31 = '',
    this.field32 = '',
    this.field33 = '',
    this.field34 = '',
    this.field35 = '',
    this.field36 = '',
    this.field37 = '',
    this.field38 = '',
    this.field39 = '',
    this.field40 = '',
    this.field41 = '',
    this.field42 = '',
    this.field43 = '',
    this.field44 = '',
    this.field45 = '',
    this.field46 = '',
    this.field47 = '',
    this.field48 = '',
    this.field49 = '',
    this.field50 = '',
    this.field51 = '',
    this.field52 = '',
    this.field53 = '',
    this.field54 = '',
    this.field55 = '',
    this.field56 = '',
    this.field57 = '',
    this.field58 = '',
    this.field59 = '',
    this.field60 = '',
    this.field61 = '',
    this.field62 = '',
    this.field63 = '',
    this.field64 = '',
    this.field65 = '',
    this.field66 = '',
    this.field67 = '',
    this.field68 = '',
    this.field69 = '',
    this.field70 = '',
    this.field71 = '',
    this.field72 = '',
    this.field73 = '',
    this.field74 = '',
    this.field75 = '',
    this.field76 = '',
    this.field77 = '',
    this.field78 = '',
    this.field79 = '',
    this.field80 = '',
    this.field81 = '',
    this.field82 = '',
    this.field83 = '',
    this.field84 = '',
    this.field85 = '',
    this.field86 = '',
    this.field87 = '',
    this.field88 = '',
    this.field89 = '',
    this.field90 = '',
    this.field91 = '',
    this.field92 = '',
    this.field93 = '',
    this.field94 = '',
    this.field95 = '',
    this.field96 = '',
    this.field97 = '',
    this.field98 = '',
    this.field99 = '',
  });

  final String field0;
  final String field1;
  final String field2;
  final String field3;
  final String field4;
  final String field5;
  final String field6;
  final String field7;
  final String field8;
  final String field9;
  final String field10;
  final String field11;
  final String field12;
  final String field13;
  final String field14;
  final String field15;
  final String field16;
  final String field17;
  final String field18;
  final String field19;
  final String field20;
  final String field21;
  final String field22;
  final String field23;
  final String field24;
  final String field25;
  final String field26;
  final String field27;
  final String field28;
  final String field29;
  final String field30;
  final String field31;
  final String field32;
  final String field33;
  final String field34;
  final String field35;
  final String field36;
  final String field37;
  final String field38;
  final String field39;
  final String field40;
  final String field41;
  final String field42;
  final String field43;
  final String field44;
  final String field45;
  final String field46;
  final String field47;
  final String field48;
  final String field49;
  final String field50;
  final String field51;
  final String field52;
  final String field53;
  final String field54;
  final String field55;
  final String field56;
  final String field57;
  final String field58;
  final String field59;
  final String field60;
  final String field61;
  final String field62;
  final String field63;
  final String field64;
  final String field65;
  final String field66;
  final String field67;
  final String field68;
  final String field69;
  final String field70;
  final String field71;
  final String field72;
  final String field73;
  final String field74;
  final String field75;
  final String field76;
  final String field77;
  final String field78;
  final String field79;
  final String field80;
  final String field81;
  final String field82;
  final String field83;
  final String field84;
  final String field85;
  final String field86;
  final String field87;
  final String field88;
  final String field89;
  final String field90;
  final String field91;
  final String field92;
  final String field93;
  final String field94;
  final String field95;
  final String field96;
  final String field97;
  final String field98;
  final String field99;

  /// Creates a new [Bench100Schema] instance with auto-generated UUID if needed.
  factory Bench100Schema.create({
    String? field0,
    String? field1,
    String? field2,
    String? field3,
    String? field4,
    String? field5,
    String? field6,
    String? field7,
    String? field8,
    String? field9,
    String? field10,
    String? field11,
    String? field12,
    String? field13,
    String? field14,
    String? field15,
    String? field16,
    String? field17,
    String? field18,
    String? field19,
    String? field20,
    String? field21,
    String? field22,
    String? field23,
    String? field24,
    String? field25,
    String? field26,
    String? field27,
    String? field28,
    String? field29,
    String? field30,
    String? field31,
    String? field32,
    String? field33,
    String? field34,
    String? field35,
    String? field36,
    String? field37,
    String? field38,
    String? field39,
    String? field40,
    String? field41,
    String? field42,
    String? field43,
    String? field44,
    String? field45,
    String? field46,
    String? field47,
    String? field48,
    String? field49,
    String? field50,
    String? field51,
    String? field52,
    String? field53,
    String? field54,
    String? field55,
    String? field56,
    String? field57,
    String? field58,
    String? field59,
    String? field60,
    String? field61,
    String? field62,
    String? field63,
    String? field64,
    String? field65,
    String? field66,
    String? field67,
    String? field68,
    String? field69,
    String? field70,
    String? field71,
    String? field72,
    String? field73,
    String? field74,
    String? field75,
    String? field76,
    String? field77,
    String? field78,
    String? field79,
    String? field80,
    String? field81,
    String? field82,
    String? field83,
    String? field84,
    String? field85,
    String? field86,
    String? field87,
    String? field88,
    String? field89,
    String? field90,
    String? field91,
    String? field92,
    String? field93,
    String? field94,
    String? field95,
    String? field96,
    String? field97,
    String? field98,
    String? field99,
  }) {
    return Bench100Schema(
      field0: field0 ?? '',
      field1: field1 ?? '',
      field2: field2 ?? '',
      field3: field3 ?? '',
      field4: field4 ?? '',
      field5: field5 ?? '',
      field6: field6 ?? '',
      field7: field7 ?? '',
      field8: field8 ?? '',
      field9: field9 ?? '',
      field10: field10 ?? '',
      field11: field11 ?? '',
      field12: field12 ?? '',
      field13: field13 ?? '',
      field14: field14 ?? '',
      field15: field15 ?? '',
      field16: field16 ?? '',
      field17: field17 ?? '',
      field18: field18 ?? '',
      field19: field19 ?? '',
      field20: field20 ?? '',
      field21: field21 ?? '',
      field22: field22 ?? '',
      field23: field23 ?? '',
      field24: field24 ?? '',
      field25: field25 ?? '',
      field26: field26 ?? '',
      field27: field27 ?? '',
      field28: field28 ?? '',
      field29: field29 ?? '',
      field30: field30 ?? '',
      field31: field31 ?? '',
      field32: field32 ?? '',
      field33: field33 ?? '',
      field34: field34 ?? '',
      field35: field35 ?? '',
      field36: field36 ?? '',
      field37: field37 ?? '',
      field38: field38 ?? '',
      field39: field39 ?? '',
      field40: field40 ?? '',
      field41: field41 ?? '',
      field42: field42 ?? '',
      field43: field43 ?? '',
      field44: field44 ?? '',
      field45: field45 ?? '',
      field46: field46 ?? '',
      field47: field47 ?? '',
      field48: field48 ?? '',
      field49: field49 ?? '',
      field50: field50 ?? '',
      field51: field51 ?? '',
      field52: field52 ?? '',
      field53: field53 ?? '',
      field54: field54 ?? '',
      field55: field55 ?? '',
      field56: field56 ?? '',
      field57: field57 ?? '',
      field58: field58 ?? '',
      field59: field59 ?? '',
      field60: field60 ?? '',
      field61: field61 ?? '',
      field62: field62 ?? '',
      field63: field63 ?? '',
      field64: field64 ?? '',
      field65: field65 ?? '',
      field66: field66 ?? '',
      field67: field67 ?? '',
      field68: field68 ?? '',
      field69: field69 ?? '',
      field70: field70 ?? '',
      field71: field71 ?? '',
      field72: field72 ?? '',
      field73: field73 ?? '',
      field74: field74 ?? '',
      field75: field75 ?? '',
      field76: field76 ?? '',
      field77: field77 ?? '',
      field78: field78 ?? '',
      field79: field79 ?? '',
      field80: field80 ?? '',
      field81: field81 ?? '',
      field82: field82 ?? '',
      field83: field83 ?? '',
      field84: field84 ?? '',
      field85: field85 ?? '',
      field86: field86 ?? '',
      field87: field87 ?? '',
      field88: field88 ?? '',
      field89: field89 ?? '',
      field90: field90 ?? '',
      field91: field91 ?? '',
      field92: field92 ?? '',
      field93: field93 ?? '',
      field94: field94 ?? '',
      field95: field95 ?? '',
      field96: field96 ?? '',
      field97: field97 ?? '',
      field98: field98 ?? '',
      field99: field99 ?? '',
    );
  }

  Bench100SchemaCopyWith<Bench100Schema> get copyWith =>
      _Bench100SchemaCopyWithImpl(this);

  /// Converts this [Bench100Schema] to a Map representation.
  Map<String, Object?> toMap() => {
    'field0': field0,
    'field1': field1,
    'field2': field2,
    'field3': field3,
    'field4': field4,
    'field5': field5,
    'field6': field6,
    'field7': field7,
    'field8': field8,
    'field9': field9,
    'field10': field10,
    'field11': field11,
    'field12': field12,
    'field13': field13,
    'field14': field14,
    'field15': field15,
    'field16': field16,
    'field17': field17,
    'field18': field18,
    'field19': field19,
    'field20': field20,
    'field21': field21,
    'field22': field22,
    'field23': field23,
    'field24': field24,
    'field25': field25,
    'field26': field26,
    'field27': field27,
    'field28': field28,
    'field29': field29,
    'field30': field30,
    'field31': field31,
    'field32': field32,
    'field33': field33,
    'field34': field34,
    'field35': field35,
    'field36': field36,
    'field37': field37,
    'field38': field38,
    'field39': field39,
    'field40': field40,
    'field41': field41,
    'field42': field42,
    'field43': field43,
    'field44': field44,
    'field45': field45,
    'field46': field46,
    'field47': field47,
    'field48': field48,
    'field49': field49,
    'field50': field50,
    'field51': field51,
    'field52': field52,
    'field53': field53,
    'field54': field54,
    'field55': field55,
    'field56': field56,
    'field57': field57,
    'field58': field58,
    'field59': field59,
    'field60': field60,
    'field61': field61,
    'field62': field62,
    'field63': field63,
    'field64': field64,
    'field65': field65,
    'field66': field66,
    'field67': field67,
    'field68': field68,
    'field69': field69,
    'field70': field70,
    'field71': field71,
    'field72': field72,
    'field73': field73,
    'field74': field74,
    'field75': field75,
    'field76': field76,
    'field77': field77,
    'field78': field78,
    'field79': field79,
    'field80': field80,
    'field81': field81,
    'field82': field82,
    'field83': field83,
    'field84': field84,
    'field85': field85,
    'field86': field86,
    'field87': field87,
    'field88': field88,
    'field89': field89,
    'field90': field90,
    'field91': field91,
    'field92': field92,
    'field93': field93,
    'field94': field94,
    'field95': field95,
    'field96': field96,
    'field97': field97,
    'field98': field98,
    'field99': field99,
  };

  List<Object?> get _validationValues => [
    field0,
    field1,
    field2,
    field3,
    field4,
    field5,
    field6,
    field7,
    field8,
    field9,
    field10,
    field11,
    field12,
    field13,
    field14,
    field15,
    field16,
    field17,
    field18,
    field19,
    field20,
    field21,
    field22,
    field23,
    field24,
    field25,
    field26,
    field27,
    field28,
    field29,
    field30,
    field31,
    field32,
    field33,
    field34,
    field35,
    field36,
    field37,
    field38,
    field39,
    field40,
    field41,
    field42,
    field43,
    field44,
    field45,
    field46,
    field47,
    field48,
    field49,
    field50,
    field51,
    field52,
    field53,
    field54,
    field55,
    field56,
    field57,
    field58,
    field59,
    field60,
    field61,
    field62,
    field63,
    field64,
    field65,
    field66,
    field67,
    field68,
    field69,
    field70,
    field71,
    field72,
    field73,
    field74,
    field75,
    field76,
    field77,
    field78,
    field79,
    field80,
    field81,
    field82,
    field83,
    field84,
    field85,
    field86,
    field87,
    field88,
    field89,
    field90,
    field91,
    field92,
    field93,
    field94,
    field95,
    field96,
    field97,
    field98,
    field99,
  ];

  /// Validates this [Bench100Schema] against its schema. Pass [scope] (a `FieldKey`)
  /// to re-check only that subtree — see `KeyedFormController.scopeOf`.
  FieldErrors<String> validate([FieldKey? scope]) =>
      benchSchema.validateValues(_validationValues, scope: scope);

  /// Asynchronously validates this [Bench100Schema] against its schema.
  Future<FieldErrors<String>> validateAsync([FieldKey? scope]) =>
      benchSchema.validateValuesAsync(_validationValues, scope: scope);

  /// Static validator — assignable straight to `KeyedFormController.resolver`.
  static FieldErrors<String> validateData(
    Bench100Schema schema, [
    FieldKey? scope,
  ]) => schema.validate(scope);

  /// Static async validator for [Bench100Schema].
  static Future<FieldErrors<String>> validateDataAsync(
    Bench100Schema schema, [
    FieldKey? scope,
  ]) => schema.validateAsync(scope);

  /// The default `KeyedFormController.scopeOf` for [Bench100Schema] — a write inside a
  /// list row re-validates just that row, otherwise its top-level field.
  static FieldKey? scopeOf(FieldKey writtenKey) => rowScopeOf(writtenKey);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bench100Schema &&
        field0 == other.field0 &&
        field1 == other.field1 &&
        field2 == other.field2 &&
        field3 == other.field3 &&
        field4 == other.field4 &&
        field5 == other.field5 &&
        field6 == other.field6 &&
        field7 == other.field7 &&
        field8 == other.field8 &&
        field9 == other.field9 &&
        field10 == other.field10 &&
        field11 == other.field11 &&
        field12 == other.field12 &&
        field13 == other.field13 &&
        field14 == other.field14 &&
        field15 == other.field15 &&
        field16 == other.field16 &&
        field17 == other.field17 &&
        field18 == other.field18 &&
        field19 == other.field19 &&
        field20 == other.field20 &&
        field21 == other.field21 &&
        field22 == other.field22 &&
        field23 == other.field23 &&
        field24 == other.field24 &&
        field25 == other.field25 &&
        field26 == other.field26 &&
        field27 == other.field27 &&
        field28 == other.field28 &&
        field29 == other.field29 &&
        field30 == other.field30 &&
        field31 == other.field31 &&
        field32 == other.field32 &&
        field33 == other.field33 &&
        field34 == other.field34 &&
        field35 == other.field35 &&
        field36 == other.field36 &&
        field37 == other.field37 &&
        field38 == other.field38 &&
        field39 == other.field39 &&
        field40 == other.field40 &&
        field41 == other.field41 &&
        field42 == other.field42 &&
        field43 == other.field43 &&
        field44 == other.field44 &&
        field45 == other.field45 &&
        field46 == other.field46 &&
        field47 == other.field47 &&
        field48 == other.field48 &&
        field49 == other.field49 &&
        field50 == other.field50 &&
        field51 == other.field51 &&
        field52 == other.field52 &&
        field53 == other.field53 &&
        field54 == other.field54 &&
        field55 == other.field55 &&
        field56 == other.field56 &&
        field57 == other.field57 &&
        field58 == other.field58 &&
        field59 == other.field59 &&
        field60 == other.field60 &&
        field61 == other.field61 &&
        field62 == other.field62 &&
        field63 == other.field63 &&
        field64 == other.field64 &&
        field65 == other.field65 &&
        field66 == other.field66 &&
        field67 == other.field67 &&
        field68 == other.field68 &&
        field69 == other.field69 &&
        field70 == other.field70 &&
        field71 == other.field71 &&
        field72 == other.field72 &&
        field73 == other.field73 &&
        field74 == other.field74 &&
        field75 == other.field75 &&
        field76 == other.field76 &&
        field77 == other.field77 &&
        field78 == other.field78 &&
        field79 == other.field79 &&
        field80 == other.field80 &&
        field81 == other.field81 &&
        field82 == other.field82 &&
        field83 == other.field83 &&
        field84 == other.field84 &&
        field85 == other.field85 &&
        field86 == other.field86 &&
        field87 == other.field87 &&
        field88 == other.field88 &&
        field89 == other.field89 &&
        field90 == other.field90 &&
        field91 == other.field91 &&
        field92 == other.field92 &&
        field93 == other.field93 &&
        field94 == other.field94 &&
        field95 == other.field95 &&
        field96 == other.field96 &&
        field97 == other.field97 &&
        field98 == other.field98 &&
        field99 == other.field99;
  }

  @override
  int get hashCode => Object.hashAll([
    field0,
    field1,
    field2,
    field3,
    field4,
    field5,
    field6,
    field7,
    field8,
    field9,
    field10,
    field11,
    field12,
    field13,
    field14,
    field15,
    field16,
    field17,
    field18,
    field19,
    field20,
    field21,
    field22,
    field23,
    field24,
    field25,
    field26,
    field27,
    field28,
    field29,
    field30,
    field31,
    field32,
    field33,
    field34,
    field35,
    field36,
    field37,
    field38,
    field39,
    field40,
    field41,
    field42,
    field43,
    field44,
    field45,
    field46,
    field47,
    field48,
    field49,
    field50,
    field51,
    field52,
    field53,
    field54,
    field55,
    field56,
    field57,
    field58,
    field59,
    field60,
    field61,
    field62,
    field63,
    field64,
    field65,
    field66,
    field67,
    field68,
    field69,
    field70,
    field71,
    field72,
    field73,
    field74,
    field75,
    field76,
    field77,
    field78,
    field79,
    field80,
    field81,
    field82,
    field83,
    field84,
    field85,
    field86,
    field87,
    field88,
    field89,
    field90,
    field91,
    field92,
    field93,
    field94,
    field95,
    field96,
    field97,
    field98,
    field99,
  ]);
}

abstract final class Bench100Fields {
  static StrictFieldRef<Bench100Schema, String> get field0 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field0'),
        get: (x) => x.field0,
        set: (x, v) => x.copyWith(field0: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field1 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field1'),
        get: (x) => x.field1,
        set: (x, v) => x.copyWith(field1: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field2 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field2'),
        get: (x) => x.field2,
        set: (x, v) => x.copyWith(field2: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field3 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field3'),
        get: (x) => x.field3,
        set: (x, v) => x.copyWith(field3: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field4 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field4'),
        get: (x) => x.field4,
        set: (x, v) => x.copyWith(field4: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field5 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field5'),
        get: (x) => x.field5,
        set: (x, v) => x.copyWith(field5: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field6 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field6'),
        get: (x) => x.field6,
        set: (x, v) => x.copyWith(field6: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field7 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field7'),
        get: (x) => x.field7,
        set: (x, v) => x.copyWith(field7: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field8 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field8'),
        get: (x) => x.field8,
        set: (x, v) => x.copyWith(field8: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field9 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field9'),
        get: (x) => x.field9,
        set: (x, v) => x.copyWith(field9: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field10 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field10'),
        get: (x) => x.field10,
        set: (x, v) => x.copyWith(field10: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field11 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field11'),
        get: (x) => x.field11,
        set: (x, v) => x.copyWith(field11: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field12 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field12'),
        get: (x) => x.field12,
        set: (x, v) => x.copyWith(field12: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field13 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field13'),
        get: (x) => x.field13,
        set: (x, v) => x.copyWith(field13: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field14 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field14'),
        get: (x) => x.field14,
        set: (x, v) => x.copyWith(field14: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field15 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field15'),
        get: (x) => x.field15,
        set: (x, v) => x.copyWith(field15: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field16 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field16'),
        get: (x) => x.field16,
        set: (x, v) => x.copyWith(field16: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field17 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field17'),
        get: (x) => x.field17,
        set: (x, v) => x.copyWith(field17: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field18 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field18'),
        get: (x) => x.field18,
        set: (x, v) => x.copyWith(field18: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field19 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field19'),
        get: (x) => x.field19,
        set: (x, v) => x.copyWith(field19: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field20 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field20'),
        get: (x) => x.field20,
        set: (x, v) => x.copyWith(field20: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field21 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field21'),
        get: (x) => x.field21,
        set: (x, v) => x.copyWith(field21: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field22 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field22'),
        get: (x) => x.field22,
        set: (x, v) => x.copyWith(field22: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field23 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field23'),
        get: (x) => x.field23,
        set: (x, v) => x.copyWith(field23: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field24 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field24'),
        get: (x) => x.field24,
        set: (x, v) => x.copyWith(field24: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field25 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field25'),
        get: (x) => x.field25,
        set: (x, v) => x.copyWith(field25: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field26 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field26'),
        get: (x) => x.field26,
        set: (x, v) => x.copyWith(field26: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field27 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field27'),
        get: (x) => x.field27,
        set: (x, v) => x.copyWith(field27: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field28 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field28'),
        get: (x) => x.field28,
        set: (x, v) => x.copyWith(field28: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field29 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field29'),
        get: (x) => x.field29,
        set: (x, v) => x.copyWith(field29: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field30 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field30'),
        get: (x) => x.field30,
        set: (x, v) => x.copyWith(field30: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field31 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field31'),
        get: (x) => x.field31,
        set: (x, v) => x.copyWith(field31: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field32 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field32'),
        get: (x) => x.field32,
        set: (x, v) => x.copyWith(field32: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field33 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field33'),
        get: (x) => x.field33,
        set: (x, v) => x.copyWith(field33: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field34 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field34'),
        get: (x) => x.field34,
        set: (x, v) => x.copyWith(field34: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field35 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field35'),
        get: (x) => x.field35,
        set: (x, v) => x.copyWith(field35: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field36 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field36'),
        get: (x) => x.field36,
        set: (x, v) => x.copyWith(field36: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field37 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field37'),
        get: (x) => x.field37,
        set: (x, v) => x.copyWith(field37: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field38 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field38'),
        get: (x) => x.field38,
        set: (x, v) => x.copyWith(field38: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field39 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field39'),
        get: (x) => x.field39,
        set: (x, v) => x.copyWith(field39: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field40 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field40'),
        get: (x) => x.field40,
        set: (x, v) => x.copyWith(field40: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field41 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field41'),
        get: (x) => x.field41,
        set: (x, v) => x.copyWith(field41: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field42 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field42'),
        get: (x) => x.field42,
        set: (x, v) => x.copyWith(field42: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field43 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field43'),
        get: (x) => x.field43,
        set: (x, v) => x.copyWith(field43: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field44 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field44'),
        get: (x) => x.field44,
        set: (x, v) => x.copyWith(field44: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field45 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field45'),
        get: (x) => x.field45,
        set: (x, v) => x.copyWith(field45: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field46 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field46'),
        get: (x) => x.field46,
        set: (x, v) => x.copyWith(field46: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field47 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field47'),
        get: (x) => x.field47,
        set: (x, v) => x.copyWith(field47: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field48 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field48'),
        get: (x) => x.field48,
        set: (x, v) => x.copyWith(field48: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field49 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field49'),
        get: (x) => x.field49,
        set: (x, v) => x.copyWith(field49: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field50 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field50'),
        get: (x) => x.field50,
        set: (x, v) => x.copyWith(field50: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field51 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field51'),
        get: (x) => x.field51,
        set: (x, v) => x.copyWith(field51: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field52 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field52'),
        get: (x) => x.field52,
        set: (x, v) => x.copyWith(field52: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field53 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field53'),
        get: (x) => x.field53,
        set: (x, v) => x.copyWith(field53: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field54 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field54'),
        get: (x) => x.field54,
        set: (x, v) => x.copyWith(field54: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field55 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field55'),
        get: (x) => x.field55,
        set: (x, v) => x.copyWith(field55: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field56 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field56'),
        get: (x) => x.field56,
        set: (x, v) => x.copyWith(field56: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field57 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field57'),
        get: (x) => x.field57,
        set: (x, v) => x.copyWith(field57: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field58 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field58'),
        get: (x) => x.field58,
        set: (x, v) => x.copyWith(field58: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field59 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field59'),
        get: (x) => x.field59,
        set: (x, v) => x.copyWith(field59: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field60 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field60'),
        get: (x) => x.field60,
        set: (x, v) => x.copyWith(field60: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field61 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field61'),
        get: (x) => x.field61,
        set: (x, v) => x.copyWith(field61: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field62 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field62'),
        get: (x) => x.field62,
        set: (x, v) => x.copyWith(field62: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field63 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field63'),
        get: (x) => x.field63,
        set: (x, v) => x.copyWith(field63: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field64 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field64'),
        get: (x) => x.field64,
        set: (x, v) => x.copyWith(field64: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field65 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field65'),
        get: (x) => x.field65,
        set: (x, v) => x.copyWith(field65: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field66 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field66'),
        get: (x) => x.field66,
        set: (x, v) => x.copyWith(field66: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field67 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field67'),
        get: (x) => x.field67,
        set: (x, v) => x.copyWith(field67: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field68 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field68'),
        get: (x) => x.field68,
        set: (x, v) => x.copyWith(field68: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field69 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field69'),
        get: (x) => x.field69,
        set: (x, v) => x.copyWith(field69: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field70 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field70'),
        get: (x) => x.field70,
        set: (x, v) => x.copyWith(field70: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field71 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field71'),
        get: (x) => x.field71,
        set: (x, v) => x.copyWith(field71: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field72 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field72'),
        get: (x) => x.field72,
        set: (x, v) => x.copyWith(field72: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field73 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field73'),
        get: (x) => x.field73,
        set: (x, v) => x.copyWith(field73: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field74 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field74'),
        get: (x) => x.field74,
        set: (x, v) => x.copyWith(field74: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field75 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field75'),
        get: (x) => x.field75,
        set: (x, v) => x.copyWith(field75: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field76 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field76'),
        get: (x) => x.field76,
        set: (x, v) => x.copyWith(field76: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field77 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field77'),
        get: (x) => x.field77,
        set: (x, v) => x.copyWith(field77: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field78 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field78'),
        get: (x) => x.field78,
        set: (x, v) => x.copyWith(field78: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field79 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field79'),
        get: (x) => x.field79,
        set: (x, v) => x.copyWith(field79: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field80 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field80'),
        get: (x) => x.field80,
        set: (x, v) => x.copyWith(field80: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field81 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field81'),
        get: (x) => x.field81,
        set: (x, v) => x.copyWith(field81: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field82 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field82'),
        get: (x) => x.field82,
        set: (x, v) => x.copyWith(field82: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field83 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field83'),
        get: (x) => x.field83,
        set: (x, v) => x.copyWith(field83: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field84 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field84'),
        get: (x) => x.field84,
        set: (x, v) => x.copyWith(field84: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field85 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field85'),
        get: (x) => x.field85,
        set: (x, v) => x.copyWith(field85: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field86 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field86'),
        get: (x) => x.field86,
        set: (x, v) => x.copyWith(field86: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field87 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field87'),
        get: (x) => x.field87,
        set: (x, v) => x.copyWith(field87: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field88 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field88'),
        get: (x) => x.field88,
        set: (x, v) => x.copyWith(field88: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field89 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field89'),
        get: (x) => x.field89,
        set: (x, v) => x.copyWith(field89: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field90 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field90'),
        get: (x) => x.field90,
        set: (x, v) => x.copyWith(field90: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field91 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field91'),
        get: (x) => x.field91,
        set: (x, v) => x.copyWith(field91: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field92 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field92'),
        get: (x) => x.field92,
        set: (x, v) => x.copyWith(field92: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field93 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field93'),
        get: (x) => x.field93,
        set: (x, v) => x.copyWith(field93: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field94 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field94'),
        get: (x) => x.field94,
        set: (x, v) => x.copyWith(field94: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field95 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field95'),
        get: (x) => x.field95,
        set: (x, v) => x.copyWith(field95: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field96 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field96'),
        get: (x) => x.field96,
        set: (x, v) => x.copyWith(field96: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field97 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field97'),
        get: (x) => x.field97,
        set: (x, v) => x.copyWith(field97: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field98 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field98'),
        get: (x) => x.field98,
        set: (x, v) => x.copyWith(field98: v),
      );

  static StrictFieldRef<Bench100Schema, String> get field99 =>
      StrictFieldRef<Bench100Schema, String>.of(
        key: FieldKey.name('field99'),
        get: (x) => x.field99,
        set: (x, v) => x.copyWith(field99: v),
      );
}
