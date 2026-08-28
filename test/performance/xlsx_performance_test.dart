import 'package:agrocampo/core/export/export_snapshot.dart';
import 'package:agrocampo/core/export/xlsx_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'exports 5,000 rows away from the UI isolate within the MVP budget',
    () async {
      final rows = List.generate(
        5000,
        (index) => {
          'id': 'row-$index',
          'sector_id': 'sector-${index % 20}',
          'valor': index,
        },
      );
      final snapshot = AgroExportSnapshot(
        generatedAt: DateTime.utc(2026, 8, 28),
        sheets: {'registros': rows},
      );
      final stopwatch = Stopwatch()..start();
      final bytes = await const XlsxExporter().encodeOffMainIsolate(snapshot);
      stopwatch.stop();
      expect(bytes, isNotEmpty);
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 15)));
    },
  );
}
