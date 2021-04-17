import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/data/editor/request_entity.dart';
import 'package:kres_requests2/data/repository/request_repository.dart';
import 'package:kres_requests2/domain/controller/repository_controller.dart';
import 'package:kres_requests2/domain/controller/streamed_controller.dart';
import 'package:kres_requests2/domain/controller/worksheet_editor.dart';
import 'package:kres_requests2/domain/models/request_type.dart';
import 'package:kres_requests2/domain/repository/repository.dart';
import 'package:kres_requests2/domain/validator.dart';
import 'package:kres_requests2/models/connection_point.dart';
import 'package:kres_requests2/models/counter_info.dart';
import 'package:kres_requests2/models/request_entity.dart';
import 'package:meta/meta.dart';

part 'request_editor_events.dart';

part 'request_editor_states.dart';

/// BLoC for editing [RequestEntity]
class RequestEditorBloc extends Bloc<RequestEditorEvent, RequestEditorState> {
  /// Repository for fetching request types list
  final Repository<RequestType> requestTypeRepository;

  final WorksheetEditor worksheetEditor;

  // Repository controller for inserting or updating requests
  final AbstractRepositoryController<RequestEntity> _requestController;

  // Validator for checking fields completion in [RequestEntity]
  final Validator<RequestEntity> requestValidator;

  // The original request that will be edited
  final RequestEntity? initial;

  /// Creates new [RequestEditorBloc] from existing [RequestEntity], if present
  RequestEditorBloc({
    required this.requestTypeRepository,
    required this.initial,
    required WorksheetEditor worksheetEditor,
    required this.requestValidator,
  })   : worksheetEditor = worksheetEditor,
        _requestController = StreamedRepositoryController(
          RepositoryController(
            RequestEntityPersistedBuilder(),
            DocumentRequestEntityRepository(worksheetEditor),
          ),
        ),
        super(
          RequestEditorShowDataState(
            current: initial ?? worksheetEditor.addRequest(),
            availableRequestTypes: <RequestType>[],
          ),
        ) {
    add(_FetchRequestTypesEvent());
  }

  @override
  Future<void> close() async {
    // Remove empty request that we added at start (when initial == `null`)
    final current = state;
    if (current is RequestEditorShowDataState && current.current.isEmpty) {
      worksheetEditor.removeRequests([current.current]);
    }

    await super.close();
  }

  @override
  Stream<RequestEditorState> mapEventToState(RequestEditorEvent event) async* {
    if (event is _FetchRequestTypesEvent) {
      yield* _fetchRequestTypes();
    } else if (event is UpdateRequestFieldsEvent) {
      yield* _updateRequestFields(event);
    }
  }

  Stream<RequestEditorState> _fetchRequestTypes() async* {
    final requestTypes = await requestTypeRepository.getAll();
    if (state is RequestEditorShowDataState) {
      final dataState = state as RequestEditorShowDataState;

      var requestTypesSet = requestTypes.toSet();
      // Merge with the current value
      final currentRequestType = dataState.current.requestType;
      if (currentRequestType != null) {
        requestTypesSet.add(currentRequestType);
      }

      yield RequestEditorShowDataState(
        availableRequestTypes: requestTypesSet.toList(growable: false),
        current: dataState.current,
      );
    }
  }

  // TODO: Handle possible errors
  Stream<RequestEditorState> _updateRequestFields(
      UpdateRequestFieldsEvent event) async* {
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

    if (state is RequestEditorShowDataState) {
      final dataState = state as RequestEditorShowDataState;

      final tp = _sanitize(event.tp);
      final line = _sanitize(event.line);
      final pillar = _sanitize(event.pillar);

      final updatedRequestBuilder = dataState.current.rebuild()
        ..name = _sanitize(event.name)
        ..additionalInfo = _sanitizeNotEmpty(event.additionalInfo)
        ..address = _sanitize(event.address)
        ..phoneNumber = _sanitizeNotEmpty(event.phone)
        ..counter = counterInfo
        ..accountId =
            event.accountId.isNotEmpty ? int.parse(event.accountId) : null
        ..requestType = event.requestType
        ..connectionPoint = ConnectionPoint(
          tp: _sanitizeNotEmpty(tp),
          line: _sanitizeNotEmpty(line),
          pillar: _sanitizeNotEmpty(pillar),
        );

      final updatedRequest = updatedRequestBuilder.build();
      final errors = requestValidator.validate(updatedRequest).toList();

      if (errors.isNotEmpty) {
        // We have some errors in field completion
        yield RequestValidationErrorState(errors.join(', '));
      } else {
        if (dataState.current.isEmpty) {
          // Newly created request
          _requestController.add(updatedRequest);
        } else {
          // Updated request
          _requestController.update(dataState.current, updatedRequest);
        }

        await _requestController.commit();
        yield RequestEditingCompletedState();
      }
    }
  }
}
