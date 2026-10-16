import '../modules/apiary/apiary_repository_test.dart' as apiary;
import '../modules/export/xlsx_contract_test.dart' as xlsx;
import '../modules/irrigation/basic_record_test.dart' as irrigation;
import '../modules/media/photo_repository_test.dart' as photos;
import '../modules/soil/soil_repository_test.dart' as soil;

void main() {
  soil.main();
  photos.main();
  apiary.main();
  xlsx.main();
  irrigation.main();
}
