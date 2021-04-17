import 'dart:async';

import 'package:kres_requests2/domain/controller/streamed_controller.dart';
import 'package:kres_requests2/domain/models/position.dart';
import 'package:kres_requests2/domain/validator.dart';
import 'package:kres_requests2/bloc/settings/common/undoable_bloc.dart';
import 'package:kres_requests2/bloc/settings/positions/position_data.dart';

/// BLoC that handles actions on position list
class PositionBloc extends UndoableBloc<PositionData, Position> {
  /// Creates new [PositionBloc] and starts fetching position list
  PositionBloc(
    StreamedRepositoryController<Position> controller,
    Validator<Position> validator,
  ) : super(controller, validator);

  @override
  Future<Position> createNewEntity() async => Position(name: '');

  @override
  Future<PositionData> onRefreshData(List<Position> data) async =>
      PositionData(data);
}
