import 'package:integration_test/integration_test.dart';

import '../test/modules/labors/fertilization_form_test.dart' as scenario;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  scenario.main();
}
