import 'package:integration_test/integration_test.dart';

import '../test/integration/functional_core_offline_restart_scenario.dart'
    as scenario;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  scenario.main();
}
