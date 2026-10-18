import 'package:integration_test/integration_test.dart';

import '../../backend/test/integration/labors_production_v2_local_e2e_test.dart'
    as scenario;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  scenario.main();
}
