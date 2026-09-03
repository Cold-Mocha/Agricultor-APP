import 'dart:convert';

import 'package:agrocampo/features/labors/domain/labor_type.dart';

final class LaborDetails {
  const LaborDetails({
    required this.type,
    required this.schemaVersion,
    required this.data,
  });

  factory LaborDetails.decode(String source) {
    final value = jsonDecode(source);
    if (value is! Map<String, Object?> ||
        value['schemaVersion'] is! int ||
        value['type'] is! String ||
        value['data'] is! Map<String, Object?>) {
      throw const FormatException('labor_details_envelope_invalid');
    }
    return LaborDetails(
      type: LaborType.values.byName(value['type']! as String),
      schemaVersion: value['schemaVersion']! as int,
      data: Map<String, Object?>.unmodifiable(
        value['data']! as Map<String, Object?>,
      ),
    );
  }

  static const currentSchemaVersion = 1;

  final LaborType type;
  final int schemaVersion;
  final Map<String, Object?> data;

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'type': type.name,
    'data': data,
  };

  String encode() => jsonEncode(toJson());

  static LaborDetails current(LaborType type, Map<String, Object?> data) =>
      LaborDetails(
        type: type,
        schemaVersion: currentSchemaVersion,
        data: Map<String, Object?>.unmodifiable(data),
      );
}
