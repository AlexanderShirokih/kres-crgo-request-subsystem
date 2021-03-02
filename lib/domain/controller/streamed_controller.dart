import 'dart:async';

import 'repository_controller.dart';

class StreamedRepositoryController<E>
    implements AbstractRepositoryController<E> {
  final AbstractRepositoryController<E> _underlyingController;
  final StreamController<List<E>> _streamController = StreamController();

  StreamedRepositoryController(this._underlyingController);

  /// Returns stream that tracks changes in controller
  Stream<List<E>> get stream => _streamController.stream;

  void fetchData() {
    _underlyingController
        .getAll()
        .then((value) => _streamController.add(value))
        .catchError((e, s) => _streamController.addError(e, s));
  }

  @override
  void add(E entity) {
    _underlyingController.add(entity);
    fetchData();
  }

  @override
  Future<void> commit() async {
    await _underlyingController.commit();
    fetchData();
  }

  @override
  void delete(E entity) {
    _underlyingController.delete(entity);
    fetchData();
  }

  @override
  Future<List<E>> getAll() => _underlyingController.getAll();

  @override
  bool get hasUncommittedChanges => _underlyingController.hasUncommittedChanges;

  @override
  void undo() {
    _underlyingController.undo();
    fetchData();
  }

  @override
  void update(E old, E edited) {
    _underlyingController.update(old, edited);
    fetchData();
  }

  Future<void> close() => _streamController.close();
}
