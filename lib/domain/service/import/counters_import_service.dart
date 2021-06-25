import 'dart:io';

import 'package:kres_requests2/domain/controller/worksheet_editor.dart';
import 'package:kres_requests2/domain/service/document_manager.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import '../../models.dart';
import '../import_exception.dart';
import 'document_import_service.dart';

typedef TableChooser = Future<String?> Function(List<String>);

/// Service responsible for importing requests from XLSX data
class CountersImportService implements DocumentImporter {
  /// Function for choosing the table from tables list
  final TableChooser tableChooser;

  const CountersImportService({
    required this.tableChooser,
  });

  @override
  Future<bool> importDocument(String filePath, DocumentManager manager) async {
    final document = await _importAsRequestsList(filePath, tableChooser);

    if (document == null || document.worksheets.isEmpty) {
      return false;
    }

    manager.addDocument(document);
    return true;
  }

  Future<Document?> _importAsRequestsList(
      String filePath, TableChooser chooser) async {
    final document = Document(updateDate: DateTime.now());

    final bytes = await File(filePath).readAsBytes();
    final excel = SpreadsheetDecoder.decodeBytes(bytes);

    final chosenTableName =
        await chooser(excel.tables.keys.toList(growable: false));

    if (chosenTableName == null) {
      return null;
    }

    final table = excel.tables[chosenTableName];

    if (table == null) {
      throw 'No table found!';
    }

    final worksheetList = document.worksheets;
    final worksheet = worksheetList.add(name: table.name);

    _processRows(worksheet, table.rows);
    worksheet.commit();

    return document;
  }

  _processRows(
    WorksheetEditor targetWorksheet,
    List<List<dynamic>> rows,
  ) {
    // 'B1' cell should contain account number if it is not a header line
    final hasHeader = !(rows.first[1] is int);

    return (hasHeader ? rows.skip(1) : rows)
        .where((row) =>
            row.fold(0, (acc, cell) => (acc as int) + (cell == null ? 1 : 0)) <
            3)
        .map((row) {
      try {
        final rawName = row[2].toString();
        final phoneMarker = rawName.indexOf('тел.: ');
        final additional = row[6]?.toString();

        final _kDefaultRequestType = const RequestType(
          shortName: 'замена',
          fullName: 'Замена по сроку',
        );

        final counterInfo = CounterInfo(
          type: row[5],
          number: row[4],
        );

        targetWorksheet.addRequest(
          requestType: _kDefaultRequestType,
          accountId: row[1],
          phoneNumber: phoneMarker < 0 ? null : rawName.substring(phoneMarker),
          name: phoneMarker < 0 ? rawName : rawName.substring(0, phoneMarker),
          address: row[3].toString(),
          counter: counterInfo,
          additionalInfo: additional,
        );
      } catch (e) {
        throw ImportException('Error in the line: $row', e);
      }
    }).toList();
  }
}
