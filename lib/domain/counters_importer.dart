import 'dart:io';

import 'package:kres_requests2/domain/importer_exception.dart';
import 'package:kres_requests2/domain/models/request_type.dart';
import 'package:kres_requests2/models/counter_info.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/request_entity.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import 'controller/worksheet_editor.dart';

typedef TableChooser = Future<String?> Function(List<String>);

class CountersImporter {
  const CountersImporter();

  Future<void> importAsRequestsList(
    String filePath,
    Document targetDocument,
    TableChooser chooser,
  ) async {
    final bytes = await File(filePath).readAsBytes();
    final excel = SpreadsheetDecoder.decodeBytes(bytes);

    final chosenTableName =
        await chooser(excel.tables.keys.toList(growable: false));

    if (chosenTableName == null) {
      return;
    }

    final table = excel.tables[chosenTableName];

    if (table == null) {
      throw 'No table found!';
    }

    final worksheet = targetDocument.addWorksheet(name: table.name);

    _processRows(worksheet, table.rows);
  }

  List<RequestEntity> _processRows(
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

        return targetWorksheet.addRequest(
          requestType: _kDefaultRequestType,
          accountId: row[1] as int,
          phoneNumber: phoneMarker < 0 ? null : rawName.substring(phoneMarker),
          name: phoneMarker < 0 ? rawName : rawName.substring(0, phoneMarker),
          address: row[3].toString(),
          counter: counterInfo,
          additionalInfo: additional,
        );
      } catch (e) {
        throw ImporterException('Error in the line: $row', e);
      }
    }).toList();
  }
}
