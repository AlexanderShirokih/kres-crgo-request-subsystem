import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/repository/repository.dart';
import 'package:meta/meta.dart';

@sealed
abstract class _EditorAction<E> {
  void applyToList(List<E> data);
}

class _InsertEntity<E> extends Equatable implements _EditorAction<E> {
  final E newEntity;

  _InsertEntity(this.newEntity);

  @override
  void applyToList(List<E> data) {
    data.add(newEntity);
  }

  @override
  List<Object?> get props => [newEntity];
}

class _DeleteEntity<E> extends Equatable implements _EditorAction<E> {
  final E entity;

  _DeleteEntity(this.entity);

  @override
  void applyToList(List<E> data) {
    if (!data.remove(entity) && entity is PersistedObject) {
      final pEntity = entity as PersistedObject;
      data.removeWhere(
        (element) => element is PersistedObject && element.id == pEntity.id,
      );
    }
  }

  @override
  List<Object?> get props => [entity];
}

class _UpdateEntity<E> extends Equatable implements _EditorAction<E> {
  final PersistedObjectBuilder<E> _persistedObjectBuilder;
  final E old;
  final E edited;

  _UpdateEntity(this.old, this.edited, this._persistedObjectBuilder);

  @override
  void applyToList(List<E> data) {
    if (old is! PersistedObject) {
      if (data.remove(old)) {
        data.add(edited);
      }
    } else {
      final pOld = old as PersistedObject;
      int toRemove = data.indexWhere(
          (element) => element is PersistedObject && (element).id == pOld.id);
      if (toRemove != -1) {
        data[toRemove] =
            _persistedObjectBuilder.build((old as PersistedObject).id, edited);
      }
    }
  }

  @override
  List<Object?> get props => [old, edited];
}

/// Factory that builds `E extends PersistedEntity`
abstract class PersistedObjectBuilder<E> {
  /// Build new persisted entity with key [key] and data from [entity]
  /// Returns `E extends PersistedEntity`
  E build(dynamic key, E entity);
}

/// An abstraction that can keep changes before they committed to the repository
abstract class AbstractRepositoryController<E> {
  /// Returns all items with actual updates
  Future<List<E>> getAll();

  /// Returns `true` if operations history is not empty
  bool get hasUncommittedChanges;

  /// Adds new entity to editing history
  void add(E entity);

  /// Deletes entity from editing
  void delete(E entity);

  /// Updates existing entity
  void update(E old, E edited);

  /// Undoes one action
  void undo();

  /// Applies all modifications to repository
  /// Returns `true` if some modifications were made
  Future<bool> commit();
}

class RepositoryController<E> implements AbstractRepositoryController<E> {
  final Repository<E> _repository;
  final PersistedObjectBuilder<E> _persistedObjectBuilder;

  final ListQueue<_EditorAction<E>> _operations = ListQueue();

  List<E>? _data;

  RepositoryController(
    this._persistedObjectBuilder,
    this._repository,
  );

  Future<List<E>> _requireData() async {
    return _data ??= await _repository.getAll();
  }

  @override
  Future<List<E>> getAll() async {
    if (_data == null || !hasUncommittedChanges) {
      _data = await _repository.getAll();
    }

    return _applyOperations(_data!);
  }

  /// Returns `true` if operations history is not empty
  @override
  bool get hasUncommittedChanges {
    if (_operations.isEmpty) {
      return false;
    }

    if (_data != null) {
      final modifiedList = _applyOperations(_data!);
      return !IterableEquality().equals(_data, modifiedList);
    }
    return true;
  }

  /// Adds new entity to editing history
  @override
  void add(E entity) => _addOperation(_InsertEntity(entity));

  /// Deletes entity from editing
  @override
  void delete(E entity) => _addOperation(_DeleteEntity(entity));

  /// Updates existing entity
  @override
  void update(E old, E edited) =>
      _addOperation(_UpdateEntity(old, edited, _persistedObjectBuilder));

  /// Undoes one operation
  @override
  void undo() {
    if (_operations.isNotEmpty) {
      _operations.removeLast();
    }
  }

  @override
  Future<bool> commit() async {
    if (hasUncommittedChanges) {
      await _commitOperations();
      _operations.clear();
      _data = null;
      return true;
    }
    return false;
  }

  void _addOperation(_EditorAction<E> operation) => _operations.add(operation);

  List<E> _applyOperations(List<E>? source) {
    final copy = source == null ? <E>[] : List.of(source);
    final iterator = _operations.iterator;

    while (iterator.moveNext()) {
      iterator.current.applyToList(copy);
    }

    return copy;
  }

  Future<void> _commitOperations() =>
      _requireData().then(_applyOperations).then(_applyChanges);

  Future<void> _applyChanges(List<E> data) async {
    for (final updates in data) {
      if (updates is! PersistedObject) {
        // Entity to be inserted
        await _repository.add(updates);
      } else {
        if (_data == null) {
          throw 'Ghost detected!';
        }

        final updateId = updates.id;
        final currentIdx = _data!
            .cast<PersistedObject>()
            .indexWhere((element) => element.id == updateId);

        if (currentIdx != -1 && _data![currentIdx] != updates) {
          // Entity was updated
          await _repository.update(updates);
        }
      }
    }

    final existing = data.whereType<PersistedObject>();

    // Find deleted objects
    if (_data != null) {
      for (final toDelete in _data!
          .cast<PersistedObject>()
          .where((e) => !existing.any((newList) => newList.id == e.id))) {
        await _repository.delete(toDelete as E);
      }
    }
  }
}
