import 'dart:io';

import 'package:kres_requests2/data/models.dart';
import 'package:kres_requests2/domain/controller/worksheet_editor.dart';
import 'package:kres_requests2/domain/editor/decoding_pipeline.dart';
import 'package:kres_requests2/domain/editor/document_factory.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/models/worksheets_list.dart';

/// Builds [Document] instances from JSON data
class JsonDocumentFactory implements DocumentFactory {
  final Map<String, dynamic> _data;
  final File? savePath;
  final DecodingPipeline pipeline;

  JsonDocumentFactory(
    this._data, {
    this.pipeline = const DecodingPipeline(),
    this.savePath,
  });

  @override
  Future<Document> createDocument() async {
    final document = Document(
      savePath: savePath,
      updateDate: _data['updateDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(_data['updateDate'])
          : DateTime.now(),
    );

    for (final worksheet in (_data['worksheets'] as List<dynamic>)) {
      await _createWorksheet(document.worksheets, worksheet);
    }

    var activeWorksheetIdx = _data['activeWorksheet'] ?? 0;

    final worksheets = document.worksheets.list;
    final worksheetsCount = worksheets.length;

    if (activeWorksheetIdx >= worksheetsCount) {
      activeWorksheetIdx = 0;
    }

    document.worksheets.makeActive(worksheets[activeWorksheetIdx]);
    return document;
  }

  Future<void> _createWorksheet(
      WorksheetsList worksheets, Map<String, dynamic> ws) async {
    final worksheet = worksheets.add(
      name: ws['name'],
      mainEmployee: ws['mainEmployee'] == null
          ? null
          : _createEmployee(ws['mainEmployee']),
      chiefEmployee: ws['chiefEmployee'] == null
          ? null
          : _createEmployee(ws['chiefEmployee']),
      membersEmployee: ws['membersEmployee'] == null
          ? {}
          : (ws['membersEmployee'] as List<dynamic>)
              .map((e) => _createEmployee(e))
              .toSet(),
      targetDate: ws['date'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(ws['date']),
      workTypes: ws['workTypes'] == null
          ? null
          : (ws['workTypes'] as List<dynamic>).cast<String>().toSet(),
    );

    for (final request in (ws['requests'] as List<dynamic>)) {
      await _createRequestEntity(worksheet, request);
    }

    worksheet.commit();
  }

  Future<void> _createRequestEntity(
      WorksheetEditor editor, Map<String, dynamic> data) async {
    final int? accountId = data['accountId'];
    final String name = data['name'];
    final String address = data['address'];
    final String? reason = data['reason'];
    String? additional = data['additionalInfo'];
    String? phone;
    ConnectionPoint? connectionPoint;

    final counter = data['counter'] != null
        ? _createCounter(data['counter'])
        : _splitCounterInfo(data['counterInfo']);

    if (additional != null) {
      final tpRegExp = RegExp(r'ТП[\:\.\s]*([\dТРП\\\/]{1,6})');
      final String? tp = tpRegExp.firstMatch(additional)?.group(1)?.trim();
      additional = additional.replaceAll(tpRegExp, '');

      final lineRegExp = RegExp(r'Ф[\:\s\.]{0,2}([\\\/\d]{1,3})');
      final String? line = lineRegExp.firstMatch(additional)?.group(1)?.trim();
      additional = additional.replaceAll(lineRegExp, '');

      final pillarRegExp = RegExp(
          r'(оп|опора|Опора)[\:\.\s]{0,2}(\d{1,3}([\\\/][\dА-я]{1,2})?)');

      final String? pillar =
          pillarRegExp.firstMatch(additional)?.group(2)?.trim();
      additional = additional.replaceAll(pillarRegExp, '');
      connectionPoint = ConnectionPoint(tp: tp, line: line, pillar: pillar);

      final phoneRegExp = RegExp(r'\+?[\d\-\(\)]{6,}');
      phone = phoneRegExp.firstMatch(additional)?.group(0);
      additional = additional.replaceAll(phoneRegExp, '');
      additional = additional.replaceAll(RegExp(r'(тел\.\:|\|)'), '').trim();
    }

    final rawRequestType = data['type'] != null
        ? _createRequestType(data['type'])
        : RequestType(
            shortName: data['reqType'],
            fullName: data['fullReqType'] ?? data['reqType'],
          );

    final requestType = await pipeline.processRequestType(rawRequestType);

    if (data['phone'] != null) {
      phone = data['phone'];
    }

    if (data['connectionPoint'] != null) {
      connectionPoint = _createConnectionPoint(data['connectionPoint']);
    }

    editor.addRequest(
      accountId: accountId,
      name: name,
      address: address,
      reason: reason,
      counter: counter,
      phoneNumber: phone,
      connectionPoint: connectionPoint,
      additionalInfo: additional,
      requestType: requestType,
    );
  }

  Employee _createEmployee(Map<String, dynamic> e) {
    final employee = Employee(
      name: e['name'],
      accessGroup: e['accessGroup'],
      position: e['position2'] == null
          ? Position(name: e['position'])
          : _createPosition(e['position2']),
    );

    if (e['id'] != null) {
      return const EmployeePersistedBuilder().build(e['id'], employee);
    }

    return employee;
  }

  Position _createPosition(Map<String, dynamic> map) {
    final position = Position(name: map['name']);
    if (map['id'] != null) {
      return const PositionPersistedBuilder().build(map['id'], position);
    }
    return position;
  }

  ConnectionPoint _createConnectionPoint(Map<String, dynamic> map) {
    return ConnectionPoint(
      tp: map['tp'],
      line: map['line'],
      pillar: map['pillar'],
    );
  }

  // Splits counter info from single line into [CounterInfo] class
  // Line examples:
  // 1) № 4756383 Hik2102-04.М2В| п. III-12
  // 2) 5СМ4  №1644748
  // 3) №011073151064584  ЦЭ6803 В
  // 4) ПУ отсутств.
  CounterInfo? _splitCounterInfo(String? info) {
    if (info == null) {
      return null;
    }

    final numberRegExp = RegExp(r'№?\s*(\d{5,})');
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

  RequestType _createRequestType(Map<String, dynamic> data) {
    final requestType = RequestType(
      shortName: data['short'],
      fullName: data['full'],
    );

    if (data['id'] != null) {
      return const RequestTypePersistedBuilder().build(data['id'], requestType);
    }

    return requestType;
  }

  CounterInfo _createCounter(Map<String, dynamic> data) {
    return CounterInfo(
      type: data['type'],
      number: data['number'],
      checkYear: data['year'],
      checkQuarter: data['quarter'],
    );
  }
}
