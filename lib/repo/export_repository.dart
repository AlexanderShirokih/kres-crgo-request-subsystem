import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/data/models/server_request.dart';
import 'package:kres_requests2/models/request_set.dart';
import 'package:kres_requests2/repo/api_repository.dart';

class ExportRepository with ApiRepositoryMixin {
  static const _kExport = 'export';

  final ApiServer _apiServer;

  ExportRepository(this._apiServer) : assert(_apiServer != null);

  /// Validates worksheets and returns a map of errors on it
  Future<Map<RequestSet, List<String>>> validateWorksheet(
      List<RequestSet> worksheets) async {
    assert(worksheets != null);

    final ids = worksheets.map((e) => e.id).join(',');

    final response = await _apiServer.getData(
      ServerRequest.get(
        '$_kExport/status',
        requestParams: {'ids': ids},
      ),
    );

    return getResponseData(
      response,
      (data) => (data as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          worksheets.singleWhere((element) => element.id == int.parse(key)),
          (value as List<dynamic>).cast<String>(),
        ),
      ),
    );
  }
}
