import 'package:integration_test/integration_test.dart';

import '../../backend/test/integration/session_persistence_scenario.dart'
    as scenario;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  scenario.main();
}
