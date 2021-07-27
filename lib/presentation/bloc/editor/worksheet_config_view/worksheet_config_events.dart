part of 'worksheet_config_bloc.dart';

/// Base event class for [WorksheetConfigBloc]
@sealed
abstract class WorksheetConfigEvent extends Equatable {
  const WorksheetConfigEvent._();
}

/// Used to trigger data loading
class FetchDataEvent extends WorksheetConfigEvent {
  /// Target worksheet for listening to
  final Worksheet target;

  const FetchDataEvent(this.target) : super._();

  @override
  List<Object?> get props => [target];
}

/// Describes employee types with single assignment
enum SingleEmployeeType {
  main,
  chief,
}

/// Used to updated chief or main employee assignment
class UpdateSingleEmployeeEvent extends WorksheetConfigEvent {
  /// New employee assignment
  final Employee? employee;

  /// Employee type
  final SingleEmployeeType type;

  const UpdateSingleEmployeeEvent(this.employee, this.type) : super._();

  @override
  List<Object?> get props => [employee, type];
}

/// Updates worksheet targeting date
class UpdateTargetDateEvent extends WorksheetConfigEvent {
  /// New targeting date value
  final DateTime targetDate;

  const UpdateTargetDateEvent(this.targetDate) : super._();

  @override
  List<Object?> get props => [targetDate];
}

/// Updates team members list on the worksheet
class UpdateMembersEvent extends WorksheetConfigEvent {
  final Set<Employee> teamMembers;

  const UpdateMembersEvent(this.teamMembers) : super._();

  @override
  List<Object?> get props => [teamMembers];
}

/// Updates work types
class UpdateWorkTypesEvent extends WorksheetConfigEvent {
  final Set<String> workTypes;

  const UpdateWorkTypesEvent(this.workTypes) : super._();

  @override
  List<Object?> get props => [workTypes];
}

/// Updates worksheet name
class UpdateNameEvent extends WorksheetConfigEvent {
  /// New worksheet name
  final String name;

  /// Target worksheet. If not present, active worksheet will be used
  final Worksheet? target;

  const UpdateNameEvent(this.name, [this.target]) : super._();

  @override
  List<Object?> get props => [name];
}
