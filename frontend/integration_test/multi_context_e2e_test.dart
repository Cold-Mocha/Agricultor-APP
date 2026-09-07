import 'package:integration_test/integration_test.dart';

import '../../backend/test/integration/multi_context_scenario.dart' as scenario;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  scenario.main();
}
