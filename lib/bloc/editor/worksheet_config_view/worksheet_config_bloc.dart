import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/service/worksheet_service.dart';
import 'package:kres_requests2/screens/bloc.dart';
import 'package:meta/meta.dart';

part 'worksheet_config_events.dart';

/// BLoC responsible for managing employees, target date, and work types
class WorksheetConfigBloc extends Bloc<WorksheetConfigEvent, BaseState> {
  /// Service for handling worksheet related operations
  final WorksheetService _service;

  StreamSubscription<Worksheet>? _activeSubscription;

  WorksheetConfigBloc(
    this._service,
  ) : super(const InitialState()) {
    _activeSubscription = _service.listenOnActive().listen((active) {
      add(FetchDataEvent(active));
    });
  }

  @override
  Stream<BaseState> mapEventToState(WorksheetConfigEvent event) async* {
    if (event is FetchDataEvent) {
      yield* _loadData(event.target);
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

  @override
  Future<void> close() async {
    await _activeSubscription?.cancel();
    _activeSubscription = null;

    return await super.close();
  }

  Stream<BaseState> _loadData(Worksheet target) async* {
    final info = await _service.getWorksheetInfo(target);
    yield DataState(info);
  }

  Stream<BaseState> _updateSingleEmployeeEvent(
    Employee? employee,
    SingleEmployeeType type,
  ) async* {
    final ws = _findTargetWorksheet();
    if (ws == null) return;

    // Update employee assignment
    switch (type) {
      case SingleEmployeeType.main:
        _service.updateMainEmployee(ws, employee);
        break;
      case SingleEmployeeType.chief:
        _service.updateChiefEmployee(ws, employee);
        break;
    }
  }

  Stream<BaseState> _updateTargetDate(DateTime targetDate) async* {
    final ws = _findTargetWorksheet();
    if (ws == null) return;
    _service.updateTargetDate(ws, targetDate);
  }

  Stream<BaseState> _updateTeamMembers(Set<Employee> employee) async* {
    final ws = _findTargetWorksheet();
    if (ws == null) return;

    _service.updateTeamMembers(ws, employee);
  }

  Stream<BaseState> _updateWorkTypes(Set<String> workTypes) async* {
    final ws = _findTargetWorksheet();
    if (ws == null) return;

    _service.updateWorkTypes(ws, workTypes);
  }

  Worksheet? _findTargetWorksheet() {
    final current = state;
    if (current is DataState<WorksheetConfigInfo>) {
      return current.data.worksheet;
    }
  }
}
