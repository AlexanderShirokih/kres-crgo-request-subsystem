import 'dart:convert';
import 'dart:io';

import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/editor/document_saver.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/models/document.dart';

/// Stores document to JSON format and saves it in the storage
class JsonDocumentSaver implements DocumentSaver {
  static const documentFormatVersion = 2;

  /// If `true` legacy fields will be stored (for backward compatibility
  /// with older versions)
  final bool saveLegacyInfo;

  const JsonDocumentSaver({required this.saveLegacyInfo});

  /// TODO: Implement file locking
  @override
  Future<void> store(Document document, [File? savePath]) async {
    final stored = _storeDocument(document);

    final json = await Future.microtask(() => jsonEncode(stored));

    final path = savePath ?? document.currentSavePath;
    if (path == null) {
      throw 'Save path is null';
    }

    await path.writeAsString(json);
  }

  Map<String, dynamic> _storeDocument(Document document) {
    final worksheets = document.currentWorksheets;
    return {
      'version': documentFormatVersion,
      'updateDate': document.currentUpdateDate.millisecondsSinceEpoch,
      'activeWorksheet': worksheets.indexOf(document.currentActive),
      'worksheets': worksheets.map(_storeWorksheet).toList()
    };
  }

  Map<String, dynamic> _storeWorksheet(Worksheet worksheet) {
    return {
      'name': worksheet.name,
      if (worksheet.mainEmployee != null)
        'mainEmployee': _storeEmployee(worksheet.mainEmployee!),
      if (worksheet.chiefEmployee != null)
        'chiefEmployee': _storeEmployee(worksheet.chiefEmployee!),
      'membersEmployee': worksheet.membersEmployee.map(_storeEmployee).toList(),
      'date': worksheet.targetDate?.millisecondsSinceEpoch,
      'requests': worksheet.requests.map(_storeRequest).toList(),
      'workTypes': worksheet.workTypes.toList(),
    };
  }

  Map<String, dynamic> _storeEmployee(Employee employee) => {
        'name': employee.name,
        if (saveLegacyInfo) 'position': employee.position.name,
        'position2': _storePosition(employee.position),
        'accessGroup': employee.accessGroup,
        if (employee is PersistedObject) 'id': (employee as PersistedObject).id,
      };

  Map<String, dynamic> _storePosition(Position position) => {
        if (position is PersistedObject) 'id': (position as PersistedObject).id,
        'name': position.name,
      };

  Map<String, dynamic> _storeRequest(RequestEntity request) => {
        'accountId': request.accountId,
        'name': request.name,
        'address': request.address,
        'phone': request.phoneNumber,
        if (request.connectionPoint != null)
          'connectionPoint': _storeConnectionPoint(request.connectionPoint!),
        if (saveLegacyInfo) 'reqType': request.requestType?.shortName,
        if (saveLegacyInfo) 'fullReqType': request.requestType?.fullName,
        if (request.requestType != null)
          'type': _storeRequestType(request.requestType!),
        'additionalInfo': request.additionalInfo,
        if (saveLegacyInfo) 'counterInfo': request.counter?.fullInfo,
        if (request.counter != null) 'counter': _storeCounter(request.counter!),
        if (request.reason != null) 'reason': request.reason,
      };

  Map<String, dynamic> _storeCounter(CounterInfo counter) => {
        'type': counter.type,
        'number': counter.number,
        if (counter.checkQuarter != null) 'quarter': counter.checkQuarter,
        if (counter.checkYear != null) 'year': counter.checkYear,
      };

  Map<String, dynamic> _storeRequestType(RequestType type) => {
        if (type is PersistedObject) 'id': (type as PersistedObject).id,
        'full': type.fullName,
        'short': type.shortName,
      };

  Map<String, dynamic> _storeConnectionPoint(ConnectionPoint point) => {
        if (point.tp != null) 'tp': point.tp,
        if (point.line != null) 'line': point.line,
        if (point.pillar != null) 'pillar': point.pillar,
      };
}
