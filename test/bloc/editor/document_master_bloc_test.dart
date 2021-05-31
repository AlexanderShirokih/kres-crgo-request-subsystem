import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/bloc/editor/document_master_bloc.dart';
import 'package:kres_requests2/bloc/editor/worksheet_creation_mode.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/service/document_service.dart';
import 'package:test/test.dart';

import '../common_mocks.dart';

class _DocumentServiceMock extends Mock implements DocumentService {}

void main() {
  late DocumentService service;
  late Document document;
  late Worksheet worksheet;
  late IModularNavigator navigator;

  setUp(() {
    service = _DocumentServiceMock();
    document = DocumentMock();
    worksheet = WorksheetMock();
    navigator = NavigatorMock();

    when(() => document.workingDirectory).thenAnswer((_) => "cwd/");
    when(() => service.document).thenReturn(document);
    when(() => service.saveDocument(any())).thenAnswer((inv) async* {
      yield DocumentSavingState.pickingSavePath;
      yield DocumentSavingState.saving;
      yield DocumentSavingState.saved;
    });
  });

  blocTest<DocumentMasterBloc, DocumentMasterState>(
    'Calls setSearchFilter in service when [WorksheetMasterSearchEvent] is added',
    build: () => DocumentMasterBloc(service, navigator),
    act: (bloc) => bloc.add(WorksheetMasterSearchEvent('hello')),
    verify: (_) {
      verify(() => service.setSearchFilter('hello')).called(1);
    },
  );

  blocTest<DocumentMasterBloc, DocumentMasterState>(
    'Calls removeWorksheet in service when [WorksheetMasterWorksheetActionEvent] is added',
    build: () => DocumentMasterBloc(service, navigator),
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
    build: () => DocumentMasterBloc(service, navigator),
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
    build: () => DocumentMasterBloc(service, navigator),
    act: (bloc) => bloc.add(
      SaveEvent(changePath: true, popAfterSave: false),
    ),
    expect: () => [
      WorksheetMasterSavingState(document, completed: false),
      WorksheetMasterSavingState(document, completed: true),
      isA<WorksheetMasterIdleState>(),
    ],
    verify: (_) {
      verify(() => service.saveDocument(true)).called(1);
    },
  );

  blocTest<DocumentMasterBloc, DocumentMasterState>(
    'Reacts on document saving with popping',
    build: () => DocumentMasterBloc(service, navigator),
    act: (bloc) => bloc.add(
      SaveEvent(changePath: true, popAfterSave: true),
    ),
    expect: () => [
      WorksheetMasterSavingState(document, completed: false),
      WorksheetMasterSavingState(document, completed: true),
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
      build: () => DocumentMasterBloc(service, navigator),
      act: (bloc) => bloc.add(
        SaveEvent(changePath: true, popAfterSave: true),
      ),
      expect: () => [
        isA<WorksheetMasterSavingState>(),
        isA<WorksheetMasterIdleState>(),
      ],
    );
  });

  blocTest<DocumentMasterBloc, DocumentMasterState>(
    'Add empty worksheet makes call to service',
    build: () => DocumentMasterBloc(service, navigator),
    act: (bloc) => bloc.add(AddNewWorksheetEvent(WorksheetCreationMode.empty)),
    verify: (_) {
      verify(() => service.addEmptyWorksheet()).called(1);
    },
  );

  createTestArguments() => {
        'document': document,
        'workingDirectory': 'cwd/',
      };

  blocTest<DocumentMasterBloc, DocumentMasterState>(
    'Import worksheet event pushes import navigator path',
    build: () => DocumentMasterBloc(service, navigator),
    act: (bloc) => bloc.add(AddNewWorksheetEvent(WorksheetCreationMode.import)),
    verify: (_) {
      verify(
        () => navigator.pushNamed(
          '/document/import/requests',
          arguments: createTestArguments(),
        ),
      ).called(1);
    },
  );

  blocTest<DocumentMasterBloc, DocumentMasterState>(
    'Import counters event pushes counter import navigator path',
    build: () => DocumentMasterBloc(service, navigator),
    act: (bloc) =>
        bloc.add(AddNewWorksheetEvent(WorksheetCreationMode.importCounters)),
    verify: (_) {
      verify(
        () => navigator.pushNamed(
          '/document/import/counters',
          arguments: createTestArguments(),
        ),
      ).called(1);
    },
  );

  blocTest<DocumentMasterBloc, DocumentMasterState>(
    'Native import event pushes document open navigator path',
    build: () => DocumentMasterBloc(service, navigator),
    act: (bloc) =>
        bloc.add(AddNewWorksheetEvent(WorksheetCreationMode.importNative)),
    verify: (_) {
      verify(
        () => navigator.pushNamed(
          '/document/open?pickPages=true',
          arguments: createTestArguments(),
        ),
      ).called(1);
    },
  );
}
