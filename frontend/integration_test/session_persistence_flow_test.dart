import 'package:integration_test/integration_test.dart';

import '../test/integration/session_persistence_scenario.dart' as scenario;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  scenario.main();
}
