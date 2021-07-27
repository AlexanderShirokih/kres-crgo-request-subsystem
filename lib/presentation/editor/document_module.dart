import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/editor/document_filter.dart';
import 'package:kres_requests2/domain/service/document_service.dart';
import 'package:kres_requests2/domain/service/worksheet_service.dart';
import 'package:kres_requests2/presentation/bloc/editor/doc_view/document_bloc.dart';
import 'package:kres_requests2/presentation/bloc/editor/worksheet_config_view/worksheet_config_bloc.dart';
import 'package:kres_requests2/presentation/editor/widgets/document_view.dart';

/// Module that provides dependencies for a certain document
class DocumentScope extends WidgetModule {
  /// Currently associated document
  final Document document;

  DocumentScope(this.document);

  @override
  List<Bind<Object>> get binds => [
        Bind.singleton<DocumentFilter>(
          (i) => DocumentFilter(document),
        ),
        Bind.singleton<WorksheetService>(
          (i) => WorksheetService(document, i<Repository<Employee>>()),
        ),
        Bind.singleton(
          (i) => DocumentService(document, i<DocumentFilter>()),
        ),
        Bind.factory<DocumentBloc>(
          (i) => DocumentBloc(i<DocumentService>(), Modular.to),
        ),
        Bind.factory(
          (i) => WorksheetConfigBloc(i<WorksheetService>()),
        ),
      ];

  @override
  Widget get view {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => Modular.get<DocumentBloc>()),
        BlocProvider(create: (_) => Modular.get<WorksheetConfigBloc>()),
      ],
      child: Builder(
        builder: (_) => DocumentView(),
      ),
    );
  }
}
