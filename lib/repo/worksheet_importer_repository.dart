import 'dart:convert';
import 'dart:io';

import 'package:kres_requests2/domain/counters_importer.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/optional_data.dart';
import 'package:kres_requests2/models/worksheet.dart';

abstract class WorksheetImporterRepository {
  const WorksheetImporterRepository();

  /// Runs parser program and returns worksheets containing parsing result
  Future<OptionalData<Document>?> importDocument(
    String filePath,
    dynamic params,
  );
}

class CountersImporterRepository extends WorksheetImporterRepository {
  final CountersImporter importer;

  const CountersImporterRepository({
    required this.importer,
  });

  @override
  Future<OptionalData<Document>?> importDocument(
      String filePath, dynamic tableChooser) {
    return _doImport(filePath, tableChooser as TableChooser)
        .then(
          (namedRequests) => namedRequests.requests.isEmpty
              ? null
              : [
                  Worksheet(
                    name: namedRequests.name,
                    requests: namedRequests.requests,
                  )
                ],
        )
        .then(
          (worksheets) => worksheets == null
              ? null
              : OptionalData(data: Document(worksheets: worksheets)),
        )
        .catchError((e, s) => OptionalData.ofError<Document>(e, s));
  }

  Future<NamedWorksheet> _doImport(
          String filePath, TableChooser tableChooser) =>
      importer.importAsRequestsList(filePath, tableChooser);
}

typedef MultiTableChooser = Future<List<Worksheet>> Function(List<Worksheet>);

class NativeImporterRepository extends WorksheetImporterRepository {
  const NativeImporterRepository();

  @override
  Future<OptionalData<Document>?> importDocument(
          String filePath, dynamic tableChooser) =>
      File(filePath)
          .readAsString()
          .then((content) => jsonDecode(content))
          .then((json) => Document.fromJson(json))
          .then((Document document) async {
        if (tableChooser == null)
          return OptionalData<Document>(data: document);
        else
          return await _chooseWorksheets(
              document, tableChooser as MultiTableChooser);
      }).then((optDocument) {
        if (!optDocument!.hasError())
          optDocument.data?.savePath = File(filePath);
        return optDocument;
      }).catchError((e, s) => OptionalData.ofError<Document>(e, s));

  Future<OptionalData<Document>?> _chooseWorksheets(
          Document document, MultiTableChooser tableChooser) =>
      _chooseWorksheets0(document, tableChooser).then(
        (worksheets) => worksheets.isEmpty
            ? null
            : OptionalData<Document>(data: document.setWorksheets(worksheets)),
      );

  Future<List<Worksheet>> _chooseWorksheets0(
      Document document, MultiTableChooser tableChooser) {
    return document.worksheets.length == 1
        ? Future.value(document.worksheets)
        : tableChooser(document.worksheets);
  }
}
