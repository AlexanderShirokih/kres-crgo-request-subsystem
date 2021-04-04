import 'dart:io';

import 'package:kres_requests2/data/models.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/models/connection_point.dart';
import 'package:kres_requests2/models/counter_info.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/request_entity.dart';
import 'package:kres_requests2/models/worksheet.dart';

/// Factory class for building [Document] instances
abstract class DocumentFactory {
  Document createDocument();
}

/// Builds [Document]  instances from JSON data
class JsonDocumentFactory implements DocumentFactory {
  final Map<String, dynamic> _data;
  final File? savePath;

  const JsonDocumentFactory(this._data, this.savePath);

  @override
  Document createDocument() {
    final List<Worksheet> worksheets = (_data['worksheets'] as List<dynamic>)
        .map((w) => _createWorksheet(w))
        .toList();

    var activeWorksheetIdx = _data['activeWorksheet'] ?? 0;

    if (activeWorksheetIdx >= worksheets.length) {
      activeWorksheetIdx = 0;
    }

    return Document(
      savePath: savePath,
      updateDate: DateTime.fromMillisecondsSinceEpoch(_data['updateDate']),
    )
      ..setWorksheets(worksheets)
      ..makeActive(worksheets[activeWorksheetIdx]);
  }

  Worksheet _createWorksheet(Map<String, dynamic> ws) {
    return Worksheet(
      worksheetId: 0,
      name: ws['name'] as String,
      mainEmployee: ws['mainEmployee'] == null
          ? null
          : _createEmployee(ws['mainEmployee']),
      chiefEmployee: ws['chiefEmployee'] == null
          ? null
          : _createEmployee(ws['chiefEmployee']),
      membersEmployee: (ws['membersEmployee'] as List<dynamic>)
          .map((e) => _createEmployee(e))
          .take(6)
          .toList(),
      requests: (ws['requests'] as List<dynamic>)
          .map((r) => _createRequestEntity(r))
          .toList(),
      targetDate: ws['date'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(ws['date']),
      workTypes: (ws['workTypes'] as List<dynamic>).cast<String>().toSet(),
    );
  }

  Employee _createEmployee(Map<String, dynamic> e) {
    final employee = Employee(
      name: e['name'],
      accessGroup: e['accessGroup'],
      position: _createPosition(e['position']),
    );

    if (e['id'] != null) {
      // TODO: Fetch employee from repository
      return EmployeePersistedBuilder().build(e['id'], employee);
    }

    return employee;
  }

  Position _createPosition(dynamic p) {
    if (p is String) {
      return Position(name: p);
    }

    // TODO: Implement real instances loading with backward compatibility
    throw UnimplementedError();
    // final map = p as Map<String, dynamic>;
    // if (map['id'] != null) {
    //   // TODO: Fetch position from repository
    //   return PositionPersistedBuilder().build(map['id'], map['name]);
    // }
  }

  RequestEntity _createRequestEntity(Map<String, dynamic> data) {
    final int? accountId = data['accountId'];
    final String name = data['name'];
    final String address = data['address'];
    final String? reason = data['reason'];
    String? additional = data['additionalInfo'];
    String? phone;
    ConnectionPoint? connectionPoint;

    // TODO: Load new (split) counterInfo
    final CounterInfo? counter = _splitCounterInfo(data['counterInfo']);

    if (additional != null) {
      final tpRegExp = RegExp(r'ТП[\:\.\s]*([\dТРП\\\/]{1,6})');
      final String? tp = tpRegExp.firstMatch(additional)?.group(1);
      additional = additional.replaceAll(tpRegExp, '');

      final lineRegExp = RegExp(r'Ф[\:\s\.]*([\\\/\d]{1,3})');
      final String? line = lineRegExp.firstMatch(additional)?.group(1);
      additional = additional.replaceAll(lineRegExp, '');

      final pillarRegExp = RegExp(r'(оп|опора|Опора)[\:\.\s]*([\\\/\d]{1,5})');
      final String? pillar = pillarRegExp.firstMatch(additional)?.group(2);
      additional = additional.replaceAll(pillarRegExp, '');
      connectionPoint = ConnectionPoint(tp: tp, line: line, pillar: pillar);

      final phoneRegExp = RegExp(r'\+?[\d\-\(\)]{6,}');
      phone = phoneRegExp.firstMatch(additional)?.group(0);
      additional = additional.replaceAll(phoneRegExp, '');
      additional = additional.replaceAll(RegExp(r'(тел\.\:|\|)'), '').trim();
    }

    final requestEntity = RequestEntity(
      accountId: accountId,
      name: name,
      address: address,
      reason: reason,
      counter: counter,
      phoneNumber: phone,
      connectionPoint: connectionPoint,
      additionalInfo: additional,
      // TODO: Hook up RequestTypeEntities
      requestType: RequestType(
        shortName: data['reqType'],
        fullName: data['fullReqType'],
      ),
    );

    return requestEntity;
  }

  // Splits counter info from single line into [CounterInfo] class
  // Line examples:
  // 1) № 4756383 Hik2102-04.М2В| п. III-12
  // 2) 5СМ4  №1644748
  // 3) №011073151064584  ЦЭ6803 В
  // 4) ПУ отсутств.
  CounterInfo? _splitCounterInfo(String info) {
    final numberRegExp = RegExp(r'№\s*(\d{5,})');
    final numberMatch = numberRegExp.firstMatch(info);
    final number = numberMatch?.group(1);

    if (number == null) {
      return null;
    }

    info = info.replaceAll(numberRegExp, '');

    int? checkQuarter;
    int? checkYear;

    final checkingRegExp = RegExp(r'п\.\s*([IV]{1,3})\-(\d{1,2})');
    final checkingMatch = checkingRegExp.firstMatch(info);
    if (checkingMatch != null) {
      checkQuarter = _translateGroup(checkingMatch.group(1) ?? '');
      checkYear = int.tryParse(checkingMatch.group(2) ?? '');
      if (checkYear != null) {
        if (checkYear < 80) {
          checkYear += 2000;
        } else {
          checkYear += 1900;
        }
      }
    }

    info = info.replaceAll(checkingRegExp, '');
    info = info.replaceAll('|', '').replaceAll(',', '');

    return CounterInfo(
      type: info.trim(),
      number: number,
      checkQuarter: checkQuarter,
      checkYear: checkYear,
    );
  }

  int? _translateGroup(String group) {
    switch (group) {
      case 'I':
        return 1;
      case 'II':
        return 2;
      case 'III':
        return 3;
      case 'IV':
      case 'VI': // Legacy bug from old versions
        return 4;
      default:
        return null;
    }
  }
}
