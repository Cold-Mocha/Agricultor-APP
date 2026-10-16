import 'package:integration_test/integration_test.dart';

import '../../backend/test/integration/reminder_restart_scenario.dart'
    as scenario;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  scenario.main();
}
