part of 'worksheet_config_bloc.dart';

/// Data structure that holds info for worksheet config view
class WorksheetConfigInfo extends Equatable {
  final Worksheet _worksheet;

  /// All available employees in the database
  final Set<Employee> allEmployees;

  /// Employees that can be assigned as team members
  final Set<Employee> teamMembersEmployees;

  /// Employees that can be assigned as main employee
  final Set<Employee> mainEmployees;

  /// Employees that can chief
  final Set<Employee> chiefEmployees;

  /// Current main employee
  Employee? get mainEmployee => _worksheet.mainEmployee;

  /// Current chief employee
  Employee? get chiefEmployee => _worksheet.chiefEmployee;

  /// Current set of members employee
  Set<Employee> get membersEmployee => _worksheet.membersEmployee;

  /// Current set of work types
  Set<String> get workTypes => _worksheet.workTypes;

  /// Current worksheet targeting date
  DateTime? get targetDate => _worksheet.targetDate;

  /// Returns `true if more team members can be added to the current worksheet
  bool get canHaveMoreMembers => membersEmployee.length < 6;

  /// If `true` then there is an additional field for teams members
  final bool hasExpandedTeamField;

  /// Returns `true` if [employee] used more than once at any positions
  bool isUsedElseWhere(Employee employee) =>
      _worksheet.isUsedElseWhere(employee);

  const WorksheetConfigInfo({
    required this.allEmployees,
    required this.mainEmployees,
    required this.chiefEmployees,
    required this.teamMembersEmployees,
    required Worksheet worksheet,
    this.hasExpandedTeamField = false,
  }) : _worksheet = worksheet;

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
