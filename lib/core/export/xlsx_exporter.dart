import 'dart:isolate';

import 'package:agrocampo/core/export/export_snapshot.dart';
import 'package:excel/excel.dart';

final class XlsxExporter {
  const XlsxExporter();

  Future<List<int>> encodeOffMainIsolate(AgroExportSnapshot snapshot) =>
      Isolate.run(() => encode(snapshot));

  List<int> encode(AgroExportSnapshot snapshot) {
    final workbook = Excel.createExcel();
    workbook.delete('Sheet1');
    for (final entry in snapshot.sheets.entries) {
      final sheet =
          workbook[entry.key.substring(0, entry.key.length.clamp(0, 31))];
      final columns = entry.value.expand((row) => row.keys).toSet().toList();
      sheet.appendRow(columns.map(TextCellValue.new).toList());
      for (final row in entry.value) {
        sheet.appendRow(
          columns
              .map((column) => TextCellValue(row[column]?.toString() ?? ''))
              .toList(),
        );
      }
    }
    return workbook.encode() ?? (throw StateError('xlsx_encode_failed'));
  }
}
