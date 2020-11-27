import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kres_requests2/models/entity.dart';
import 'package:kres_requests2/models/encoder.dart';
import 'package:kres_requests2/models/optional_data.dart';
import 'package:kres_requests2/repo/base_crd_repository.dart';
import 'package:meta/meta.dart';

part 'management_event.dart';

part 'management_state.dart';

class ManagementBloc<E extends Entity>
    extends Bloc<ManagementEvent, ManagementState> {
  final Encoder<E> _typeEncoder;
  final BaseCRDRepository<E> _repository;

  ManagementBloc(this._repository, this._typeEncoder)
      : super(ManagementInitial()) {
    add(ManagementFetchEvent());
  }

  @override
  Stream<ManagementState> mapEventToState(ManagementEvent event) async* {
    if (event is ManagementFetchEvent) {
      yield* _fetchData();
    } else if (event is ManagementRemoveItemEvent<E>) {
      switch (event.type) {
        case RemoveItemType.CONFIRMED:
          yield* _deleteEntity(event.entity);
          return;
        case RemoveItemType.REQUEST:
          yield* _showConfirmation(event.entity);
          return;
        case RemoveItemType.RESTORED:
          yield* _restoreEntity(event.entity);
          return;
      }
    } else if (event is ManagementEditItemEvent<E>) {
      final saved = state;
      yield ManagementEditingState(event.entity);
      yield saved;
    } else if (event is ManagementEditCompletedEvent<E>) {
      yield* _processEditingResult(event.originalEntity, event.edited);
    }
  }

  Stream<ManagementState> _fetchData() => _safeApiCall(() async* {
        yield ManagementFetchingData();
        final data = await _repository.getAll();
        yield ManagementDataState(data);
      });

  Stream<ManagementState> _showConfirmation(E entity) async* {
    final saved = state;
    yield ManagementConfirmationState(
      onConfirmed: ManagementRemoveItemEvent(entity, RemoveItemType.CONFIRMED),
      onRestore: ManagementRemoveItemEvent(entity, RemoveItemType.RESTORED),
      content: entity.toString(),
    );
    if (saved is ManagementDataState<E>) {
      saved.data.remove(entity);
    }
    yield saved;
  }

  Stream<ManagementState> _deleteEntity(E entity) => _safeApiCall(() async* {
        final saved = state;
        if (saved is ManagementDataState<E>) {
          yield ManagementFetchingData();
          await _repository.delete(entity);
          yield saved;
        }
      });

  Stream<ManagementState> _restoreEntity(E entity) async* {
    final saved = state;
    if (saved is ManagementDataState<E>) {
      yield ManagementFetchingData();
      saved.data.add(entity);
      yield saved;
    }
  }

  Stream<ManagementState> _processEditingResult(
      E originalEntity, Map<String, dynamic> editingResult) async* {
    final id = originalEntity?.getId();
    if (id != null) {
      editingResult['id'] = id;
    }

    final E editedEntity = _typeEncoder.fromJson(editingResult);

    if (editedEntity != originalEntity) {
      yield* _safeApiCall(() async* {
        yield ManagementFetchingData();
        await _repository.save(editedEntity);
        yield* _fetchData();
      });
    }
  }

  Stream<ManagementState> _safeApiCall(
          Stream<ManagementState> Function() action) =>
      action().transform(
          StreamTransformer<ManagementState, ManagementState>.fromHandlers(
        handleError: (e, s, sink) {
          sink.add(
              ManagementErrorState(ErrorWrapper(e.toString(), s.toString())));
        },
      ));
}
