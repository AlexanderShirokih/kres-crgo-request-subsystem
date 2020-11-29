import 'package:intl/intl.dart';
import 'package:kres_requests2/domain/request_set_service.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/request.dart';
import 'package:kres_requests2/models/request_set.dart';
import 'package:kres_requests2/repo/request_set_repository.dart';
import 'package:kres_requests2/repo/server_exception.dart';

/// Encapsulates logic of editing document
class DocumentService {
  final RequestsSetRepository _requestsSetRepository;

  final Document _document;

  final Map<RequestSet, List<Request>> filtered = {};

  final Map<RequestSet, RequestSetService> _serviceCache = {};

  /// Creates document with single `RequestSet`
  DocumentService(this._requestsSetRepository, this._document)
      : assert(_requestsSetRepository != null),
        assert(_document != null);

  /// Returns `true` is all worksheets are empty
  bool get isEmpty => _document.isEmpty;

  /// Adds new worksheet to the document with optional [name]
  /// If name is not passed default name will be generated
  /// If `makeActive` is `true` then newly created worksheet will be activated.
  Future<bool> addNewWorksheet(
      [String name, bool makeActive = false, DateTime targetDate]) async {
    if (targetDate == null) {
      targetDate = _document.requestSets.first.date;
    }
    if (name == null) {
      final formattedDate = DateFormat('dd.MM.yyyy').format(targetDate);
      name = _getUniqueName('Заявки на $formattedDate');
    }

    try {
      final requestSet = await _requestsSetRepository.createOrUpdateRequestSet(
          name, targetDate);
      _document.addWorksheet(requestSet);
      if (makeActive) {
        setActive(requestSet);
      }
    } on ApiException {
      return false;
    }
    return true;
  }

  String _getUniqueName(String name) {
    name ??= "Лист ${getWorksheets().length + 1}";
    String worksheetName;
    var attempt = 0;
    do {
      worksheetName = "$name${attempt > 0 ? "($attempt)" : ""}";
      attempt++;
    } while (getWorksheets().any((w) => w.name == worksheetName));
    return worksheetName;
  }

  /// Removes worksheet from the document
  Future<bool> removeWorksheet(RequestSet targetRequestSet) async {
    try {
      await _requestsSetRepository.removeWorksheet(targetRequestSet);
      _serviceCache.remove(targetRequestSet);
      _document.removeWorksheet(targetRequestSet);
      return true;
    } on ApiException {
      return false;
    }
  }

  /// Returns currently active worksheet
  RequestSet getActive() => _document.active;

  /// Makes `requestSet` active
  void setActive(RequestSet requestSet) {
    _document.active = requestSet;
  }

  Map<RequestSet, List<Request>> filterRequests(String searchText) {
    if (searchText == null || searchText.isEmpty)
      return <RequestSet, List<Request>>{};
    searchText = searchText.toLowerCase();

    return Map.fromIterable(_document.requestSets,
        key: (worksheet) => worksheet,
        value: (worksheet) => worksheet.requests.where((Request request) {
              return (request.accountInfo.baseId?.toString()?.padLeft(6, '0') ??
                          '')
                      .contains(searchText) ||
                  request.accountInfo.name.toLowerCase().contains(searchText) ||
                  (request?.accountInfo
                          ?.joinAddress()
                          ?.toLowerCase()
                          ?.contains(searchText) ??
                      false) ||
                  (request?.countingPoint
                          ?.joinToString()
                          ?.toLowerCase()
                          ?.contains(searchText) ??
                      false) ||
                  request.additional.toLowerCase().contains(searchText);
            }).toList());
  }

  RequestSetService _gerOrCreateRequestService(RequestSet set) {
    var cached = _serviceCache[set];
    if (cached == null) {
      cached = RequestSetService(_requestsSetRepository, set);
      _serviceCache[set] = cached;
    }
    return cached;
  }

  /// Gets current worksheet for editing
  RequestSetService getEditor(RequestSet requestSet) {
    return _gerOrCreateRequestService(requestSet);
  }

  /// Gets current worksheet for editing
  RequestSetService getEditableWorksheet() {
    return _gerOrCreateRequestService(getActive());
  }

  /// Gets all worksheets which are not empty
  List<RequestSetService> getEditableWorksheets() =>
      _document.requestSets.map((e) => _gerOrCreateRequestService(e)).toList();

  /// Gets read-only list of worksheets
  List<RequestSet> getWorksheets() => List.unmodifiable(_document.requestSets);

  /// Moves `source` requests from `targetWorksheet`. Note that the requests will
  /// be removed from worksheet on which they contained.
  ///
  Future moveRequests(RequestSet targetWorksheet, Set<Request> source) {
    //   targetWorksheet.requests.addAll(_movingRequests);
    //     if (_moveMethod == MoveMethod.Move)
    //       for (RequestEntity e in _movingRequests)
    //         _sourceWorksheet.requests.remove(e);
    throw UnimplementedError();
  }
}
