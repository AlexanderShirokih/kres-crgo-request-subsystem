import 'package:bloc_test/bloc_test.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/service/document_service.dart';
import 'package:kres_requests2/presentation/bloc.dart';
import 'package:kres_requests2/presentation/bloc/editor/doc_view/document_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../common_mocks.dart';

class _DocumentServiceMock extends Mock implements DocumentService {}

void main() {
  late DocumentService service;
  late Worksheet worksheet;
  late Document document;

  setUp(() {
    document = DocumentMock();
    worksheet = WorksheetMock();
    service = _DocumentServiceMock();

    when(() => service.document).thenReturn(document);
  });

  blocTest<DocumentBloc, BaseState>(
    'Calls removeWorksheet in service when [WorksheetMasterWorksheetActionEvent] is added',
    build: () => DocumentBloc(service),
    act: (bloc) => bloc.add(
      WorksheetActionEvent(
        worksheet,
        WorksheetAction.remove,
      ),
    ),
    verify: (_) {
      verify(() => service.removeWorksheet(worksheet)).called(1);
    },
  );

  blocTest<DocumentBloc, BaseState>(
    'Calls makeActive in service when [WorksheetMasterWorksheetActionEvent] is added',
    build: () => DocumentBloc(service),
    act: (bloc) => bloc.add(
      WorksheetActionEvent(
        worksheet,
        WorksheetAction.makeActive,
      ),
    ),
    verify: (_) {
      verify(() => service.makeActive(worksheet)).called(1);
    },
  );

  blocTest<DocumentBloc, BaseState>(
    'Add empty worksheet makes call to service',
    build: () => DocumentBloc(service),
    act: (bloc) => bloc.add(const AddNewWorksheetEvent()),
    verify: (_) {
      verify(() => service.addEmptyWorksheet()).called(1);
    },
  );
}
