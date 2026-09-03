import 'package:integration_test/integration_test.dart';

import '../test/integration/sync_conflict_tombstone_scenario.dart' as scenario;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  scenario.main();
}
