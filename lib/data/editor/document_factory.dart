import 'dart:io';

import 'package:kres_requests2/data/models.dart';
import 'package:kres_requests2/domain/models.dart';
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
      worksheets: worksheets,
      updateDate: DateTime.fromMillisecondsSinceEpoch(_data['updateDate']),
    )..makeActive(worksheets[activeWorksheetIdx]);
  }

  Worksheet _createWorksheet(Map<String, dynamic> ws) {
    return Worksheet(
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
      date: ws['date'] == null
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

    // TODO: Implement real instances loading with backward compability
    throw UnimplementedError();
    // final map = p as Map<String, dynamic>;
    // if (map['id'] != null) {
    //   // TODO: Fetch position from repository
    //   return PositionPersistedBuilder().build(map['id'], map['name]);
    // }
  }

  // TODO: Disallow creating instances from model's factory
  RequestEntity _createRequestEntity(Map<String, dynamic> r) =>
      RequestEntity.fromJson(r);
}
