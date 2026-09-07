import 'package:integration_test/integration_test.dart';

import '../../backend/test/integration/session_sync_isolation_scenario.dart'
    as scenario;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  scenario.main();
}
