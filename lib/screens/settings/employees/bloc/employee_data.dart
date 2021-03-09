part of 'employee_bloc.dart';

/// Employee screen data
class EmployeeData extends Equatable {
  /// List of all employees
  final List<Employee> employees;

  /// List of all available positions
  final List<Position> availablePositions;

  /// List of all access groups
  final List<int> groups = const [2, 3, 4, 5];

  const EmployeeData({
    required this.employees,
    required this.availablePositions,
  });

  @override
  List<Object?> get props => [
        employees,
        availablePositions,
        groups,
      ];
}
