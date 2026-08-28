import 'package:agrocampo/core/observability/safe_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('logger redacts credential, prompt and precise-location metadata', () {
    expect(
      DeveloperSafeLogger.sanitize({
        'event_id': '1',
        'access_token': 'secret',
        'apiKey': 'key',
        'prompt': 'private',
        'latitude': -34.9,
      }),
      {'event_id': '1'},
    );
  });
}
