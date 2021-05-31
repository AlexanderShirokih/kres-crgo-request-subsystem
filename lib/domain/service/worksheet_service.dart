import '../models.dart';
import '../repositories.dart';

/// Service for handling actions on worksheet
class WorksheetService {
  final Document document;
  final Repository<Employee> _employeeRepository;

  const WorksheetService(this.document, this._employeeRepository);

  /// Swaps requests on [target] worksheet [from] one request [to] another.
  void swapRequest(Worksheet target, Request from, Request to) {
    document.worksheets.edit(target).swapRequests(from, to).commit();
  }

  /// Removes [requests] from [target] worksheet
  void removeRequests(Worksheet target, List<Request> requests) {
    document.worksheets.edit(target).removeRequests(requests).commit();
  }

  // Updates target date on [target] worksheet
  void updateTargetDate(Worksheet target, DateTime targetDate) {
    document.worksheets.edit(target).setTargetDate(targetDate).commit();
  }

  /// Updates current work types on [target] worksheet
  void updateWorkTypes(Worksheet target, Set<String> workTypes) {
    document.worksheets.edit(target).setWorkTypes(workTypes).commit();
  }

  /// Updates team members on [target] worksheet
  void updateTeamMembers(Worksheet target, Set<Employee> employee) {
    document.worksheets.edit(target).setTeamMembers(employee).commit();
  }

  /// Updates main employee on [target] worksheet
  void updateMainEmployee(Worksheet target, Employee? employee) {
    document.worksheets.edit(target).setMainEmployee(employee).commit();
  }

  /// Updates chief employee on [target] worksheet
  void updateChiefEmployee(Worksheet target, Employee? employee) {
    document.worksheets.edit(target).setChiefEmployee(employee).commit();
  }

  /// Listen for changes on [target] worksheet
  Stream<Worksheet> listenOn(Worksheet target) =>
      document.worksheets.streamFor(target);

  /// Listen for changes on active worksheet
  Stream<Worksheet> listenOnActive() => document.worksheets.activeStream;

  /// Fetches configuration information for [target] worksheet and returns
  /// [WorksheetConfigInfo]
  Future<WorksheetConfigInfo> getWorksheetInfo(Worksheet target) async {
    final employees = Set<Employee>.from(await _employeeRepository.getAll());

    final worksheet = document.worksheets.active;

    final used = Set<Employee>.from(worksheet.getUsedEmployee());

    final unusedEmployees = employees.difference(used);

    final mainEmployees = [
      ...unusedEmployees,
      if (worksheet.mainEmployee != null) worksheet.mainEmployee!
    ].toSet();

    final teamMembersEmployees =
        unusedEmployees.union(worksheet.membersEmployee);

    final chiefEmployees = [
      ...unusedEmployees.where((e) => e.accessGroup >= 4),
      if (worksheet.chiefEmployee != null) worksheet.chiefEmployee!
    ].toSet();

    return WorksheetConfigInfo(
      allEmployees: employees,
      mainEmployees: mainEmployees,
      teamMembersEmployees: teamMembersEmployees,
      chiefEmployees: chiefEmployees,
      worksheet: worksheet,
    );
  }
}
