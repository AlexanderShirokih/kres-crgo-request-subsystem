import 'package:equatable/equatable.dart';
import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/models/request_type.dart';
import 'package:kres_requests2/models/connection_point.dart';
import 'package:kres_requests2/models/counter_info.dart';
import 'package:kres_requests2/models/request_entity.dart';
import 'package:kres_requests2/models/worksheet.dart';
import 'package:rxdart/rxdart.dart';

/// Controls editing of worksheet properties
class WorksheetEditor extends Equatable {
  final BehaviorSubject<Worksheet> _worksheet;

  /// Current readonly state
  Worksheet get current => _worksheet.requireValue;

  WorksheetEditor(Worksheet initialWorksheet)
      : _worksheet = BehaviorSubject.seeded(initialWorksheet);

  /// Returns worksheet actual state stream
  Stream<Worksheet> get actualState => _worksheet;

  // Closes internal streams
  Future<void> close() => _worksheet.close();

  /// Swaps request positions in the worksheet
  void swapRequests(RequestEntity from, RequestEntity to) {
    if (from == to) {
      return;
    }

    final requests = current.requests;

    final idx = requests.indexOf(to);
    requests.remove(from);
    requests.insert(idx, from);

    _worksheet.add(current.copy(requests: requests));
  }

  /// Updates current worksheet name
  void setName(String text) => _worksheet.add(current.copy(name: text));

  /// Updates currently existing request
  void update(RequestEntity entity) {
    final currentRequests = current.requests;

    final persisted = entity as PersistedObject;

    final oldEntityId = currentRequests
        .cast<PersistedObject>()
        .indexWhere((request) => request.id == persisted.id);

    if (oldEntityId == -1) {
      throw 'Request with ID: ${persisted.id} is not found in the worksheet';
    }

    currentRequests[oldEntityId] = entity;

    _worksheet.add(current.copy(requests: currentRequests));
  }

  /// Removes requests from the worksheet
  void removeRequests(List<RequestEntity> requests) {
    final currentRequests = current.requests;

    for (final toRemove in requests) {
      currentRequests.remove(toRemove);
    }

    _worksheet.add(current.copy(requests: List.of(currentRequests)));
  }

  /// Adds all requests to the worksheet
  void addAll(List<RequestEntity> requests) {
    _worksheet.add(
      current.copy(
        requests: List.of(current.requests + requests),
      ),
    );
  }

  @override
  List<Object?> get props => [current];

  /// Creates new empty request
  RequestEntity addRequest({
    int? accountId,
    String? name,
    String? reason,
    String? address,
    CounterInfo? counter,
    ConnectionPoint? connectionPoint,
    String? phoneNumber,
    String? additionalInfo,
    RequestType? requestType,
  }) {
    final request = current.createRequestEntity(
      name: name,
      reason: reason,
      address: address,
      counter: counter,
      accountId: accountId,
      phoneNumber: phoneNumber,
      requestType: requestType,
      additionalInfo: additionalInfo,
      connectionPoint: connectionPoint,
    );
    addAll([request]);
    return request;
  }
}
