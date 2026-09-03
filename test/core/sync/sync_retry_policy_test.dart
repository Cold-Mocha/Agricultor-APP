import 'package:agrocampo/core/sync/sync_retry_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses deterministic exponential delay with a practical cap', () {
    const policy = SyncRetryPolicy(baseSeconds: 30, maximumSeconds: 1800);
    expect(policy.delayForAttempt(0), const Duration(seconds: 30));
    expect(
      policy.delayForAttempt(1, operationId: 'stable'),
      policy.delayForAttempt(1, operationId: 'stable'),
    );
    expect(policy.delayForAttempt(6), const Duration(seconds: 1800));
    expect(policy.delayForAttempt(50), const Duration(seconds: 1800));
    expect(
      policy.delayForAttempt(0, serverDelay: const Duration(minutes: 2)),
      const Duration(minutes: 2),
    );
  });
}
