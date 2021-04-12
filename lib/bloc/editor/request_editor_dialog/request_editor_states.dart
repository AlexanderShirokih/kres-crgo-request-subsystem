part of 'request_editor_bloc.dart';

/// Base state for [RequestEditorBloc]
abstract class RequestEditorState extends Equatable {
  const RequestEditorState._();
}

/// State used when data is ready to show
class RequestEditorShowDataState extends RequestEditorState {
  /// Current request entity to be shown
  final RequestEntity current;

  /// List of all available request types
  final List<RequestType> availableRequestTypes;

  /// List of year quarters. `null` value means quarter is unset
  final List<int?> availableCheckQuarters = const [null, 1, 2, 3, 4];

  /// Default constructor to create the state from [RequestEntity] instance
  const RequestEditorShowDataState({
    required this.availableRequestTypes,
    required this.current,
  }) : super._();

  @override
  List<Object?> get props => [current, availableRequestTypes];
}

/// Notifies user about error in request fields completion.
class RequestValidationErrorState extends RequestEditorState {
  final String error;

  const RequestValidationErrorState(this.error) : super._();

  @override
  List<Object?> get props => [error];
}

/// A state indicating that request editing successfully completed
class RequestEditingCompletedState extends RequestEditorState {
  const RequestEditingCompletedState() : super._();

  @override
  List<Object?> get props => [];
}
