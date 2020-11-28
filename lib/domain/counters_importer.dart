import 'dart:io';

import 'package:kres_requests2/models/request.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import 'package:kres_requests2/domain/importer_exception.dart';

typedef TableChooser = Future<String> Function(List<String>);

class NamedWorksheet {
  final String name;
  final List<Request> requests;

  const NamedWorksheet(this.name, this.requests);
}

class CountersImporter {
  static const _kDefaultRequestName = 'замена';

  const CountersImporter();

  Future<NamedWorksheet> importAsRequestsList(
      String filePath, TableChooser chooser) async {
    final bytes = await File(filePath).readAsBytes();
    final excel = SpreadsheetDecoder.decodeBytes(bytes);

    final chosenTableName =
        await chooser(excel.tables.keys.toList(growable: false));

    if (chosenTableName == null) return NamedWorksheet(null, <Request>[]);

    final table = excel.tables[chosenTableName];

    return NamedWorksheet(table.name ?? "NoName", _processRows(table.rows));
  }

  List<Request> _processRows(List<List<dynamic>> rows) {
    // 'B1' cell should contain account number if it is not a header line
    final hasHeader = !(rows.first[1] is int);

    return (hasHeader ? rows.skip(1) : rows)
        .where((row) =>
            row.fold(0, (acc, cell) => acc + (cell == null ? 1 : 0)) < 3)
        .map((row) {
      try {
        final rawName = row[2].toString();
        final phoneMarker = rawName.indexOf('тел.: ');
        final additional = row[6]?.toString();
        // TODO: Unimplemented
        if (true) throw UnimplementedError();
        // return Request();
        // reqType: _kDefaultRequestName,
        // fullReqType:
        //     _configRepository.getFullRequestName(_kDefaultRequestName),
        // accountId: row[1] as int,
        // name: phoneMarker < 0 ? rawName : rawName.substring(0, phoneMarker),
        // address: row[3].toString(),
        // counterInfo: '${row[5]} №${row[4]}',
        // additionalInfo: phoneMarker < 0
        //     ? additional ?? ''
        //     : [
        //         if (additional != null) additional,
        //         rawName.substring(phoneMarker)
        //       ].join(' | '),
        // );
      } catch (e) {
        throw ImporterException('Ошибка формата в строке: $row', e);
      }
    }).toList();
  }
}
