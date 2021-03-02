part of 'employee_bloc.dart';

/// Base class for all events for [EmployeeViewModel]
abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();
}

/// Triggers data state with updated [data]
class EmployeeRefreshData extends EmployeeEvent {
  final List<Employee> data;

  EmployeeRefreshData(this.data);

  @override
  List<Object> get props => [data];
}

/// Signals to cancel editing and revert to last saved state
class EmployeeUndoAction extends EmployeeEvent {
  const EmployeeUndoAction();

  @override
  List<Object> get props => [];
}

/// Signals to apply inserted changes to employee list
class EmployeeApply extends EmployeeEvent {
  const EmployeeApply();

  @override
  List<Object> get props => [];
}

/// Signals to add a new item
class EmployeeAddItem extends EmployeeEvent {
  const EmployeeAddItem();

  @override
  List<Object> get props => [];
}

/// Notifies about updated [Employee]
class EmployeeUpdateItem extends EmployeeEvent {
  /// Original employee
  final Employee original;

  /// Modified employee
  final Employee updated;

  const EmployeeUpdateItem(this.original, this.updated);

  @override
  List<Object> get props => [original, updated];
}

class EmployeeDeleteItem extends EmployeeEvent {
  /// Employee to be deleted
  final Employee employee;

  const EmployeeDeleteItem(this.employee);

  @override
  List<Object> get props => [employee];
}
