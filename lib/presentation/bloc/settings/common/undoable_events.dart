import 'package:equatable/equatable.dart';

/// Base class for events that have actions history and can be reverted
abstract class UndoableDataEvent extends Equatable {
  const UndoableDataEvent();
}

/// Triggers data state with updated [data]
class RefreshDataEvent<T> extends UndoableDataEvent {
  final List<T> data;

  const RefreshDataEvent(this.data);

  @override
  List<Object> get props => [data];
}

/// Signals to cancel editing and revert to the last saved state
class UndoActionEvent extends UndoableDataEvent {
  const UndoActionEvent();

  @override
  List<Object> get props => [];
}

/// Signals to apply inserted changes to data list
class ApplyEvent extends UndoableDataEvent {
  const ApplyEvent();

  @override
  List<Object> get props => [];
}

/// Signals to add a new item
class AddItemEvent extends UndoableDataEvent {
  const AddItemEvent();

  @override
  List<Object> get props => [];
}

/// Notifies about updated entity
class UpdateItemEvent<T extends Object> extends UndoableDataEvent {
  /// Original entity
  final T original;

  /// Modified entity
  final T updated;

  const UpdateItemEvent(this.original, this.updated);

  @override
  List<Object> get props => [original, updated];
}

class DeleteItemEvent<T extends Object> extends UndoableDataEvent {
  /// Entity to be deleted
  final T entity;

  const DeleteItemEvent(this.entity);

  @override
  List<Object> get props => [entity];
}

/// Event used when some table references to another table, but it is empty
class MissingDependencyEvent extends UndoableDataEvent {
  const MissingDependencyEvent();

  @override
  List<Object> get props => [];
}