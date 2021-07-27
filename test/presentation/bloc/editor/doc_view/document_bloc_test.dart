import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/service/document_service.dart';
import 'package:kres_requests2/presentation/bloc.dart';
import 'package:kres_requests2/presentation/bloc/editor/doc_view/document_bloc.dart';
import 'package:kres_requests2/presentation/bloc/editor/doc_view/worksheet_creation_mode.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../common_mocks.dart';

class _DocumentServiceMock extends Mock implements DocumentService {}

void main() {
  late DocumentService service;
  late IModularNavigator navigator;
  late Worksheet worksheet;
  late Document document;

  setUp(() {
    document = DocumentMock();
    worksheet = WorksheetMock();
    service = _DocumentServiceMock();
    navigator = NavigatorMock();

    when(() => service.document).thenReturn(document);
  });

  blocTest<DocumentBloc, BaseState>(
    'Calls removeWorksheet in service when [WorksheetMasterWorksheetActionEvent] is added',
    build: () => DocumentBloc(service, navigator),
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
    build: () => DocumentBloc(service, navigator),
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
    build: () => DocumentBloc(service, navigator),
    act: (bloc) =>
        bloc.add(const AddNewWorksheetEvent(WorksheetCreationMode.empty)),
    verify: (_) {
      verify(() => service.addEmptyWorksheet()).called(1);
    },
  );

  blocTest<DocumentBloc, BaseState>(
    'Import worksheet event pushes import navigator path',
    build: () => DocumentBloc(service, navigator),
    act: (bloc) =>
        bloc.add(const AddNewWorksheetEvent(WorksheetCreationMode.import)),
    verify: (_) {
      verify(
        () => navigator.pushNamed('/document/import/requests'),
      ).called(1);
    },
  );

  blocTest<DocumentBloc, BaseState>(
    'Import counters event pushes counter import navigator path',
    build: () => DocumentBloc(service, navigator),
    act: (bloc) => bloc
        .add(const AddNewWorksheetEvent(WorksheetCreationMode.importCounters)),
    verify: (_) {
      verify(
        () => navigator.pushNamed('/document/import/counters'),
      ).called(1);
    },
  );

  blocTest<DocumentBloc, BaseState>(
    'Native import event pushes document open navigator path',
    build: () => DocumentBloc(service, navigator),
    act: (bloc) => bloc
        .add(const AddNewWorksheetEvent(WorksheetCreationMode.importNative)),
    verify: (_) {
      verify(
        () => navigator.pushNamed('/document/open?pickPages=true'),
      ).called(1);
    },
  );
}
