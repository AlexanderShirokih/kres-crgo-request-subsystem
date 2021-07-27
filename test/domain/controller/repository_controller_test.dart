import 'package:equatable/equatable.dart';
import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/controller/repository_controller.dart';
import 'package:kres_requests2/domain/repository/repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _TestEntity extends Equatable {
  final String label;

  const _TestEntity(this.label);

  @override
  List<Object> get props => [label];
}

class _PersistedTestEntity extends _TestEntity implements PersistedObject<int> {
  @override
  final int id;

  const _PersistedTestEntity(this.id, String label) : super(label);

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
  final testEntities = [
    const _PersistedTestEntity(1, 'A'),
    const _PersistedTestEntity(2, 'B'),
    const _PersistedTestEntity(3, 'C'),
  ];

  late Repository<_TestEntity> repository;
  late RepositoryController<_TestEntity> controller;

  setUp(() {
    repository = _MockRepository();
    controller = RepositoryController(_TestObjectBuilder(), repository);
    registerFallbackValue(const _TestEntity("test"));
    when(() => repository.getAll()).thenAnswer((_) async => testEntities);
    when(() => repository.update(any()))
        .thenAnswer((_) async => Future.value());
    when(() => repository.delete(any()))
        .thenAnswer((_) async => Future.value());
    when(() => repository.add(any())).thenAnswer(
      (inv) async => inv.positionalArguments[0],
    );
  });

  test('getAll() fetches data from repository when no changes', () async {
    expect(await controller.getAll(), equals(testEntities));
    verify(() => repository.getAll()).called(1);

    expect(await controller.getAll(), equals(testEntities));
    verify(() => repository.getAll()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('hasUncommittedChanges by default `false`', () {
    expect(controller.hasUncommittedChanges, isFalse);
  });

  test('CRUD functions does not affects repository until committed', () {
    controller.add(const _TestEntity('D'));
    controller.delete(const _TestEntity('D'));
    controller.update(const _TestEntity('D'), const _TestEntity('E'));

    verifyZeroInteractions(repository);
  });

  test(
    'Adding item on empty repository will cause add() on repository after commit',
    () async {
      when(() => repository.getAll()).thenAnswer(
        (_) async => <_PersistedTestEntity>[],
      );

      controller.add(const _TestEntity('A'));
      verifyZeroInteractions(repository);

      await expectLater(controller.commit(), completes);
      verify(() => repository.add(const _TestEntity('A')));
      verify(() => repository.getAll()).called(lessThanOrEqualTo(1));
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'Deleting item on empty repository will not cause action',
    () async {
      when(() => repository.getAll()).thenAnswer(
        (_) async => <_PersistedTestEntity>[],
      );

      controller.delete(const _TestEntity('A'));
      verifyZeroInteractions(repository);

      await expectLater(controller.commit(), completes);
      verify(() => repository.getAll()).called(lessThanOrEqualTo(1));
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'Adding and then deleting the same item will not cause action',
    () async {
      when(() => repository.getAll()).thenAnswer(
        (_) async => <_PersistedTestEntity>[],
      );

      controller.add(const _TestEntity('A'));
      controller.delete(const _TestEntity('A'));
      verifyZeroInteractions(repository);

      await expectLater(controller.commit(), completes);
      verify(() => repository.getAll()).called(lessThanOrEqualTo(1));
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'Updating item on empty repository will not cause action',
    () async {
      when(() => repository.getAll()).thenAnswer(
        (_) async => <_PersistedTestEntity>[],
      );

      controller.update(const _TestEntity('A'), const _TestEntity('B'));
      verifyZeroInteractions(repository);

      await expectLater(controller.commit(), completes);
      verify(() => repository.getAll()).called(lessThanOrEqualTo(1));
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'Adding and then updating item on empty repository will cause insertion',
    () async {
      when(() => repository.getAll()).thenAnswer(
        (_) async => <_PersistedTestEntity>[],
      );

      controller.add(const _TestEntity('A'));
      controller.update(const _TestEntity('A'), const _TestEntity('B'));
      verifyZeroInteractions(repository);

      await expectLater(controller.commit(), completes);
      verify(() => repository.add(const _TestEntity('B')));
      verify(() => repository.getAll()).called(lessThanOrEqualTo(1));
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'Adding and then updating item on present data works as expected',
    () async {
      controller.add(const _TestEntity('D'));
      controller.update(const _TestEntity('D'), const _TestEntity('E'));
      verifyZeroInteractions(repository);

      await expectLater(controller.commit(), completes);
      verify(() => repository.add(const _TestEntity('E')));
      verify(() => repository.getAll()).called(lessThanOrEqualTo(1));
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'Complex work present data works as expected',
    () async {
      controller.add(const _TestEntity('F'));
      controller.update(
          const _PersistedTestEntity(1, 'A'), const _TestEntity('D'));
      controller.update(
          const _PersistedTestEntity(1, 'D'), const _TestEntity('E'));
      controller.delete(const _PersistedTestEntity(2, 'B'));
      verifyZeroInteractions(repository);

      await expectLater(controller.commit(), completes);
      verify(() => repository.add(const _TestEntity('F'))).called(1);
      verify(() => repository.update(const _PersistedTestEntity(1, 'E')))
          .called(1);
      verify(() => repository.delete(const _PersistedTestEntity(2, 'B')))
          .called(1);
      verify(() => repository.getAll()).called(lessThanOrEqualTo(1));
      verifyNoMoreInteractions(repository);
    },
  );

  test('Undo cancels previous operation', () async {
    controller.add(const _TestEntity('F'));
    controller.update(
        const _PersistedTestEntity(1, 'A'), const _TestEntity('D'));
    controller.update(
        const _PersistedTestEntity(1, 'D'), const _TestEntity('E'));
    controller.undo();
    controller.delete(const _PersistedTestEntity(2, 'B'));
    controller.undo();
    verifyZeroInteractions(repository);

    await expectLater(controller.commit(), completes);
    verify(() => repository.add(const _TestEntity('F'))).called(1);
    verify(() => repository.update(const _PersistedTestEntity(1, 'D')))
        .called(1);
    verify(() => repository.getAll()).called(lessThanOrEqualTo(1));
    verifyNoMoreInteractions(repository);
  });

  test('Editing with no changes does not creates editing history', () async {
    await controller.getAll();

    controller.update(
      const _PersistedTestEntity(1, 'A'),
      const _PersistedTestEntity(1, 'A'),
    );

    expect(controller.hasUncommittedChanges, isFalse);

    await controller.commit();

    verify(() => repository.getAll()).called(lessThanOrEqualTo(1));
    verifyNoMoreInteractions(repository);
  });
}
