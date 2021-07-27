import 'package:bloc_test/bloc_test.dart';
import 'package:kres_requests2/presentation/bloc/editor/requests_move_dialog/requests_move_dialog_bloc.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/service/request_service.dart';
import 'package:kres_requests2/presentation/bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../common_mocks.dart';

class _RequestServiceMock extends Mock implements RequestService {}

void main() {
  late RequestService service;
  late Worksheet worksheet;

  setUp(() {
    service = _RequestServiceMock();
    worksheet = WorksheetMock();

    registerFallbackValue(worksheet);
    when(() => service.getTargetWorksheets(any())).thenReturn(Iterable.empty());
  });

  blocTest<RequestsMoveDialogBloc, BaseState>(
    'Emits [DataState<RequestsMoveDialogData>] when [FetchDataEvent] is added ',
    build: () => RequestsMoveDialogBloc(service),
    act: (bloc) => bloc.add(FetchDataEvent(worksheet)),
    expect: () => [
      isA<DataState<RequestsMoveDialogData>>(),
    ],
    verify: (_) {
      verify(() => service.getTargetWorksheets(worksheet)).called(1);
    },
  );

  blocTest<RequestsMoveDialogBloc, BaseState>(
    'Moves requests when [MoveRequestsEvent] is added ',
    build: () => RequestsMoveDialogBloc(service),
    seed: () => DataState(RequestsMoveDialogData(worksheet, [])),
    expect: () => [CompletedState()],
    act: (bloc) => bloc.add(
      MoveRequestsEvent(
        requests: [],
        removeFromSource: false,
      ),
    ),
    verify: (_) {
      verify(
        () => service.moveRequests(
          removeFromSource: false,
          requests: [],
          target: any(named: "target"),
          source: worksheet,
        ),
      ).called(1);
    },
  );
}
