import '../modules/apiary/apiary_sync_codec_test.dart' as apiary;
import '../modules/irrigation/basic_record_test.dart' as irrigation;
import '../modules/labors/labor_sync_codec_test.dart' as labor;
import '../modules/territory/territory_sync_codec_test.dart' as territory;
import '../platform/sync/sync_contract_test.dart' as protocol;

/// Compound sync regression entry point for the 003 specializations. Each
/// imported suite owns its fixtures and remains independently runnable.
void main() {
  protocol.main();
  territory.main();
  labor.main();
  apiary.main();
  irrigation.main();
}
