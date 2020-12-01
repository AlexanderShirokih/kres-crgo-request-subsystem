part of 'preview_bloc.dart';

abstract class PreviewEvent extends Equatable {
  const PreviewEvent();
}

class PreviewFetchStatus extends PreviewEvent {
  @override
  List<Object> get props => [];
}

class PreviewSelectionChangedEvent extends PreviewEvent {
  final RequestSetService target;
  final bool isSelected;

  PreviewSelectionChangedEvent(this.target, this.isSelected);

  @override
  List<Object> get props => [target, isSelected];
}
