import 'dart:convert';
import 'package:flutter/material.dart';

enum ParamType {
  int,
  double,
  String,
  bool,
  DateTime,
  DateTimeRange,
  LatLng,
  Color,
  FFPlace,
  FFUploadedFile,
  JSON,
}

dynamic serializeParam(
  dynamic param,
  ParamType paramType, {
  bool isList = false,
}) {
  try {
    if (param == null) return null;
    if (paramType == ParamType.JSON) {
      return jsonEncode(param);
    }
    return param.toString();
  } catch (e) {
    return null;
  }
}

dynamic deserializeParam<T>(
  dynamic param,
  ParamType paramType,
  bool isList,
) {
  try {
    if (param == null) return null;
    if (paramType == ParamType.JSON) {
      return jsonDecode(param);
    }
    return param as T;
  } catch (e) {
    return null;
  }
}

extension MapWithoutNullsExtension on Map<String, dynamic> {
  Map<String, dynamic> get withoutNulls => Map.fromEntries(
        entries.where((e) => e.value != null),
      );
}

extension CastListExtension on List? {
  List<T>? toListOrNull<T>() => this?.cast<T>().toList();
}

extension FFJsonExtension on dynamic {
  dynamic get(String key) {
    if (this is Map) {
      return (this as Map)[key];
    }
    return null;
  }
}

dynamic getJsonField(
  dynamic response,
  String jsonPath, [
  bool isForList = false,
]) {
  try {
    if (response == null) return null;
    if (response is String) {
      response = jsonDecode(response);
    }
    List<String> keys = jsonPath.replaceAll(r'$.', '').split('.');
    dynamic current = response;
    for (String key in keys) {
      if (current is Map && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  } catch (_) {
    return null;
  }
}
