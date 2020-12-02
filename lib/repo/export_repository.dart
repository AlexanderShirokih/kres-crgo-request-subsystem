import 'dart:io';
import 'dart:typed_data';

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

  /// Gets a list of available printers installed on server
  Future<List<String>> getAvailablePrinters() async {
    final response = await _apiServer.getData(
      ServerRequest.get('$_kExport/print'),
    );

    return getResponseData(
        response, (body) => (body as List<dynamic>).cast<String>());
  }

  /// Sends document to print on server printer
  Future<void> printWorksheets(
      List<RequestSet> worksheets, String printerName, bool noLists) async {
    final response = await _apiServer.getData(
      ServerRequest.get(
        '$_kExport/print/$printerName',
        requestParams: {
          'ids': _joinWorksheets(worksheets),
          'noLists': noLists,
        },
      ),
    );

    ensureOk(response);
  }

  /// Runs exporter for list and then downloads final document and saves it
  /// to the `savePath`
  Future<void> exportToPdf(List<RequestSet> worksheets, String savePath) =>
      _downloadExportedFile('pdf', worksheets, savePath);

  /// Runs exporter for list and then downloads final document and saves it
  /// to the `savePath`
  Future<void> exportToXlsx(List<RequestSet> worksheets, String savePath) =>
      _downloadExportedFile('xlsx', worksheets, savePath);

  Future<void> _downloadExportedFile(
      String exportType, List<RequestSet> worksheets, String savePath) async {
    final response = await _apiServer.getData(
      ServerRequest.get(
        '$_kExport/$exportType',
        requestParams: {'ids': _joinWorksheets(worksheets)},
      ),
    );

    Uint8List bytes = getResponseData(response, (body) => body as Uint8List);

    await File(savePath).writeAsBytes(bytes);
  }

  String _joinWorksheets(List<RequestSet> worksheets) {
    assert(worksheets != null);
    return worksheets.map((e) => e.id).join(',');
  }
}
