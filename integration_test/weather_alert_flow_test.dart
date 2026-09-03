import 'package:integration_test/integration_test.dart';

import '../test/integration/weather_alert_scenario.dart' as scenario;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  scenario.main();
}
