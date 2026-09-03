import '../features/apiary/apiary_repository_test.dart' as apiary;
import '../features/export/xlsx_contract_test.dart' as xlsx;
import '../features/irrigation/basic_record_test.dart' as irrigation;
import '../features/photos/photo_repository_test.dart' as photos;
import '../features/soil/soil_repository_test.dart' as soil;

void main() {
  soil.main();
  photos.main();
  apiary.main();
  xlsx.main();
  irrigation.main();
}
