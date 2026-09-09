import 'package:integration_test/integration_test.dart';

import '../test/integration/session_sync_isolation_scenario.dart' as scenario;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  scenario.main();
}
