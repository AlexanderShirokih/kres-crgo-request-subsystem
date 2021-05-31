import 'package:bloc_test/bloc_test.dart';
import 'package:kres_requests2/bloc/editor/worksheet_config_view/worksheet_config_bloc.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/service/worksheet_service.dart';
import 'package:kres_requests2/screens/bloc.dart';
import 'package:test/test.dart';

import '../../common_mocks.dart';

class _WorksheetEditorServiceMock extends Mock implements WorksheetService {}

class _WorksheetConfigInfoMock extends Mock implements WorksheetConfigInfo {}

class _EmployeeMock extends Mock implements Employee {}

void main() {
  late WorksheetService service;
  late Worksheet worksheet;
  late WorksheetConfigInfo config;
  late Employee employee;

  setUp(() {
    service = _WorksheetEditorServiceMock();
    worksheet = WorksheetMock();
    config = _WorksheetConfigInfoMock();
    employee = _EmployeeMock();

    registerFallbackValue(worksheet);
    when(() => service.listenOnActive())
        .thenAnswer((_) => Stream.value(worksheet));
    when(() => service.getWorksheetInfo(any())).thenAnswer((_) async => config);
    when(() => config.worksheet).thenReturn(worksheet);
  });

  blocTest<WorksheetConfigBloc, BaseState>(
    'Listens active stream',
    build: () => WorksheetConfigBloc(service),
    verify: (_) {
      verify(() => service.listenOnActive()).called(1);
    },
  );

  blocTest<WorksheetConfigBloc, BaseState>(
    'Emits [DataState<WorksheetConfigInfo>] when [FetchDataEvent] is added ',
    build: () => WorksheetConfigBloc(service),
    act: (bloc) => bloc.add(FetchDataEvent(worksheet)),
    expect: () => [
      isA<DataState<WorksheetConfigInfo>>(),
    ],
    verify: (_) {
      verify(() => service.getWorksheetInfo(worksheet))
          .called(greaterThanOrEqualTo(1));
    },
  );

  blocTest<WorksheetConfigBloc, BaseState>(
    'Updates main employee in service when [UpdateSingleEmployeeEvent] is added ',
    build: () => WorksheetConfigBloc(service),
    seed: () => DataState(config),
    act: (bloc) => bloc.add(
      UpdateSingleEmployeeEvent(
        employee,
        SingleEmployeeType.main,
      ),
    ),
    verify: (_) {
      verify(() => service.updateMainEmployee(worksheet, employee)).called(1);
    },
  );

  blocTest<WorksheetConfigBloc, BaseState>(
    'Updates chief employee in service when [UpdateSingleEmployeeEvent] is added ',
    build: () => WorksheetConfigBloc(service),
    seed: () => DataState(config),
    act: (bloc) => bloc.add(
      UpdateSingleEmployeeEvent(
        employee,
        SingleEmployeeType.chief,
      ),
    ),
    verify: (_) {
      verify(() => service.updateChiefEmployee(worksheet, employee)).called(1);
    },
  );

  final dateTime = DateTime.now();

  blocTest<WorksheetConfigBloc, BaseState>(
    'Updates target date in service when [UpdateTargetDateEvent] is added ',
    build: () => WorksheetConfigBloc(service),
    seed: () => DataState(config),
    act: (bloc) => bloc.add(UpdateTargetDateEvent(dateTime)),
    verify: (_) {
      verify(() => service.updateTargetDate(worksheet, dateTime)).called(1);
    },
  );

  final members = <Employee>{};
  blocTest<WorksheetConfigBloc, BaseState>(
    'Updates team members in service when [UpdateMembersEvent] is added ',
    build: () => WorksheetConfigBloc(service),
    seed: () => DataState(config),
    act: (bloc) => bloc.add(UpdateMembersEvent(members)),
    verify: (_) {
      verify(() => service.updateTeamMembers(worksheet, members)).called(1);
    },
  );

  final workTypes = <String>{};
  blocTest<WorksheetConfigBloc, BaseState>(
    'Updates work types in service when [UpdateWorkTypesEvent] is added ',
    build: () => WorksheetConfigBloc(service),
    seed: () => DataState(config),
    act: (bloc) => bloc.add(UpdateWorkTypesEvent(workTypes)),
    verify: (_) {
      verify(() => service.updateWorkTypes(worksheet, workTypes)).called(1);
    },
  );
}
