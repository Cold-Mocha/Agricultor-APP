import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:agrocampo/core/sync/protocol/sync_pull_response_parser.dart';
import 'package:agrocampo/core/sync/protocol/sync_push_response_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = SyncPushResponseParser();
  const requests = [
    PushMutation(
      operationId: 'one',
      aggregateType: 'parcel',
      aggregateId: 'p1',
      kind: 'create',
      payloadJson: '{}',
    ),
    PushMutation(
      operationId: 'two',
      aggregateType: 'parcel',
      aggregateId: 'p2',
      kind: 'create',
      payloadJson: '{}',
    ),
  ];

  test('accepts exactly one validated result per request', () {
    final result = parser.parse({
      'protocol_version': 2,
      'results': [
        {'operation_id': 'one', 'status': 'applied'},
        {'operation_id': 'two', 'status': 'duplicate'},
      ],
    }, requests);
    expect(
      result.operations.map((item) => item.isAcknowledged),
      everyElement(isTrue),
    );
  });

  test('pull requires strictly ascending complete structured changes', () {
    const pullParser = SyncPullResponseParser();
    final result = pullParser.parse([
      {
        'change_seq': 8,
        'aggregate_type': 'parcel',
        'aggregate_id': 'p1',
        'mutation_kind': 'update',
        'remote_version': 2,
        'payload': {'id': 'p1'},
      },
    ], 7);
    expect(result.nextCursor, 8);
    expect(result.changes, hasLength(1));
    expect(
      () => pullParser.parse([
        {
          'change_seq': 7,
          'aggregate_type': 'parcel',
          'aggregate_id': 'p1',
          'mutation_kind': 'update',
          'remote_version': 2,
          'payload': {'id': 'p1'},
        },
      ], 7),
      throwsFormatException,
    );
  });

  test('rejects partial, duplicate, unknown and malformed responses', () {
    for (final response in [
      {
        'protocol_version': 2,
        'results': [
          {'operation_id': 'one', 'status': 'applied'},
        ],
      },
      {
        'protocol_version': 2,
        'results': [
          {'operation_id': 'one', 'status': 'applied'},
          {'operation_id': 'one', 'status': 'duplicate'},
        ],
      },
      {
        'protocol_version': 2,
        'results': [
          {'operation_id': 'one', 'status': 'applied'},
          {'operation_id': 'other', 'status': 'applied'},
        ],
      },
      {'protocol_version': 1, 'results': <Object?>[]},
    ]) {
      expect(() => parser.parse(response, requests), throwsFormatException);
    }
  });
}
