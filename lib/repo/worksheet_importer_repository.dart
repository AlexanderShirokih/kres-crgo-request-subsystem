import 'package:kres_requests2/domain/counters_importer.dart';
import 'package:kres_requests2/domain/document_service.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/optional_data.dart';
import 'package:kres_requests2/models/request_set.dart';
import 'package:meta/meta.dart';

abstract class WorksheetImporterRepository {
  const WorksheetImporterRepository();

  /// Runs parser program and returns worksheets containing parsing result
  Future<OptionalData<DocumentService>> importDocument(
    String filePath,
    dynamic params,
  );
}

class CountersImporterRepository extends WorksheetImporterRepository {
  final CountersImporter importer;

  const CountersImporterRepository({
    @required this.importer,
  }) : assert(importer != null);

  @override
  Future<OptionalData<DocumentService>> importDocument(
      String filePath, dynamic tableChooser) {
    return _doImport(filePath, tableChooser as TableChooser)
        .then(
          (namedRequests) => namedRequests.requests.isEmpty
              ? null
              : [
                  RequestSet(
                    name: namedRequests.name,
                    requests: namedRequests.requests,
                  )
                ],
        )
        .then(
          (worksheets) => worksheets == null
              ? null
              // TODO:
              : throw UnimplementedError(), //OptionalData(data: DocumentService(worksheets: worksheets)),
        )
        .catchError((e, s) => OptionalData.ofError<Document>(e, s));
  }

  Future<NamedWorksheet> _doImport(
          String filePath, TableChooser tableChooser) =>
      importer.importAsRequestsList(filePath, tableChooser);
}
