import 'dart:convert';

import 'package:crypto/crypto.dart';

String syncRequestHash({
  required String aggregateType,
  required String aggregateId,
  required String mutationKind,
  required int? baseVersion,
  required Object payload,
}) => sha256
    .convert(
      utf8.encode(
        jsonEncode({
          'protocol_version': 2,
          'aggregate_type': aggregateType,
          'aggregate_id': aggregateId,
          'mutation_kind': mutationKind,
          'base_version': baseVersion,
          'payload_schema_version': 1,
          'payload': payload,
        }),
      ),
    )
    .toString();
