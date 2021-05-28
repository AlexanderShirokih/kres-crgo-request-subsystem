import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/models/connection_point.dart';
import 'package:kres_requests2/domain/models/counter_info.dart';
import 'package:kres_requests2/domain/models/request_entity.dart';
import 'package:kres_requests2/domain/models/request_type.dart';
import 'package:kres_requests2/domain/repository/repository.dart';
import 'package:kres_requests2/domain/validator.dart';
import 'package:kres_requests2/screens/bloc.dart';
import 'package:meta/meta.dart';

part 'request_editor_events.dart';

/// Request editor data wrapper
class RequestEditorData extends Equatable {
  /// Current request entity to be shown
  final RequestEntity current;

  /// List of all available request types
  final List<RequestType> availableRequestTypes;

  /// List of year quarters. `null` value means quarter is unset
  final List<int?> availableCheckQuarters = const [null, 1, 2, 3, 4];

  @protected
  final Document document;

  @protected
  final Worksheet worksheet;

  /// Default constructor to create the state from [RequestEntity] instance
  const RequestEditorData({
    required this.availableRequestTypes,
    required this.current,
    required this.document,
    required this.worksheet,
  });

  @override
  List<Object?> get props => [
        current,
        availableRequestTypes,
        worksheet,
        document,
      ];
}

/// BLoC for editing [RequestEntity]
class RequestEditorBloc extends Bloc<RequestEditorEvent, BaseState> {
  /// Repository for fetching request types list
  final Repository<RequestType> requestTypeRepository;

  // Validator for checking fields completion in [RequestEntity]
  final Validator<RequestEntity> requestValidator;

  /// Creates new [RequestEditorBloc]
  RequestEditorBloc({
    required this.requestTypeRepository,
    required this.requestValidator,
  }) : super(InitialState());

  @override
  Stream<BaseState> mapEventToState(RequestEditorEvent event) async* {
    if (event is SetRequestEvent) {
      yield* _setCurrentRequest(event);
    } else if (event is SaveRequestEvent) {
      yield* _saveRequest(event);
    }
  }

  Stream<BaseState> _saveRequest(SaveRequestEvent event) async* {
    String _sanitize(String value) => value.replaceAll(RegExp(r"[\n\r]"), "");
    String? _sanitizeNotEmpty(String value) {
      final v = _sanitize(value);
      return v.isEmpty ? null : v;
    }

    CounterInfo? counterInfo;

    if (event.counterNumber.isNotEmpty && event.counterType.isNotEmpty) {
      counterInfo = CounterInfo(
        type: _sanitize(event.counterType),
        number: _sanitize(event.counterNumber),
        checkQuarter: event.checkQuarter,
        checkYear: event.checkYear.isNotEmpty
            ? int.tryParse(_sanitize(event.checkYear))
            : null,
      );
    }

    final currentState = state;
    if (currentState is DataState<RequestEditorData>) {
      final data = currentState.data;

      final tp = _sanitize(event.tp);
      final line = _sanitize(event.line);
      final pillar = _sanitize(event.pillar);

      final updatedRequest = data.current.rebuild(
        reason: data.current.reason,
        name: _sanitize(event.name),
        additionalInfo: _sanitizeNotEmpty(event.additionalInfo),
        address: _sanitize(event.address),
        phoneNumber: _sanitizeNotEmpty(event.phone),
        counter: counterInfo,
        accountId:
            event.accountId.isNotEmpty ? int.parse(event.accountId) : null,
        requestType: event.requestType,
        connectionPoint: ConnectionPoint(
          tp: _sanitizeNotEmpty(tp),
          line: _sanitizeNotEmpty(line),
          pillar: _sanitizeNotEmpty(pillar),
        ),
      );

      final errors = requestValidator.validate(updatedRequest).toList();

      if (errors.isNotEmpty) {
        // We have some errors in field completion
        final currentState = state;
        yield ErrorState(errors.join(', '));
        yield currentState;
      } else {
        final editor = data.document.worksheets.edit(data.worksheet);
        if (updatedRequest is _TemporaryRequestEntity) {
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

        yield CompletedState();
      }
    }
  }

  /// Sets currently edited request
  Stream<DataState> _setCurrentRequest(SetRequestEvent event) async* {
    final requestTypes = await _fetchRequestTypes(event.request?.requestType);

    yield DataState<RequestEditorData>(
      RequestEditorData(
        current: event.request ?? _buildInitial(),
        availableRequestTypes: requestTypes,
        worksheet: event.worksheet,
        document: event.document,
      ),
    );
  }

  /// Fetches available request types from the repository
  Future<List<RequestType>> _fetchRequestTypes(
    RequestType? currentRequestType,
  ) async {
    // Fetch available request types from the database
    final requestTypes = await requestTypeRepository.getAll();

    // Merge with the current value
    if (currentRequestType != null) {
      return (requestTypes.toSet()..add(currentRequestType))
          .toList(growable: false);
    }

    return requestTypes;
  }

  RequestEntity _buildInitial() => _TemporaryRequestEntity.empty();
}

class _TemporaryRequestEntity extends RequestEntity {
  const _TemporaryRequestEntity({
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

  const _TemporaryRequestEntity.empty()
      : super(
          name: "",
          address: "",
          additionalInfo: null,
          counter: null,
        );

  @override
  RequestEntity rebuild({
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
      _TemporaryRequestEntity(
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
