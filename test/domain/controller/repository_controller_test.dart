import 'package:equatable/equatable.dart';
import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/controller/repository_controller.dart';
import 'package:kres_requests2/domain/repository/repository.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class _TestEntity extends Equatable {
  final String label;

  _TestEntity(this.label);

  @override
  List<Object> get props => [label];
}

class _PersistedTestEntity extends _TestEntity implements PersistedObject<int> {
  @override
  final int id;

  _PersistedTestEntity(this.id, String label) : super(label);

  @override
  List<Object> get props => [...super.props, id];
}

class _MockRepository extends Mock implements Repository<_TestEntity> {}

class _TestObjectBuilder implements PersistedObjectBuilder<_TestEntity> {
  @override
  _TestEntity build(key, _TestEntity entity) =>
      _PersistedTestEntity(key, entity.label);
}

void main() {
  EquatableConfig.stringify = true;
  final testEntities = [
    _PersistedTestEntity(1, 'A'),
    _PersistedTestEntity(2, 'B'),
    _PersistedTestEntity(3, 'C'),
  ];

  Repository<_TestEntity> repository;
  RepositoryController<_TestEntity> controller;

  setUp(() {
    repository = _MockRepository();
    controller = RepositoryController(_TestObjectBuilder(), repository);
    when(repository.getAll()).thenAnswer((_) async => testEntities);
  });

  test('getAll() fetches data from repository when no changes', () async {
    expect(await controller.getAll(), equals(testEntities));
    verify(repository.getAll()).called(1);

    expect(await controller.getAll(), equals(testEntities));
    verify(repository.getAll()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('hasUncommittedChanges by default `false`', () {
    expect(controller.hasUncommittedChanges, isFalse);
  });

  test('CRUD functions does not affects repository until committed', () {
    controller.add(_TestEntity('D'));
    controller.delete(_TestEntity('D'));
    controller.update(_TestEntity('D'), _TestEntity('E'));

    verifyZeroInteractions(repository);
  });

  test(
    'Adding item on empty repository will cause add() on repository after commit',
    () async {
      when(repository.getAll()).thenAnswer(
        (_) async => <_PersistedTestEntity>[],
      );

      controller.add(_TestEntity('A'));
      verifyZeroInteractions(repository);

      await expectLater(controller.commit(), completes);
      verify(repository.add(_TestEntity('A')));
      verify(repository.getAll()).called(lessThanOrEqualTo(1));
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'Deleting item on empty repository will not cause action',
    () async {
      when(repository.getAll()).thenAnswer(
        (_) async => <_PersistedTestEntity>[],
      );

      controller.delete(_TestEntity('A'));
      verifyZeroInteractions(repository);

      await expectLater(controller.commit(), completes);
      verify(repository.getAll()).called(lessThanOrEqualTo(1));
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'Adding and then deleting the same item will not cause action',
    () async {
      when(repository.getAll()).thenAnswer(
        (_) async => <_PersistedTestEntity>[],
      );

      controller.add(_TestEntity('A'));
      controller.delete(_TestEntity('A'));
      verifyZeroInteractions(repository);

      await expectLater(controller.commit(), completes);
      verify(repository.getAll()).called(lessThanOrEqualTo(1));
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'Updating item on empty repository will not cause action',
    () async {
      when(repository.getAll()).thenAnswer(
        (_) async => <_PersistedTestEntity>[],
      );

      controller.update(_TestEntity('A'), _TestEntity('B'));
      verifyZeroInteractions(repository);

      await expectLater(controller.commit(), completes);
      verify(repository.getAll()).called(lessThanOrEqualTo(1));
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'Adding and then updating item on empty repository will cause insertion',
    () async {
      when(repository.getAll()).thenAnswer(
        (_) async => <_PersistedTestEntity>[],
      );

      controller.add(_TestEntity('A'));
      controller.update(_TestEntity('A'), _TestEntity('B'));
      verifyZeroInteractions(repository);

      await expectLater(controller.commit(), completes);
      verify(repository.add(_TestEntity('B')));
      verify(repository.getAll()).called(lessThanOrEqualTo(1));
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'Adding and then updating item on present data works as expected',
    () async {
      controller.add(_TestEntity('D'));
      controller.update(_TestEntity('D'), _TestEntity('E'));
      verifyZeroInteractions(repository);

      await expectLater(controller.commit(), completes);
      verify(repository.add(_TestEntity('E')));
      verify(repository.getAll()).called(lessThanOrEqualTo(1));
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'Complex work present data works as expected',
    () async {
      controller.add(_TestEntity('F'));
      controller.update(_PersistedTestEntity(1, 'A'), _TestEntity('D'));
      controller.update(_PersistedTestEntity(1, 'D'), _TestEntity('E'));
      controller.delete(_PersistedTestEntity(2, 'B'));
      verifyZeroInteractions(repository);

      await expectLater(controller.commit(), completes);
      verify(repository.add(_TestEntity('F')));
      verify(repository.update(_PersistedTestEntity(1, 'E')));
      verify(repository.delete(_PersistedTestEntity(2, 'B')));
      verify(repository.getAll()).called(lessThanOrEqualTo(1));
      verifyNoMoreInteractions(repository);
    },
  );

  test('Undo cancels previous operation', () async {
    controller.add(_TestEntity('F'));
    controller.update(_PersistedTestEntity(1, 'A'), _TestEntity('D'));
    controller.update(_PersistedTestEntity(1, 'D'), _TestEntity('E'));
    controller.undo();
    controller.delete(_PersistedTestEntity(2, 'B'));
    controller.undo();
    verifyZeroInteractions(repository);

    await expectLater(controller.commit(), completes);
    verify(repository.add(_TestEntity('F')));
    verify(repository.update(_PersistedTestEntity(1, 'D')));
    verify(repository.getAll()).called(lessThanOrEqualTo(1));
    verifyNoMoreInteractions(repository);
  });
}
