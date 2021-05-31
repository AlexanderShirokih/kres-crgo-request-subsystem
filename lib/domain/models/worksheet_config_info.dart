import 'package:equatable/equatable.dart';
import 'package:kres_requests2/domain/models.dart';

/// Data structure that holds info for worksheet config view
class WorksheetConfigInfo extends Equatable {
  /// Target worksheet
  final Worksheet worksheet;

  /// All available employees in the database
  final Set<Employee> allEmployees;

  /// Employees that can be assigned as team members
  final Set<Employee> teamMembersEmployees;

  /// Employees that can be assigned as main employee
  final Set<Employee> mainEmployees;

  /// Employees that can chief
  final Set<Employee> chiefEmployees;

  /// Current main employee
  Employee? get mainEmployee => worksheet.mainEmployee;

  /// Current chief employee
  Employee? get chiefEmployee => worksheet.chiefEmployee;

  /// Current set of members employee
  Set<Employee> get membersEmployee => worksheet.membersEmployee;

  /// Current set of work types
  Set<String> get workTypes => worksheet.workTypes;

  /// Current worksheet targeting date
  DateTime? get targetDate => worksheet.targetDate;

  /// Returns `true if more team members can be added to the current worksheet
  bool get canHaveMoreMembers => membersEmployee.length < 6;

  /// If `true` then there is an additional field for teams members
  final bool hasExpandedTeamField;

  /// Returns `true` if [employee] used more than once at any positions
  bool isUsedElseWhere(Employee employee) =>
      worksheet.isUsedElseWhere(employee);

  const WorksheetConfigInfo({
    required this.allEmployees,
    required this.mainEmployees,
    required this.chiefEmployees,
    required this.teamMembersEmployees,
    required Worksheet worksheet,
    this.hasExpandedTeamField = false,
  }) : worksheet = worksheet;

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
