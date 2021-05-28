import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/models/worksheets_list.dart';
import 'package:kres_requests2/domain/repositories.dart';
import 'package:kres_requests2/screens/bloc.dart';
import 'package:meta/meta.dart';

part 'worksheet_config_events.dart';

part 'worksheet_config_info.dart';

/// BLoC responsible for managing employees, target date, and work types
class WorksheetConfigBloc extends Bloc<WorksheetConfigEvent, BaseState> {
  /// Repository for accessing employees list
  final Repository<Employee> employeeRepository;

  /// Current worksheets list
  final WorksheetsList worksheetsList;

  StreamSubscription<Worksheet>? _activeSubscription;

  WorksheetConfigBloc(
    this.employeeRepository,
    this.worksheetsList,
  ) : super(const InitialState()) {
    _activeSubscription = worksheetsList.activeStream.listen((_) {
      add(const _WorksheetConfigLoadData());
    });

    add(const _WorksheetConfigLoadData());
  }

  @override
  Future<void> close() async {
    await _activeSubscription?.cancel();
    _activeSubscription = null;

    return await super.close();
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

    final editor = worksheetsList.edit(worksheetsList.active);
    // Update employee assignment
    switch (type) {
      case SingleEmployeeType.main:
        editor.setMainEmployee(employee);
        break;
      case SingleEmployeeType.chief:
        editor.setChiefEmployee(employee);
        break;
    }

    editor.commit();
  }

  Stream<BaseState> _updateTargetDate(DateTime targetDate) async* {
    final currentState = state;
    if (currentState is! DataState<WorksheetConfigInfo>) {
      return;
    }

    worksheetsList
        .edit(worksheetsList.active)
        .setTargetDate(targetDate)
        .commit();
  }

  Stream<BaseState> _updateTeamMembers(Set<Employee> employee) async* {
    final currentState = state;
    if (currentState is! DataState<WorksheetConfigInfo>) {
      return;
    }

    worksheetsList
        .edit(worksheetsList.active)
        .setTeamMembers(employee)
        .commit();
  }

  Stream<BaseState> _updateWorkTypes(Set<String> workTypes) async* {
    final currentState = state;
    if (currentState is! DataState<WorksheetConfigInfo>) {
      return;
    }

    worksheetsList.edit(worksheetsList.active).setWorkTypes(workTypes).commit();
  }

  WorksheetConfigInfo _buildConfigInfo(Set<Employee> employees) {
    final worksheet = worksheetsList.active;

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
