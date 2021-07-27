import 'package:kres_requests2/domain/models/document.dart';
import 'package:kres_requests2/domain/models/request_entity.dart';
import 'package:kres_requests2/domain/models/worksheet.dart';
import 'package:rxdart/rxdart.dart';

/// Class that responsible for filtering requests that matches search criteria
class DocumentFilter {
  final Document _document;

  /// Creates new [DocumentFilter] from existing document
  DocumentFilter(this._document);

  final BehaviorSubject<String> _searchingText = BehaviorSubject.seeded('');

  void setSearchingTest(String searchingText) {
    _searchingText.add(searchingText);
  }

  Stream<Map<Worksheet, List<Request>>> get filteredRequests =>
      Rx.combineLatest2(
        _searchingText,
        _document.worksheets.stream,
        _filterRequests,
      );

  Map<Worksheet, List<Request>> _filterRequests(
      String searchText, List<Worksheet> ws) {
    if (searchText.isEmpty) {
      return <Worksheet, List<Request>>{};
    }

    searchText = searchText.toLowerCase();

    return Map.fromIterable(ws,
        key: (worksheet) => worksheet,
        value: (worksheet) => worksheet.requests.where((Request request) {
              return (request.printableAccountId.contains(searchText) ||
                  request.name.toLowerCase().contains(searchText) ||
                  request.address.toLowerCase().contains(searchText) ||
                  (request.counter?.mainInfo
                          .toLowerCase()
                          .contains(searchText) ??
                      false) ||
                  (request.additionalInfo?.toLowerCase().contains(searchText) ??
                      false));
            }).toList());
  }

  /// Closes internal resources
  Future<void> close() => _searchingText.close();
}
