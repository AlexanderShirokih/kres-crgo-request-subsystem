import 'package:bloc_test/bloc_test.dart';
import 'package:kres_requests2/presentation/bloc/editor/request_editor_dialog/request_editor_bloc.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/service/request_service.dart';
import 'package:kres_requests2/presentation/bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../common_mocks.dart';

class _RequestEditorServiceMock extends Mock implements RequestService {}

void main() {
  late RequestService service;
  late Document document;
  late Worksheet worksheet;
  late Request request;

  setUp(() {
    service = _RequestEditorServiceMock();
    document = DocumentMock();
    worksheet = WorksheetMock();
    request = RequestMock();

    when(() => service.createTemporaryRequest()).thenReturn(request);
    when(() => service.fetchRequestTypes(any())).thenAnswer((_) async => []);
  });

  blocTest<RequestEditorBloc, BaseState>(
    'Emits [DataState<RequestEditorData>] when [SetRequestEvent] is added '
    'and request not present',
    build: () => RequestEditorBloc(service: service),
    act: (bloc) => bloc.add(SetRequestEvent(
      worksheet: worksheet,
      document: document,
    )),
    expect: () => [
      isA<DataState<RequestEditorData>>(),
    ],
    verify: (_) {
      verify(() => service.fetchRequestTypes(any())).called(1);
      verify(() => service.createTemporaryRequest()).called(1);
    },
  );

  blocTest<RequestEditorBloc, BaseState>(
    'Emits [DataState<RequestEditorData>] when [SetRequestEvent] is added '
    'and request is present',
    build: () => RequestEditorBloc(service: service),
    act: (bloc) => bloc.add(SetRequestEvent(
      worksheet: worksheet,
      document: document,
      request: request,
    )),
    expect: () => [
      isA<DataState<RequestEditorData>>(),
    ],
    verify: (_) {
      verify(() => service.fetchRequestTypes(any())).called(1);
      verifyNoMoreInteractions(service);
    },
  );
}
