import 'dart:convert';
import 'dart:isolate';

import 'package:agrocampo_backend/src/modules/export/infrastructure/export_snapshot.dart';
import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:xml/xml.dart';

final class XlsxExporter {
  const XlsxExporter();

  Future<List<int>> encodeOffMainIsolate(AgroExportSnapshot snapshot) =>
      Isolate.run(() => encode(snapshot));

  List<int> encode(AgroExportSnapshot snapshot) {
    final workbook = Excel.createExcel();
    for (final entry in snapshot.sheets.entries) {
      final sheet =
          workbook[entry.key.substring(0, entry.key.length.clamp(0, 31))];
      final columns =
          snapshot.columns[entry.key] ??
          entry.value.expand((row) => row.keys).toSet().toList();
      sheet.appendRow(columns.map(TextCellValue.new).toList());
      for (final row in entry.value) {
        final cells = columns
            .map((column) => _cell(column, row[column]))
            .toList();
        sheet.appendRow(cells);
        for (var index = 0; index < cells.length; index++) {
          if (cells[index] is DateTimeCellValue) {
            sheet
                .cell(
                  CellIndex.indexByColumnRow(
                    columnIndex: index,
                    rowIndex: sheet.maxRows - 1,
                  ),
                )
                .cellStyle = CellStyle(
              numberFormat: NumFormat.custom(
                formatCode: 'yyyy-mm-dd hh:mm:ss" UTC"',
              ),
            );
          }
        }
      }
    }
    if (snapshot.sheets.isNotEmpty && !snapshot.sheets.containsKey('Sheet1')) {
      workbook.setDefaultSheet(snapshot.sheets.keys.first);
      workbook.delete('Sheet1');
    }
    return _correctDimensions(
      workbook.encode() ?? (throw StateError('xlsx_encode_failed')),
    );
  }

  // excel 4.0.6 leaves worksheet dimensions at A1. Consumers that trust that
  // metadata can hide subsequent fields/rows; derive the extent from cells.
  List<int> _correctDimensions(List<int> bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final result = Archive();
    for (final file in archive.files) {
      if (!file.name.startsWith('xl/worksheets/sheet') ||
          !file.name.endsWith('.xml')) {
        result.addFile(file);
        continue;
      }
      final document = XmlDocument.parse(
        utf8.decode(file.content as List<int>),
      );
      var column = 0, row = 0;
      for (final cell in document.findAllElements('c')) {
        final index = CellIndex.indexByString(cell.getAttribute('r')!);
        if (index.columnIndex > column) column = index.columnIndex;
        if (index.rowIndex > row) row = index.rowIndex;
      }
      final last = CellIndex.indexByColumnRow(
        columnIndex: column,
        rowIndex: row,
      ).cellId;
      for (final dimension in document.findAllElements('dimension')) {
        dimension.setAttribute('ref', last == 'A1' ? 'A1' : 'A1:$last');
      }
      final content = utf8.encode(document.toXmlString());
      result.addFile(ArchiveFile(file.name, content.length, content));
    }
    return ZipEncoder().encode(result) ?? (throw StateError('xlsx_zip_failed'));
  }

  CellValue? _cell(String column, Object? value) {
    if (value == null) return null;
    if (value is bool) return BoolCellValue(value);
    if (value is int) return IntCellValue(value);
    if (value is num) return DoubleCellValue(value.toDouble());
    if (value is DateTime) return DateTimeCellValue.fromDateTime(value.toUtc());
    if (value is String && (column == 'fecha' || column == 'actualizado')) {
      final date = DateTime.tryParse(value);
      if (date != null) return DateTimeCellValue.fromDateTime(date.toUtc());
    }
    return TextCellValue(value.toString());
  }
}
