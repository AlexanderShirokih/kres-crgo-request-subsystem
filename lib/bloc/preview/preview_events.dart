part of 'preview_bloc.dart';

/// Base event class for [PreviewBloc]
@sealed
abstract class PreviewEvent extends Equatable {
  const PreviewEvent._();
}

/// Event that used internally to trigger initial document checking
class _CheckDocumentEvent extends PreviewEvent {
  const _CheckDocumentEvent() : super._();

  @override
  List<Object?> get props => [];
}

/// Used to update a list of selected lists
class UpdateSelectedEvent extends PreviewEvent {
  /// A list of selected worksheets
  final List<Worksheet> selectedWorksheets;

  const UpdateSelectedEvent(this.selectedWorksheets) : super._();

  @override
  List<Object?> get props => [selectedWorksheets];
}
