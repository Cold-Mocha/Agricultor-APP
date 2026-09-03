import 'package:integration_test/integration_test.dart';

import '../test/core/sync/seasons_crops_v2_local_e2e_test.dart' as scenario;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  scenario.main();
}
