import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/domain/models/request_entity.dart';
import 'package:kres_requests2/domain/models/worksheet.dart';
import 'package:kres_requests2/domain/models/worksheets_list.dart';
import 'package:rxdart/rxdart.dart';

/// Class that responsible for filtering requests that matches search criteria
class DocumentFilter implements Disposable {
  final BehaviorSubject<String> _searchText = BehaviorSubject.seeded('');

  void setSearchText(String searchText) {
    _searchText.add(searchText);
  }

  Stream<Map<Worksheet, List<Request>>> filterRequests(
    WorksheetsList worksheets,
  ) =>
      Rx.combineLatest2(
        _searchText.distinct(),
        worksheets.stream,
        _filterRequests,
      );

  Map<Worksheet, List<Request>> _filterRequests(
      String searchText, List<Worksheet> ws) {
    if (searchText.isEmpty) {
      return const {};
    }

    searchText = searchText.toLowerCase();

    return {
      for (var worksheet in ws)
        worksheet: worksheet.requests.where((Request request) {
          return (request.printableAccountId.contains(searchText) ||
              request.name.toLowerCase().contains(searchText) ||
              request.address.toLowerCase().contains(searchText) ||
              (request.counter?.mainInfo.toLowerCase().contains(searchText) ??
                  false) ||
              (request.additionalInfo?.toLowerCase().contains(searchText) ??
                  false));
        }).toList()
    };
  }

  /// Closes internal resources
  @override
  void dispose() {
    _searchText.close();
  }
}
