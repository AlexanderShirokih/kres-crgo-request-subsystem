import 'package:equatable/equatable.dart';
import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/controller/repository_controller.dart';
import 'package:kres_requests2/domain/controller/streamed_controller.dart';
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

class _MockRepositoryController extends Mock
    implements AbstractRepositoryController<_TestEntity> {}

void main() {
  late AbstractRepositoryController<_TestEntity> mockController;
  late StreamedRepositoryController<_TestEntity> streamedController;

  setUp(() {
    mockController = _MockRepositoryController();

    streamedController = StreamedRepositoryController(mockController);

    when(() => mockController.hasUncommittedChanges).thenReturn(true);
    when(() => mockController.commit()).thenAnswer((_) async => true);
    when(() => mockController.getAll()).thenAnswer(
      (_) async => [
        const _PersistedTestEntity(1, 'A'),
      ],
    );
  });

  test('all methods call their proxies', () {
    const testEntity = _TestEntity('test');
    const testEntity2 = _TestEntity('test2');

    streamedController.add(testEntity);
    verify(() => mockController.add(testEntity)).called(1);

    streamedController.update(testEntity, testEntity2);
    verify(() => mockController.update(testEntity, testEntity2)).called(1);

    streamedController.delete(testEntity2);
    verify(() => mockController.delete(testEntity2)).called(1);

    streamedController.undo();
    verify(() => mockController.undo()).called(1);

    streamedController.commit();
    verify(() => mockController.commit()).called(1);

    streamedController.hasUncommittedChanges;
    verify(() => mockController.hasUncommittedChanges).called(1);

    streamedController.getAll();
    verify(() => mockController.getAll()).called(greaterThan(1));
  });
}
