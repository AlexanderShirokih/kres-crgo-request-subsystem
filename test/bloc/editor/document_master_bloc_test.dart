import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/bloc/editor/document_master_bloc.dart';
import 'package:kres_requests2/bloc/editor/worksheet_creation_mode.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/service/document_manager.dart';
import 'package:kres_requests2/domain/service/document_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../common_mocks.dart';

class _DocumentServiceFactoryMock extends Mock
    implements DocumentServiceFactory {}

class _DocumentServiceMock extends Mock implements DocumentService {}

class _DocumentManagerMock extends Mock implements DocumentManager {}

void main() {
  late DocumentManager documentManager;
  late DocumentService service;
  late DocumentServiceFactory serviceFactory;
  late Document document;
  late Worksheet worksheet;
  late IModularNavigator navigator;

  setUp(() {
    documentManager = _DocumentManagerMock();
    serviceFactory = _DocumentServiceFactoryMock();
    service = _DocumentServiceMock();
    document = DocumentMock();
    worksheet = WorksheetMock();
    navigator = NavigatorMock();

    when(() => serviceFactory.createDocumentService(document))
        .thenReturn(service);
    when(() => service.document).thenReturn(document);
    when(() => service.saveDocument(any())).thenAnswer((inv) async* {
      yield DocumentSavingState.pickingSavePath;
      yield DocumentSavingState.saving;
      yield DocumentSavingState.saved;
    });
  });

  blocTest<DocumentMasterBloc, DocumentMasterState>(
    'Calls setSearchFilter in service when [WorksheetMasterSearchEvent] is added',
    build: () => DocumentMasterBloc(documentManager, serviceFactory, navigator),
    act: (bloc) => bloc.add(WorksheetMasterSearchEvent('hello')),
    verify: (_) {
      fail("Unimplemented!");
      // verify(() => service.setSearchFilter('hello')).called(1);
    },
  );

  blocTest<DocumentMasterBloc, DocumentMasterState>(
    'Calls removeWorksheet in service when [WorksheetMasterWorksheetActionEvent] is added',
    build: () => DocumentMasterBloc(documentManager, serviceFactory, navigator),
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

  blocTest<DocumentMasterBloc, DocumentMasterState>(
    'Calls makeActive in service when [WorksheetMasterWorksheetActionEvent] is added',
    build: () => DocumentMasterBloc(documentManager, serviceFactory, navigator),
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

  blocTest<DocumentMasterBloc, DocumentMasterState>(
    'Reacts on document saving w/o popping',
    build: () => DocumentMasterBloc(documentManager, serviceFactory, navigator),
    act: (bloc) => bloc.add(
      SaveEvent(changePath: true, popAfterSave: false),
    ),
    expect: () => [
      // TODO: Fix expects
    ],
    verify: (_) {
      verify(() => service.saveDocument(true)).called(1);
    },
  );

  blocTest<DocumentMasterBloc, DocumentMasterState>(
    'Reacts on document saving with popping',
    build: () => DocumentMasterBloc(documentManager, serviceFactory, navigator),
    act: (bloc) => bloc.add(
      SaveEvent(changePath: true, popAfterSave: true),
    ),
    expect: () => [
      // TODO: Fix expects
    ],
    verify: (_) {
      verify(() => service.saveDocument(true)).called(1);
      verify(() => navigator.pop());
    },
  );

  group('Error test', () {
    setUp(() {
      service = _DocumentServiceMock();
      document = DocumentMock();
      when(() => document.workingDirectory).thenAnswer((_) => "cwd/");
      when(() => service.document).thenReturn(document);
      when(() => service.saveDocument(any())).thenThrow("Saving error");
    });

    blocTest<DocumentMasterBloc, DocumentMasterState>(
      'Reacts on document saving with error',
      build: () =>
          DocumentMasterBloc(documentManager, serviceFactory, navigator),
      act: (bloc) => bloc.add(
        SaveEvent(changePath: true, popAfterSave: true),
      ),
      expect: () => [
        // TODO: Fix expects
      ],
    );
  });

  blocTest<DocumentMasterBloc, DocumentMasterState>(
    'Add empty worksheet makes call to service',
    build: () => DocumentMasterBloc(documentManager, serviceFactory, navigator),
    act: (bloc) => bloc.add(AddNewWorksheetEvent(WorksheetCreationMode.empty)),
    verify: (_) {
      verify(() => service.addEmptyWorksheet()).called(1);
    },
  );

  blocTest<DocumentMasterBloc, DocumentMasterState>(
    'Import worksheet event pushes import navigator path',
    build: () => DocumentMasterBloc(documentManager, serviceFactory, navigator),
    act: (bloc) => bloc.add(AddNewWorksheetEvent(WorksheetCreationMode.import)),
    verify: (_) {
      verify(
        () => navigator.pushNamed('/document/import/requests'),
      ).called(1);
    },
  );

  blocTest<DocumentMasterBloc, DocumentMasterState>(
    'Import counters event pushes counter import navigator path',
    build: () => DocumentMasterBloc(documentManager, serviceFactory, navigator),
    act: (bloc) =>
        bloc.add(AddNewWorksheetEvent(WorksheetCreationMode.importCounters)),
    verify: (_) {
      verify(
        () => navigator.pushNamed('/document/import/counters'),
      ).called(1);
    },
  );

  blocTest<DocumentMasterBloc, DocumentMasterState>(
    'Native import event pushes document open navigator path',
    build: () => DocumentMasterBloc(documentManager, serviceFactory, navigator),
    act: (bloc) =>
        bloc.add(AddNewWorksheetEvent(WorksheetCreationMode.importNative)),
    verify: (_) {
      verify(
        () => navigator.pushNamed('/document/open?pickPages=true'),
      ).called(1);
    },
  );
}
