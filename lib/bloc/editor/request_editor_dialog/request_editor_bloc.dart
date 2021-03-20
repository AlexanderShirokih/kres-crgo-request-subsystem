import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/domain/controller/repository_controller.dart';
import 'package:kres_requests2/domain/models/request_type.dart';
import 'package:kres_requests2/domain/repository/repository.dart';
import 'package:kres_requests2/domain/validator.dart';
import 'package:kres_requests2/models/request_entity.dart';
import 'package:meta/meta.dart';

part 'request_editor_events.dart';
part 'request_editor_states.dart';

/// BLoC for editing [RequestEntity]
class RequestEditorBloc extends Bloc<RequestEditorEvent, RequestEditorState> {
  /// Repository for fetching request types list
  final Repository<RequestType> requestTypeRepository;

  // Repository controller for inserting or updating requests
  final AbstractRepositoryController<RequestEntity> requestController;

  // Validator for checking fields completion in [RequestEntity]
  final Validator<RequestEntity> requestValidator;

  /// Creates new [RequestEditorBloc] from existing [RequestEntity], if present
  RequestEditorBloc({
    required this.requestTypeRepository,
    required this.requestController,
    required this.requestValidator,
    RequestEntity? initialRequest,
  }) : super(
          RequestEditorShowDataState(
            current: initialRequest?.copy() ?? RequestEntity.empty(),
            availableRequestTypes: <RequestType>[],
          ),
        ) {
    add(_FetchRequestTypesEvent());
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
      yield RequestEditorShowDataState(
        availableRequestTypes: requestTypes,
        current: dataState.current,
      );
    }
  }

  // TODO: Handle possible errors
  Stream<RequestEditorState> _updateRequestFields(
      UpdateRequestFieldsEvent event) async* {
    String _sanitize(String value) => value.replaceAll(RegExp(r"[\n\r]"), "");

    if (state is RequestEditorShowDataState) {
      final dataState = state as RequestEditorShowDataState;
      final updatedRequest = dataState.current.copy(
        name: _sanitize(event.name),
        additionalInfo: _sanitize(event.additionalInfo),
        address: _sanitize(event.address),
        counterInfo: _sanitize(event.counterInfo),
        accountId:
            event.accountId.isNotEmpty ? int.parse(event.accountId) : null,
        requestType: event.requestType,
      );

      final errors = requestValidator.validate(updatedRequest).toList();

      if (errors.isEmpty) {
        // We have some errors in field completion
        yield RequestValidationErrorState(errors.first);
      } else {
        if (dataState.current.isNew) {
          // Newly created request
          requestController.add(updatedRequest);
        } else {
          // Updated request
          requestController.update(dataState.current, updatedRequest);
        }

        await requestController.commit();
        yield RequestEditingCompletedState();
      }
    }
  }
}
