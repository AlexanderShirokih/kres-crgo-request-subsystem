part of 'management_bloc.dart';

abstract class ManagementEvent extends Equatable {
  const ManagementEvent();
}

class ManagementFetchEvent extends ManagementEvent {
  @override
  List<Object> get props => [];
}

enum RemoveItemType { REQUEST, CONFIRMED, RESTORED }

class ManagementRemoveItemEvent<E> extends ManagementEvent {
  final E entity;
  final RemoveItemType type;

  const ManagementRemoveItemEvent(this.entity,
      [this.type = RemoveItemType.REQUEST]);

  @override
  List<Object> get props => [entity, type];
}

class ManagementEditItemEvent<E> extends ManagementEvent {
  final E entity;

  const ManagementEditItemEvent(this.entity);

  @override
  List<Object> get props => [entity];
}

class ManagementEditCompletedEvent<E> extends ManagementEvent {
  final E originalEntity;
  final Map<String, dynamic> edited;

  const ManagementEditCompletedEvent(this.originalEntity, this.edited)
      : assert(edited != null);

  @override
  List<Object> get props => [originalEntity, edited];
}
