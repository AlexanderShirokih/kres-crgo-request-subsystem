part of 'employee_bloc.dart';

/// Data holder for employee BLoC
class EmployeeData extends Equatable implements UndoableDataHolder<Employee> {
  /// List of all employees
  @override
  final List<Employee> data;

  /// List of all available positions
  final List<Position> availablePositions;

  /// List of all access groups
  final List<int> groups = const [2, 3, 4, 5];

  const EmployeeData({
    required this.data,
    required this.availablePositions,
  });

  @override
  List<Object?> get props => [
        data,
        availablePositions,
        groups,
      ];
}
