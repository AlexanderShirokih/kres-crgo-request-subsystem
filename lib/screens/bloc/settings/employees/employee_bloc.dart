import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:kres_requests2/domain/controller/streamed_controller.dart';
import 'package:kres_requests2/domain/lazy.dart';
import 'package:kres_requests2/domain/models/employee.dart';
import 'package:kres_requests2/domain/models/position.dart';
import 'package:kres_requests2/domain/repository/repository.dart';
import 'package:kres_requests2/domain/validator.dart';
import 'package:kres_requests2/screens/bloc/settings/common/undoable_bloc.dart';
import 'package:kres_requests2/screens/bloc/settings/common/undoable_data.dart';

part 'employee_data.dart';

/// BLoC that handles actions on employees list
class EmployeeBloc extends UndoableBloc<EmployeeData, Employee> {
  final Repository<Position> _positionRepository;
  final AsyncLazy<Position> _defaultPosition;

  /// Creates new [EmployeeBloc] and starts fetching employee list
  EmployeeBloc(
    StreamedRepositoryController<Employee> controller,
    Validator<Employee> validator,
    this._positionRepository,
  )   : _defaultPosition = AsyncLazy(),
        super(controller, validator);

  @override
  Future<Employee> createNewEntity() async => Employee(
        name: '',
        position: await _defaultPosition
            .call(() async => (await _positionRepository.getAll()).first),
        accessGroup: 3,
      );

  @override
  Future<EmployeeData> onRefreshData(List<Employee> data) async => EmployeeData(
        data: data,
        availablePositions: await _positionRepository.getAll(),
      );
}
