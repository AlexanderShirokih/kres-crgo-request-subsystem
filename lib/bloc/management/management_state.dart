part of 'management_bloc.dart';

abstract class ManagementState extends Equatable {
  const ManagementState();
}

class ManagementInitial extends ManagementState {
  @override
  List<Object> get props => [];
}

class ManagementFetchingData extends ManagementState {
  @override
  List<Object> get props => [];
}

class ManagementDataState<E> extends ManagementState {
  final List<E> data;

  const ManagementDataState(this.data) : assert(data != null);

  @override
  List<Object> get props => [data];
}

class ManagementConfirmationState extends ManagementState {
  final ManagementEvent onConfirmed;
  final ManagementEvent onRestore;
  final String content;

  const ManagementConfirmationState({
    @required this.onConfirmed,
    @required this.onRestore,
    @required this.content,
  })  : assert(onConfirmed != null),
        assert(content != null),
        assert(onRestore != null);

  @override
  List<Object> get props => [onConfirmed, content];
}

class ManagementErrorState extends ManagementState {
  final ErrorWrapper error;

  const ManagementErrorState(this.error) : assert(error != null);

  @override
  List<Object> get props => [error];
}

class ManagementEditingState<E> extends ManagementState {
  final E entity;

  const ManagementEditingState(this.entity);

  @override
  List<Object> get props => [entity];
}
