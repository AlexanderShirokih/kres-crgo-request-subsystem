import 'package:kres_requests2/domain/models.dart';

import '../repositories.dart';
import '../validator.dart';

/// Service for handling actions on [Request]
class RequestService {
  /// Repository for fetching request types list
  final Repository<RequestType> _requestTypeRepository;

  // Validator for checking fields completion in [RequestEntity]
  final Validator<Request> _requestValidator;

  final Document _document;

  const RequestService(
    this._requestTypeRepository,
    this._requestValidator,
    this._document,
  );

  /// Moves [requests] from [source] worksheet to [target] worksheet.
  /// If [removeFromSource] is `true` then [requests] will permanently moved
  /// to [target] worksheet, otherwise it will be *copied*.
  void moveRequests({
    required Worksheet? target,
    required Worksheet source,
    required bool removeFromSource,
    required List<Request> requests,
  }) {
    final sourceEditor = _document.worksheets.edit(source);
    final targetEditor = target == null
        ? _document.worksheets.add(name: source.name, activate: true)
        : _document.worksheets.edit(target);

    targetEditor.addAll(requests).commit();

    if (removeFromSource) {
      sourceEditor.removeRequests(requests).commit();
    }
  }

  /// Fetches available request types from the repository
  Future<List<RequestType>> fetchRequestTypes(
    RequestType? currentRequestType,
  ) async {
    // Fetch available request types from the database
    final requestTypes = await _requestTypeRepository.getAll();

    // Merge with the current value
    if (currentRequestType != null) {
      return (requestTypes.toSet()..add(currentRequestType))
          .toList(growable: false);
    }

    return requestTypes;
  }

  /// Creates temporary request with blank fields
  Request createTemporaryRequest() => _TemporaryRequest.empty();

  /// Validates current request and tries to save it
  /// Throws [ValidationError] if request fields has an error
  void saveRequest({
    required Request? current,
    required RawRequestInfo updatedInfo,
    required Document document,
    required Worksheet worksheet,
  }) {
    String _sanitize(String value) => value.replaceAll(RegExp(r"[\n\r]"), "");
    String? _sanitizeNotEmpty(String value) {
      final v = _sanitize(value);
      return v.isEmpty ? null : v;
    }

    CounterInfo? counterInfo;

    if (updatedInfo.counterNumber.isNotEmpty &&
        updatedInfo.counterType.isNotEmpty) {
      counterInfo = CounterInfo(
        type: _sanitize(updatedInfo.counterType),
        number: _sanitize(updatedInfo.counterNumber),
        checkQuarter: updatedInfo.checkQuarter,
        checkYear: updatedInfo.checkYear.isNotEmpty
            ? int.tryParse(_sanitize(updatedInfo.checkYear))
            : null,
      );
    }

    if (current != null) {
      final tp = _sanitize(updatedInfo.tp);
      final line = _sanitize(updatedInfo.line);
      final pillar = _sanitize(updatedInfo.pillar);

      final updatedRequest = current.rebuild(
        reason: current.reason,
        name: _sanitize(updatedInfo.name),
        additionalInfo: _sanitizeNotEmpty(updatedInfo.additionalInfo),
        address: _sanitize(updatedInfo.address),
        phoneNumber: _sanitizeNotEmpty(updatedInfo.phone),
        counter: counterInfo,
        accountId: updatedInfo.accountId.isNotEmpty
            ? int.parse(updatedInfo.accountId)
            : null,
        requestType: updatedInfo.requestType,
        connectionPoint: ConnectionPoint(
          tp: _sanitizeNotEmpty(tp),
          line: _sanitizeNotEmpty(line),
          pillar: _sanitizeNotEmpty(pillar),
        ),
      );

      // Will throw an exception if request has errors
      _requestValidator.ensureValid(updatedRequest);

      final editor = document.worksheets.edit(worksheet);
      if (updatedRequest is _TemporaryRequest) {
        // Newly created request
        editor.addRequest(
          accountId: updatedRequest.accountId,
          name: updatedRequest.name,
          connectionPoint: updatedRequest.connectionPoint,
          additionalInfo: updatedRequest.additionalInfo,
          requestType: updatedRequest.requestType,
          phoneNumber: updatedRequest.phoneNumber,
          counter: updatedRequest.counter,
          address: updatedRequest.address,
        );
      } else {
        // Updated request
        editor.update(updatedRequest);
      }

      editor.commit();
    }
  }

  /// Returns [Worksheet]s that can be used as target worksheets.
  /// Actually it's all worksheets except [sourceWorksheet] from the current
  /// document
  Iterable<Worksheet> getTargetWorksheets(Worksheet sourceWorksheet) =>
      _document.worksheets.list.where(
        (worksheet) => worksheet != sourceWorksheet,
      );
}

/// Interface that keeps raw field of request info
abstract class RawRequestInfo {
  /// Request type
  RequestType? get requestType;

  /// Account owner name
  String get name;

  /// Additional info, such as comments to the request
  String get additionalInfo;

  /// Request address
  String get address;

  /// Account ID
  String get accountId;

  /// Counter type
  String get counterType;

  /// Phone number
  String get phone;

  /// Counter number
  String get counterNumber;

  /// Check year
  String get checkYear;

  /// Transformation station number
  String get tp;

  /// Connection line number
  String get line;

  /// Endpoint pillar number
  String get pillar;

  /// Check quarter
  int? get checkQuarter;
}

class _TemporaryRequest extends Request {
  const _TemporaryRequest({
    required int? accountId,
    required String name,
    required ConnectionPoint? connectionPoint,
    required String? additionalInfo,
    required RequestType? requestType,
    required String? phoneNumber,
    required CounterInfo? counter,
    required String address,
    required String? reason,
  }) : super(
          accountId: accountId,
          address: address,
          additionalInfo: additionalInfo,
          counter: counter,
          name: name,
          reason: reason,
          phoneNumber: phoneNumber,
          requestType: requestType,
          connectionPoint: connectionPoint,
        );

  const _TemporaryRequest.empty()
      : super(
          name: "",
          address: "",
          additionalInfo: null,
          counter: null,
        );

  @override
  Request rebuild({
    required int? accountId,
    required String name,
    required ConnectionPoint? connectionPoint,
    required String? additionalInfo,
    required RequestType? requestType,
    required String? phoneNumber,
    required CounterInfo? counter,
    required String address,
    required String? reason,
  }) =>
      _TemporaryRequest(
        connectionPoint: connectionPoint,
        requestType: requestType,
        phoneNumber: phoneNumber,
        reason: reason,
        name: name,
        accountId: accountId,
        additionalInfo: additionalInfo,
        address: address,
        counter: counter,
      );
}
