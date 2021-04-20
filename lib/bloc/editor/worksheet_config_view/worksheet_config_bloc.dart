import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/domain/controller/worksheet_editor.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/repositories.dart';
import 'package:kres_requests2/screens/bloc.dart';
import 'package:meta/meta.dart';

part 'worksheet_config_events.dart';

part 'worksheet_config_info.dart';

/// BLoC responsible for managing employees, target date, and work types
class WorksheetConfigBloc extends Bloc<WorksheetConfigEvent, BaseState> {
  /// Repository for accessing employees list
  final Repository<Employee> employeeRepository;

  /// Current worksheet
  final WorksheetEditor worksheetEditor;

  WorksheetConfigBloc(
    this.employeeRepository,
    this.worksheetEditor,
  ) : super(const InitialState()) {
    add(const _WorksheetConfigLoadData());
  }

  @override
  Stream<BaseState> mapEventToState(WorksheetConfigEvent event) async* {
    if (event is _WorksheetConfigLoadData) {
      yield* _loadData();
    } else if (event is UpdateSingleEmployeeEvent) {
      yield* _updateSingleEmployeeEvent(event.employee, event.type);
    } else if (event is UpdateTargetDateEvent) {
      yield* _updateTargetDate(event.targetDate);
    } else if (event is UpdateMembersEvent) {
      yield* _updateTeamMembers(event.teamMembers);
    } else if (event is UpdateWorkTypesEvent) {
      yield* _updateWorkTypes(event.workTypes);
    }
  }

  Stream<BaseState> _loadData() async* {
    final employees = Set<Employee>.from(await employeeRepository.getAll());

    yield DataState(_buildConfigInfo(employees));
  }

  Stream<BaseState> _updateSingleEmployeeEvent(
    Employee? employee,
    SingleEmployeeType type,
  ) async* {
    final currentState = state;
    if (currentState is! DataState<WorksheetConfigInfo>) {
      return;
    }

    // Update employee assignment
    switch (type) {
      case SingleEmployeeType.main:
        worksheetEditor.setMainEmployee(employee);
        break;
      case SingleEmployeeType.chief:
        worksheetEditor.setChiefEmployee(employee);
        break;
    }

    // Rebuild worksheet config info
    yield DataState(_buildConfigInfo(currentState.data.allEmployees));
  }

  Stream<BaseState> _updateTargetDate(DateTime targetDate) async* {
    final currentState = state;
    if (currentState is! DataState<WorksheetConfigInfo>) {
      return;
    }

    worksheetEditor.setTargetDate(targetDate);

    // Rebuild worksheet config info
    yield DataState(_buildConfigInfo(currentState.data.allEmployees));
  }

  Stream<BaseState> _updateTeamMembers(Set<Employee> employee) async* {
    final currentState = state;
    if (currentState is! DataState<WorksheetConfigInfo>) {
      return;
    }

    worksheetEditor.setTeamMembers(employee);

    // Rebuild worksheet config info
    yield DataState(_buildConfigInfo(currentState.data.allEmployees));
  }

  Stream<BaseState> _updateWorkTypes(Set<String> workTypes) async* {
    final currentState = state;
    if (currentState is! DataState<WorksheetConfigInfo>) {
      return;
    }

    worksheetEditor.setWorkTypes(workTypes);

    // Rebuild worksheet config info
    yield DataState(_buildConfigInfo(currentState.data.allEmployees));
  }

  WorksheetConfigInfo _buildConfigInfo(Set<Employee> employees) {
    final worksheet = worksheetEditor.current;
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
      chiefEmployee: worksheet.chiefEmployee,
      mainEmployee: worksheet.mainEmployee,
      membersEmployee: worksheet.membersEmployee,
      targetDate: worksheet.targetDate,
      workTypes: worksheet.workTypes,
    );
  }
}
