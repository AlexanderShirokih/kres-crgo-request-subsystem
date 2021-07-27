import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/service/document_manager.dart';
import 'package:kres_requests2/presentation/bloc/editor/document_master_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../common_mocks.dart';

class _DocumentManagerMock extends Mock implements DocumentManager {}

void main() {
  late DocumentManager documentManager;
  late Document document;
  late IModularNavigator navigator;

  setUp(() {
    documentManager = _DocumentManagerMock();
    document = DocumentMock();
    navigator = NavigatorMock();

    when(() => documentManager.save(document, changePath: any()))
        .thenAnswer((inv) async* {
      yield DocumentSavingState.pickingSavePath;
      yield DocumentSavingState.saving;
      yield DocumentSavingState.saved;
    });
  });

  blocTest<DocumentMasterBloc, DocumentMasterState>(
    'Calls setSearchFilter in service when [WorksheetMasterSearchEvent] is added',
    build: () => DocumentMasterBloc(documentManager, navigator),
    act: (bloc) => bloc.add(const WorksheetMasterSearchEvent('hello')),
    verify: (_) {
      fail("Unimplemented!");
      // verify(() => service.setSearchFilter('hello')).called(1);
    },
  );

  blocTest<DocumentMasterBloc, DocumentMasterState>(
    'Reacts on document saving w/o popping',
    build: () => DocumentMasterBloc(documentManager, navigator),
    act: (bloc) => bloc.add(
      const SaveEvent(changePath: true, popAfterSave: false),
    ),
    expect: () => [
      // TODO: Fix expects
    ],
    verify: (_) {
      verify(() => documentManager.save(document, changePath: true)).called(1);
    },
  );

  blocTest<DocumentMasterBloc, DocumentMasterState>(
    'Reacts on document saving with popping',
    build: () => DocumentMasterBloc(documentManager, navigator),
    act: (bloc) => bloc.add(
      const SaveEvent(changePath: true, popAfterSave: true),
    ),
    expect: () => [
      // TODO: Fix expects
    ],
    verify: (_) {
      verify(() => documentManager.save(document, changePath: true)).called(1);
      verify(() => navigator.pop());
    },
  );

  group('Error test', () {
    setUp(() {
      document = DocumentMock();
      when(() => document.workingDirectory).thenAnswer((_) => "cwd/");
      when(() => documentManager.save(any(), changePath: any()))
          .thenThrow("Saving error");
    });

    blocTest<DocumentMasterBloc, DocumentMasterState>(
      'Reacts on document saving with error',
      build: () => DocumentMasterBloc(documentManager, navigator),
      act: (bloc) => bloc.add(
        const SaveEvent(changePath: true, popAfterSave: true),
      ),
      expect: () => [
        // TODO: Fix expects
      ],
    );
  });
}
