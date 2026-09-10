import 'package:integration_test/integration_test.dart';

import '../test/modules/apiary/apiary_inspection_page_test.dart' as apiary;
import '../test/modules/history/history_page_test.dart' as history;
import '../test/modules/labors/fertilization_form_test.dart' as fertilization;
import '../test/modules/labors/labor_form_page_test.dart' as labor;
import '../test/modules/production/production_page_test.dart' as production;
import '../test/modules/soil/soil_measurement_page_test.dart' as soil;

/// Representative 003 flow set. Each scenario uses the public UI and a
/// local Drift database, so it is also runnable on the Android emulator.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  labor.main();
  soil.main();
  production.main();
  fertilization.main();
  apiary.main();
  history.main();
}
