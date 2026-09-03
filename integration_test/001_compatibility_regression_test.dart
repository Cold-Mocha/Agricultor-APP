// ignore_for_file: file_names

import 'package:integration_test/integration_test.dart';

import '../test/integration/compatibility_001_scenario.dart' as scenario;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  scenario.main();
}
