import 'package:bloc_test/bloc_test.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/service/worksheet_service.dart';
import 'package:kres_requests2/presentation/bloc/editor/editor_view/worksheet_bloc.dart';
import 'package:kres_requests2/presentation/bloc/editor/editor_view/worksheet_navigation_routes.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../common_mocks.dart';

class _WorksheetServiceMock extends Mock implements WorksheetService {}

class _WorksheetNavigationRoutesMock extends Mock
    implements WorksheetNavigationRoutes {}

void main() {
  late WorksheetService service;
  late Document document;
  late Worksheet worksheet;
  late Request prev;
  late Request curr;
  late WorksheetNavigationRoutes routes;

  setUp(() {
    routes = _WorksheetNavigationRoutesMock();
    service = _WorksheetServiceMock();
    worksheet = WorksheetMock();
    document = DocumentMock();
    prev = RequestMock();
    curr = RequestMock();

    when(() => worksheet.requests).thenReturn([prev, curr]);
    when(() => service.document).thenReturn(document);

    registerFallbackValue(worksheet);
  });

  blocTest<WorksheetBloc, WorksheetState>(
    'Ensure initial state is correct',
    build: () => WorksheetBloc(service, routes),
    verify: (e) => expect(e.state, isA<WorksheetInitialState>()),
  );

  blocTest<WorksheetBloc, WorksheetState>(
    'Emits [WorksheetDataState] when [SetCurrentWorksheetEvent] is added',
    build: () => WorksheetBloc(service, routes),
    act: (bloc) => bloc.add(SetCurrentWorksheetEvent(worksheet)),
    expect: () => [
      WorksheetDataState(
        document: document,
        worksheet: worksheet,
        lastGroupIndex: 0,
        groupList: const {},
        requests: [prev, curr],
      ),
    ],
    verify: (_) {
      verify(() => service.listenOn(any())).called(1);
    },
  );

  blocTest<WorksheetBloc, WorksheetState>(
    'Calls swapRequest() when [SwapRequestsEvent] added',
    build: () => WorksheetBloc(service, routes),
    seed: () => WorksheetDataState(
      document: document,
      worksheet: worksheet,
      requests: [prev, curr],
    ),
    act: (bloc) => bloc.add(SwapRequestsEvent(from: prev, to: curr)),
    verify: (_) {
      verify(() => service.swapRequest(worksheet, prev, curr)).called(1);
    },
  );
}
