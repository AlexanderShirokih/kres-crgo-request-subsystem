part of 'preview_bloc.dart';

abstract class PreviewState extends Equatable {
  const PreviewState();
}

class PreviewInitial extends PreviewState {
  @override
  List<Object> get props => [];
}

class PreviewEmptyDocumentState extends PreviewState {
  @override
  List<Object> get props => [];
}

class PreviewValidationState extends PreviewState {
  @override
  List<Object> get props => [];
}

class PreviewDataState extends PreviewState {
  final Map<RequestSetService, WorksheetInfo> validatedWorksheets;

  PreviewDataState(this.validatedWorksheets)
      : assert(validatedWorksheets != null);

  @override
  List<Object> get props => [validatedWorksheets];
}

class PreviewErrorState extends PreviewState {
  final ErrorWrapper wrapper;

  PreviewErrorState(this.wrapper) : assert(wrapper != null);

  @override
  List<Object> get props => [wrapper];
}
