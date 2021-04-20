part of 'worksheet_config_bloc.dart';

/// Data structure that holds info for worksheet config view
class WorksheetConfigInfo extends Equatable {
  /// All available employees in the database
  final Set<Employee> allEmployees;

  /// Employees that can be assigned as team members
  final Set<Employee> teamMembersEmployees;

  /// Employees that can be assigned as main employee
  final Set<Employee> mainEmployees;

  /// Employees that can chief
  final Set<Employee> chiefEmployees;

  /// Current main employee
  final Employee? mainEmployee;

  /// Current chief employee
  final Employee? chiefEmployee;

  /// Current set of members employee
  final Set<Employee> membersEmployee;

  /// Current set of work types
  final Set<String> workTypes;

  /// Current worksheet targeting date
  final DateTime? targetDate;

  /// Returns `true if more team members can be added to the current worksheet
  bool get canHaveMoreMembers => membersEmployee.length < 6;

  /// If `true` then there is an additional field for teams members
  final bool hasExpandedTeamField;

  const WorksheetConfigInfo({
    required this.allEmployees,
    required this.mainEmployees,
    required this.teamMembersEmployees,
    required this.chiefEmployees,
    required this.mainEmployee,
    required this.chiefEmployee,
    required this.membersEmployee,
    required this.workTypes,
    required this.targetDate,
    this.hasExpandedTeamField = false,
  });

  @override
  List<Object?> get props => [
        mainEmployees,
        teamMembersEmployees,
        chiefEmployees,
        mainEmployee,
        chiefEmployee,
        membersEmployee,
        workTypes,
        targetDate,
        allEmployees,
        hasExpandedTeamField,
      ];
}
