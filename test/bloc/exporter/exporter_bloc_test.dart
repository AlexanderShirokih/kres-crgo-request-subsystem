import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kres_requests2/screens/bloc/exporter/exporter_bloc.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/service/export_service.dart';
import 'package:mocktail/mocktail.dart';

import '../common_mocks.dart';

class _ExportServiceMock extends Mock implements ExportService {}

void main() {
  late ExportService service;

  setUp(() {
    service = _ExportServiceMock();
    when(() => service.isAvailable()).thenAnswer((_) async => true);
  });

  blocTest<ExporterBloc, ExporterState>(
    'Initially is in Idle state',
    build: () => ExporterBloc(service: service),
    verify: (bloc) {
      expect(bloc.state, isA<ExporterIdle>());
    },
  );

  group('Missing exporter', () {
    late ExportService service;
    late Document document;

    setUp(() {
      service = _ExportServiceMock();
      document = DocumentMock();

      when(() => service.isAvailable()).thenAnswer((_) async => false);
    });

    blocTest<ExporterBloc, ExporterState>(
      'Yields [ExporterMissingState] on [ExportEvent] and unavailable service',
      build: () => ExporterBloc(service: service),
      act: (bloc) => bloc..add(ExportEvent(ExportFormat.pdf, document)),
      expect: () => [ExporterMissingState()],
    );

    blocTest<ExporterBloc, ExporterState>(
      'Yields [ExporterMissingState] on [ShowPrintersListEvent] and unavailable service',
      build: () => ExporterBloc(service: service),
      act: (bloc) => bloc..add(ShowPrintersListEvent()),
      expect: () => [ExporterMissingState()],
    );

    blocTest<ExporterBloc, ExporterState>(
      'Yields [ExporterMissingState] on [PrintDocumentEvent] and unavailable service',
      build: () => ExporterBloc(service: service),
      act: (bloc) => bloc..add(PrintDocumentEvent(document, 'printer', false)),
      expect: () => [ExporterMissingState()],
    );
  });

  group('Export (normal)', () {
    late ExportService service;
    late Document document;

    setUp(() {
      service = _ExportServiceMock();
      document = DocumentMock();

      when(() => service.isAvailable()).thenAnswer((_) async => true);
      when(() => service.exportDocument(document, ExportFormat.pdf))
          .thenAnswer((i) async* {
        yield ExportState.pickingFile;
        yield ExportState.exporting;
        yield ExportState.done;
      });
    });

    blocTest<ExporterBloc, ExporterState>(
      'Emits right states when export completes normally',
      build: () => ExporterBloc(service: service),
      act: (bloc) => bloc..add(ExportEvent(ExportFormat.pdf, document)),
      expect: () => [
        isA<ExporterIdle>(),
        isA<ExporterIdle>(),
        ExporterClosingState(isCompleted: true),
      ],
    );
  });

  group('Export (cancelled)', () {
    late ExportService service;
    late Document document;

    setUp(() {
      service = _ExportServiceMock();
      document = DocumentMock();

      when(() => service.isAvailable()).thenAnswer((_) async => true);
      when(() => service.exportDocument(document, ExportFormat.excel))
          .thenAnswer((i) async* {
        yield ExportState.pickingFile;
        yield ExportState.cancelled;
      });
    });

    blocTest<ExporterBloc, ExporterState>(
      'Emits right states when export cancels',
      build: () => ExporterBloc(service: service),
      act: (bloc) => bloc..add(ExportEvent(ExportFormat.excel, document)),
      expect: () => [
        isA<ExporterIdle>(),
        ExporterClosingState(isCompleted: false),
      ],
    );
  });

  group('Export (error)', () {
    late ExportService service;
    late Document document;

    setUp(() {
      service = _ExportServiceMock();
      document = DocumentMock();

      when(() => service.isAvailable()).thenAnswer((_) async => true);
      when(() => service.exportDocument(document, ExportFormat.pdf))
          .thenAnswer((i) async* {
        yield ExportState.pickingFile;
        throw ExportServiceException("error", "stack trace");
      });
    });

    blocTest<ExporterBloc, ExporterState>(
      'Emits right states when export finishes with error',
      build: () => ExporterBloc(service: service),
      act: (bloc) => bloc..add(ExportEvent(ExportFormat.pdf, document)),
      expect: () => [
        isA<ExporterIdle>(),
        isA<ExporterErrorState>(),
      ],
    );
  });

  group('Printing (normal)', () {
    late ExportService service;
    late Document document;

    setUp(() {
      service = _ExportServiceMock();
      document = DocumentMock();

      when(() => service.isAvailable()).thenAnswer((_) async => true);
      when(() => service.printDocument(document, 'printer', true))
          .thenAnswer((i) => Future.value());
    });

    blocTest<ExporterBloc, ExporterState>(
      'Emits state in right order when printing completes normally',
      build: () => ExporterBloc(service: service),
      act: (bloc) => bloc..add(PrintDocumentEvent(document, 'printer', true)),
      expect: () => [
        isA<ExporterIdle>(),
        ExporterClosingState(isCompleted: true),
      ],
    );
  });

  group('Printing (error)', () {
    late ExportService service;
    late Document document;

    setUp(() {
      service = _ExportServiceMock();
      document = DocumentMock();

      when(() => service.isAvailable()).thenAnswer((_) async => true);
      when(() => service.printDocument(document, 'printer', true))
          .thenAnswer((i) async {
        throw ExportServiceException("error", "stack trace");
      });
    });

    blocTest<ExporterBloc, ExporterState>(
      'Emits state in right order when printing completes normally',
      build: () => ExporterBloc(service: service),
      act: (bloc) => bloc..add(PrintDocumentEvent(document, 'printer', true)),
      expect: () => [
        isA<ExporterIdle>(),
        isA<ExporterErrorState>(),
      ],
    );
  });

  group('List printers (normal)', () {
    late ExportService service;
    late PrintersList printers;

    setUp(() {
      service = _ExportServiceMock();
      printers = PrintersList('preferred', ['preferred']);

      when(() => service.isAvailable()).thenAnswer((_) async => true);
      when(() => service.listPrinters()).thenAnswer((_) async => printers);
    });

    blocTest<ExporterBloc, ExporterState>(
      'Emits state in right order when printing completes normally',
      build: () => ExporterBloc(service: service),
      act: (bloc) => bloc..add(ShowPrintersListEvent()),
      expect: () => [
        isA<ExporterIdle>(),
        ExporterListPrintersState('preferred', ['preferred']),
      ],
    );
  });
}
