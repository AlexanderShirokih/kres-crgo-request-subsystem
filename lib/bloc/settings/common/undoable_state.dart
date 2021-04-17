import 'package:equatable/equatable.dart';
import 'package:kres_requests2/bloc/settings/common/undoable_data.dart';

/// Base class for states that have actions history and can be reverted
abstract class UndoableState<D> extends Equatable {
  const UndoableState();
}

/// Initial state without any data
class InitialState<D> extends UndoableState<D> {
  @override
  List<Object> get props => [];

  const InitialState();
}

/// State used to show data on screen
class DataState<E extends Object, D extends UndoableDataHolder<E>>
    extends UndoableState<D> {
  /// Current data
  final D current;

  /// `true` if current document has unsaved changes
  final bool hasUnsavedChanges;

  /// `true` is current document can be saved (All fields are valid).
  final bool canSave;

  const DataState({
    required this.current,
    required this.hasUnsavedChanges,
    required this.canSave,
  });

  @override
  List<Object?> get props => [
        current,
        hasUnsavedChanges,
        canSave,
      ];
}
