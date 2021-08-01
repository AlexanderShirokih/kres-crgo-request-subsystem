import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/service/request_service.dart';
import 'package:kres_requests2/presentation/bloc.dart';
import 'package:kres_requests2/presentation/bloc/editor/requests_move_dialog/requests_move_dialog_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../common_mocks.dart';

class _RequestServiceMock extends Mock implements RequestService {}

void main() {
  late RequestService service;
  late Worksheet worksheet;
  late Document document;
  late IModularNavigator navigator;

  MoveSource getSource() => MoveSource(document, worksheet);

  setUp(() {
    service = _RequestServiceMock();
    worksheet = WorksheetMock();
    navigator = NavigatorMock();
    document = DocumentMock();

    registerFallbackValue(worksheet);
    when(() => service.getTargetWorksheets(any()))
        .thenReturn(const Iterable.empty());
  });

  blocTest<RequestsMoveDialogBloc, BaseState>(
    'Emits [DataState<RequestsMoveDialogData>] when [FetchDataEvent] is added ',
    build: () => RequestsMoveDialogBloc(service, navigator),
    act: (bloc) => bloc.add(FetchDataEvent(getSource())),
    expect: () => [
      isA<DataState<RequestsMoveDialogData>>(),
    ],
    verify: (_) {
      verify(() => service.getTargetWorksheets(worksheet)).called(1);
    },
  );

  blocTest<RequestsMoveDialogBloc, BaseState>(
    'Moves requests when [MoveRequestsEvent] is added ',
    build: () => RequestsMoveDialogBloc(service, navigator),
    seed: () => DataState(RequestsMoveDialogData(getSource(), const [])),
    act: (bloc) => bloc.add(
      MoveRequestsEvent(
        requests: const [],
        removeFromSource: false,
        targetDocument: document,
        targetWorksheet: null,
      ),
    ),
    verify: (_) {
      verify(
        () => service.moveRequests(
          removeFromSource: false,
          requests: [],
          targetWorksheet: any(named: "targetWorksheet"),
          targetDocument: any(named: "targetDocument"),
          source: getSource(),
        ),
      ).called(1);

      verify(() => navigator.pop()).called(1);
    },
  );
}
