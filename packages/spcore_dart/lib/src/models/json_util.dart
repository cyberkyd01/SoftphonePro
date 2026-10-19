import 'dart:convert';

import 'package:collection/collection.dart';

/// Enum with a stable wire (JSON) name.
abstract interface class WireEnum {
  String get wire;
}

/// Parses [v] into one of [values] by wire name, or returns [fallback].
T parseEnum<T extends WireEnum>(List<T> values, Object? v, T fallback) {
  if (v is String) {
    for (final e in values) {
      if (e.wire == v) return e;
    }
  }
  return fallback;
}

int asInt(Object? v, [int def = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? def;
  return def;
}

int? asIntN(Object? v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

double asDouble(Object? v, [double def = 0]) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? def;
  return def;
}

double? asDoubleN(Object? v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

bool asBool(Object? v, [bool def = false]) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v == 'true' ? true : (v == 'false' ? false : def);
  return def;
}

bool? asBoolN(Object? v) => v == null ? null : asBool(v);

String asString(Object? v, [String def = '']) {
  if (v == null) return def;
  return v is String ? v : v.toString();
}

String? asStringN(Object? v) => v == null ? null : asString(v);

Map<String, dynamic> asMap(Object? v) {
  if (v is Map) {
    return v.map((k, val) => MapEntry(k.toString(), val));
  }
  return const <String, dynamic>{};
}

List<dynamic> asList(Object? v) => v is List ? v : const <dynamic>[];

List<String> asStringList(Object? v, [List<String> def = const []]) =>
    v is List ? v.map((e) => asString(e)).toList() : def;

List<int> asIntList(Object? v, [List<int> def = const []]) =>
    v is List ? v.map((e) => asInt(e)).toList() : def;

Map<String, String> asStringMap(
  Object? v, [
  Map<String, String> def = const {},
]) {
  if (v is Map) {
    return v.map((k, val) => MapEntry(k.toString(), asString(val)));
  }
  return def;
}

const _deepEq = DeepCollectionEquality();

bool jsonEqual(Object? a, Object? b) => _deepEq.equals(a, b);

int jsonHash(Object? a) => jsonEncode(a).hashCode;
