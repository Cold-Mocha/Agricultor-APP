import 'package:agrocampo_backend/src/modules/export/infrastructure/export_snapshot.dart';
import 'package:agrocampo_backend/src/modules/export/infrastructure/xlsx_exporter.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('XLSX v1 preserves identifiers, relationships and pending state', () {
    final bytes = const XlsxExporter().encode(
      AgroExportSnapshot(
        generatedAt: DateTime.utc(2026, 8, 28),
        sheets: {
          'sectores': [
            {'id': 'sector-1', 'numero': 1, 'nombre': 'Norte'},
          ],
          'labores': [
            {'id': 'labor-1', 'sector_id': 'sector-1', 'tipo': 'pruning'},
          ],
        },
      ),
    );
    final decoded = Excel.decodeBytes(bytes);
    expect(decoded.tables.keys, containsAll(['sectores', 'labores']));
    expect(decoded.tables.keys, isNot(contains('parcelas')));
    expect(
      decoded.tables['sectores']!.rows[1][0]!.value.toString(),
      'sector-1',
    );
    expect(
      decoded.tables['labores']!.rows[1][1]!.value.toString(),
      'sector-1',
    );
    expect(bytes.take(2), [80, 75]);
  });
}
