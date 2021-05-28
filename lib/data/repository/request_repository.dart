import 'package:kres_requests2/domain/controller/worksheet_editor.dart';
import 'package:kres_requests2/domain/models/request_entity.dart';
import 'package:kres_requests2/domain/repository/repository.dart';

/// Repository implementation for managing [RequestEntity]'s in locale paged
/// scope
/// TODO: REMOVE!
class DocumentRequestEntityRepository extends Repository<RequestEntity> {
  final WorksheetEditor _worksheetEditor;

  DocumentRequestEntityRepository(this._worksheetEditor);

  @override
  Future<RequestEntity> add(RequestEntity entity) {
    return Future.sync(() {
      _worksheetEditor.addAll([entity]);
      return entity;
    });
  }

  @override
  Future<void> delete(RequestEntity entity) {
    return Future.sync(() => _worksheetEditor.removeRequests([entity]));
  }

  @override
  Future<List<RequestEntity>> getAll() {
    return Future.value(_worksheetEditor.current.requests);
  }

  @override
  Future<void> update(RequestEntity entity) {
    return Future.sync(() => _worksheetEditor.update(entity));
  }

  @override
  Future<void> onCommit() {
    return Future.sync(() => _worksheetEditor.commit());
  }
}
