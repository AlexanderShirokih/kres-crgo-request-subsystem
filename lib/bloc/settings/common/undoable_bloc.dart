import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/domain/controller/repository_controller.dart';
import 'package:kres_requests2/domain/controller/streamed_controller.dart';
import 'package:kres_requests2/domain/validator.dart';
import 'package:kres_requests2/bloc/settings/common/undoable_data.dart';
import 'package:kres_requests2/bloc/settings/common/undoable_events.dart';
import 'package:kres_requests2/bloc/settings/common/undoable_state.dart';
import 'package:meta/meta.dart';

/// BLoC that handles actions on a list of data that can have editing history
/// and can be reverted or applied to [RepositoryController]
abstract class UndoableBloc<DH extends UndoableDataHolder<E>, E extends Object>
    extends Bloc<UndoableDataEvent, UndoableState<DH>> implements Disposable {
  final StreamedRepositoryController<E> _controller;
  final Validator<E> _validator;
  late StreamSubscription _subscription;

  /// Creates new [PositionBloc] from [PositionRepository]
  /// and starts fetching position list
  UndoableBloc(
    this._controller,
    this._validator,
  ) : super(InitialState()) {
    _subscription = _controller.stream.listen((event) {
      add(RefreshDataEvent(event));
    }, onError: (e, s) {
      // TODO: Handle error
      print('GOT AN ERROR: $e, STACK TRACE:$s');
    });
    _controller.fetchData();
  }

  /// Converts new portion of data to a new data holder
  @protected
  Future<DH> onRefreshData(List<E> data);

  /// Creates new entity to be appended to the end of list
  @protected
  Future<E> createNewEntity();

  @override
  Stream<DataState<E, DH>> mapEventToState(UndoableDataEvent event) async* {
    if (event is RefreshDataEvent<E>) {
      yield DataState(
        current: await onRefreshData(event.data),
        hasUnsavedChanges: _controller.hasUncommittedChanges,
        canSave:
            _controller.hasUncommittedChanges && _validator.isValid(event.data),
      );
    } else if (event is UndoActionEvent) {
      _controller.undo();
    } else if (event is ApplyEvent) {
      await commitChanges();
    } else if (event is AddItemEvent) {
      _controller.add(await createNewEntity());
    } else if (event is UpdateItemEvent<E>) {
      _controller.update(event.original, event.updated);
    } else if (event is DeleteItemEvent<E>) {
      _controller.delete(event.entity);
    }
  }

  /// Commits entered changes. Should be used only to be sure the changes
  /// has committed before screen popped.
  Future<void> commitChanges() => _controller.commit();

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }

  @override
  void dispose() {
    close();
  }
}
