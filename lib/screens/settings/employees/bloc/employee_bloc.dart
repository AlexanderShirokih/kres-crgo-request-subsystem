import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/domain/controller/streamed_controller.dart';
import 'package:kres_requests2/domain/lazy.dart';
import 'package:kres_requests2/domain/models/employee.dart';
import 'package:kres_requests2/domain/models/position.dart';
import 'package:kres_requests2/domain/repository/employee_repository.dart';
import 'package:kres_requests2/domain/repository/repository.dart';
import 'package:kres_requests2/domain/validator.dart';

part 'employee_event.dart';
part 'employee_state.dart';

/// BLoC that handles actions on employees list
class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final StreamedRepositoryController<Employee> _controller;
  final Repository<Position> _positionRepository;
  final Validator<Employee> _employeeValidator;
  final AsyncLazy<Position> _defaultPosition;

  /// Creates new [EmployeeBloc] from [EmployeeRepository]
  /// and starts fetching employee list
  EmployeeBloc(
    this._controller,
    this._positionRepository,
    this._employeeValidator,
  )   : _defaultPosition = AsyncLazy(),
        super(EmployeeInitial()) {
    _controller.stream.listen((event) {
      add(EmployeeRefreshData(event));
    }, onError: (e, s) {
      // TODO: Handle error
      print('GOT AN ERROR: $e');
    });
    _controller.fetchData();
  }

  @override
  Stream<EmployeeState> mapEventToState(EmployeeEvent event) async* {
    if (event is EmployeeRefreshData) {
      yield EmployeeDataState(
        employees: event.data,
        availablePositions: await _positionRepository.getAll(),
        hasUnsavedChanges: _controller.hasUncommittedChanges,
        canSave: _controller.hasUncommittedChanges &&
            _employeeValidator.isValid(event.data),
      );
    } else if (event is EmployeeUndoAction) {
      _controller.undo();
    } else if (event is EmployeeApply) {
      await commitChanges();
    } else if (event is EmployeeAddItem) {
      _controller.add(await _createNewEmployee());
    } else if (event is EmployeeUpdateItem) {
      _controller.update(event.original, event.updated);
    } else if (event is EmployeeDeleteItem) {
      _controller.delete(event.employee);
    }
  }

  /// Commits entered changes. Should be used only to be sure the changes
  /// has committed before screen popped.
  Future<void> commitChanges() => _controller.commit();

  Future<Employee> _createNewEmployee() async {
    return Employee(
      name: '',
      position: await _defaultPosition
          .call(() async => (await _positionRepository.getAll()).first),
      accessGroup: 3,
    );
  }
}
