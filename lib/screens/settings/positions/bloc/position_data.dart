import 'package:equatable/equatable.dart';
import 'package:kres_requests2/domain/models/position.dart';
import 'package:kres_requests2/screens/settings/common/bloc/undoable_data.dart';

/// Data holder for positions BLoC
class PositionData extends Equatable implements UndoableDataHolder<Position> {
  /// List of all postions
  @override
  final List<Position> data;

  PositionData(this.data);

  @override
  List<Object?> get props => [data];
}
