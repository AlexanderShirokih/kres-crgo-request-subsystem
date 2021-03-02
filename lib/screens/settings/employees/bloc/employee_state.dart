part of 'employee_bloc.dart';

/// States for [EmployeeViewModel]
abstract class EmployeeState extends Equatable {
  const EmployeeState();
}

/// Initial state without any data
class EmployeeInitial extends EmployeeState {
  @override
  List<Object> get props => [];
}

/// State used to show a list of employees
class EmployeeDataState extends EmployeeState {
  /// List of all employees
  final List<Employee> employees;

  /// List of all available positions
  final List<Position> availablePositions;

  /// List of all access groups
  final List<int> groups = const [2, 3, 4, 5];

  /// `true` if current document has unsaved changes
  final bool hasUnsavedChanges;

  /// `true` is current document can be saved (All fields are valid).
  final bool canSave;

  const EmployeeDataState({
    @required this.employees,
    @required this.availablePositions,
    @required this.hasUnsavedChanges,
    @required this.canSave,
  });

  @override
  List<Object> get props => [
        employees,
        availablePositions,
        groups,
        hasUnsavedChanges,
        canSave,
      ];
}
