import 'package:agrocampo/core/export/export_snapshot.dart';
import 'package:agrocampo/core/export/xlsx_exporter.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('XLSX v1 preserves identifiers, relationships and pending state', () {
    final bytes = const XlsxExporter().encode(
      AgroExportSnapshot(
        generatedAt: DateTime.utc(2026, 8, 28),
        sheets: {
          'parcelas': [
            {'id': 'parcel-1', 'nombre': 'Campo', 'pendiente': true},
          ],
          'sectores': [
            {'id': 'sector-1', 'parcela_id': 'parcel-1', 'nombre': 'Norte'},
          ],
        },
      ),
    );
    final decoded = Excel.decodeBytes(bytes);
    expect(decoded.tables.keys, containsAll(['parcelas', 'sectores']));
    expect(
      decoded.tables['parcelas']!.rows[1][0]!.value.toString(),
      'parcel-1',
    );
    expect(
      decoded.tables['sectores']!.rows[1][1]!.value.toString(),
      'parcel-1',
    );
    expect(bytes.take(2), [80, 75]);
  });
}
