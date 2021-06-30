import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/service/request_service.dart';
import 'package:kres_requests2/screens/bloc.dart';
import 'package:meta/meta.dart';

part 'request_editor_events.dart';

/// Request editor data wrapper
class RequestEditorData extends Equatable {
  /// Current request entity to be shown
  final Request current;

  /// List of all available request types
  final List<RequestType> availableRequestTypes;

  /// List of year quarters. `null` value means quarter is unset
  final List<int?> availableCheckQuarters = const [null, 1, 2, 3, 4];

  @protected
  final Document document;

  @protected
  final Worksheet worksheet;

  /// Default constructor to create the state from [Request] instance
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

/// BLoC for editing [Request]
class RequestEditorBloc extends Bloc<RequestEditorEvent, BaseState> {
  /// Service for handling actions on [Request]
  final RequestService service;

  /// Creates new [RequestEditorBloc]
  RequestEditorBloc({required this.service}) : super(InitialState());

  @override
  Stream<BaseState> mapEventToState(RequestEditorEvent event) async* {
    if (event is SetRequestEvent) {
      yield* _setCurrentRequest(event);
    } else if (event is SaveRequestEvent) {
      yield* _saveRequest(event);
    }
  }

  Stream<BaseState> _saveRequest(SaveRequestEvent event) async* {
    final currentState = state;

    if (currentState is DataState<RequestEditorData>) {
      final data = currentState.data;

      try {
        // Check request and try to save it
        service.saveRequest(
          updatedInfo: event,
          document: data.document,
          worksheet: data.worksheet,
          current: data.current,
        );

        yield CompletedState();
      } on ValidationError catch (e) {
        // We have some errors in field completion
        final currentState = state;
        yield ErrorState(e.errors.join(', '));
        yield currentState;
      }
    }
  }

  /// Sets currently edited request
  Stream<DataState> _setCurrentRequest(SetRequestEvent event) async* {
    final requestTypes =
        await service.fetchRequestTypes(event.request?.requestType);

    yield DataState<RequestEditorData>(
      RequestEditorData(
        current: event.request ?? service.createTemporaryRequest(),
        availableRequestTypes: requestTypes,
        worksheet: event.worksheet,
        document: event.document,
      ),
    );
  }
}
