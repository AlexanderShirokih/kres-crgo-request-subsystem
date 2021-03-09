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
import 'package:kres_requests2/screens/settings/common/bloc/undoable_events.dart';
import 'package:kres_requests2/screens/settings/common/bloc/undoable_state.dart';

part 'employee_data.dart';

/// BLoC that handles actions on employees list
class EmployeeBloc
    extends Bloc<UndoableDataEvent, UndoableState<EmployeeData>> {
  final StreamedRepositoryController<Employee> _controller;
  final Repository<Position> _positionRepository;
  final Validator<Employee> _validator;
  final AsyncLazy<Position> _defaultPosition;
  late StreamSubscription _subscription;

  /// Creates new [EmployeeBloc] from [EmployeeRepository]
  /// and starts fetching employee list
  EmployeeBloc(
    this._controller,
    this._positionRepository,
    this._validator,
  )   : _defaultPosition = AsyncLazy(),
        super(InitialState()) {
    _subscription = _controller.stream.listen((event) {
      add(RefreshDataEvent(event));
    }, onError: (e, s) {
      // TODO: Handle error
      print('GOT AN ERROR: $e');
    });
    _controller.fetchData();
  }

  @override
  Stream<DataState<EmployeeData>> mapEventToState(
      UndoableDataEvent event) async* {
    if (event is RefreshDataEvent<Employee>) {
      yield DataState(
        data: EmployeeData(
          employees: event.data,
          availablePositions: await _positionRepository.getAll(),
        ),
        hasUnsavedChanges: _controller.hasUncommittedChanges,
        canSave: _controller.hasUncommittedChanges &&
            _validator.isValid(event.data),
      );
    } else if (event is UndoActionEvent) {
      _controller.undo();
    } else if (event is ApplyEvent) {
      await commitChanges();
    } else if (event is AddItemEvent) {
      _controller.add(await _createNewEmployee());
    } else if (event is UpdateItemEvent<Employee>) {
      _controller.update(event.original, event.updated);
    } else if (event is DeleteItemEvent<Employee>) {
      _controller.delete(event.entity);
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

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
