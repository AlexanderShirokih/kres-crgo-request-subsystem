import 'package:bloc_test/bloc_test.dart';
import 'package:kres_requests2/screens/bloc/editor/editor_view/worksheet_editor_bloc.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/service/worksheet_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../common_mocks.dart';

class _WorksheetServiceMock extends Mock implements WorksheetService {}

void main() {
  late WorksheetService service;
  late Document document;
  late Worksheet worksheet;
  late Request prev;
  late Request curr;

  setUp(() {
    service = _WorksheetServiceMock();
    worksheet = WorksheetMock();
    document = DocumentMock();
    prev = RequestMock();
    curr = RequestMock();

    when(() => worksheet.requests).thenReturn([prev, curr]);
    when(() => service.document).thenReturn(document);

    registerFallbackValue(worksheet);
  });

  blocTest<WorksheetEditorBloc, WorksheetEditorState>(
    'Ensure initial state is correct',
    build: () => WorksheetEditorBloc(service: service),
    verify: (e) => expect(e.state, isA<WorksheetInitialState>()),
  );

  blocTest<WorksheetEditorBloc, WorksheetEditorState>(
    'Emits [WorksheetDataState] when [SetCurrentWorksheetEvent] is added',
    build: () => WorksheetEditorBloc(service: service),
    act: (bloc) => bloc.add(SetCurrentWorksheetEvent(worksheet)),
    expect: () => [
      WorksheetDataState(
        document: document,
        worksheet: worksheet,
        lastGroupIndex: 0,
        groupList: {},
        requests: [prev, curr],
      ),
    ],
    verify: (_) {
      verify(() => service.listenOn(any())).called(1);
    },
  );

  blocTest<WorksheetEditorBloc, WorksheetEditorState>(
    'Calls swapRequest() when [SwapRequestsEvent] added',
    build: () => WorksheetEditorBloc(service: service),
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
