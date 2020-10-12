import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:kres_requests2/bloc/exporter/exporter_bloc.dart';
import 'package:kres_requests2/models/worksheet.dart';
import 'package:kres_requests2/repo/config_repository.dart';
import 'package:kres_requests2/repo/requests_repository.dart';
import 'package:kres_requests2/repo/settings_repository.dart';
import 'package:kres_requests2/screens/common.dart';

class PrintDialog extends StatelessWidget {
  final List<Worksheet> worksheets;

  const PrintDialog(this.worksheets) : assert(worksheets != null);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Печать', textAlign: TextAlign.center),
      content: Container(
        width: 340.0,
        height: 380.0,
        child: BlocProvider.value(
          value: ExporterBloc(
            settings: context.repository<SettingsRepository>(),
            worksheets: worksheets,
            requestsRepository: RequestsRepository(
              context.repository<SettingsRepository>(),
              context.repository<ConfigRepository>(),
            ),
          ),
          child: Builder(
            builder: (context) => BlocConsumer(
              cubit: context.bloc<ExporterBloc>(),
              builder: (context, state) {
                if (state is ExporterListPrintersState) {
                  return _ListPrintersView(
                    state.preferredPrinter,
                    state.availablePrinters,
                  );
                } else if (state is ExporterIdle) {
                  return LoadingView(state.message);
                } else if (state is ExporterErrorState && state.error != null) {
                  return ErrorView(
                    errorDescription: state.error.error,
                    stackTrace: state.error.stackTrace,
                  );
                } else
                  return Center(
                    child: Text('Possibly unknown state'),
                  );
              },
              listener: (context, state) {
                if (state is ExporterClosingState) {
                  Navigator.of(context).pop(state.isCompleted
                      ? 'Задание отправлено на печать'
                      : null);
                } else if (state is ExporterMissingState) {
                  Navigator.of(context)
                      .pop('Ошибка: Модуль печати отсутcтвует');
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ListPrintersView extends StatefulWidget {
  final String preferredPrinter;
  final List<String> availablePrinters;

  const _ListPrintersView(this.preferredPrinter, this.availablePrinters);

  @override
  __ListPrintersViewState createState() => __ListPrintersViewState();
}

class __ListPrintersViewState extends State<_ListPrintersView> {
  bool noLists = false;

  @override
  Widget build(BuildContext context) {
    if (widget.availablePrinters.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Доступные принтеры не найдены'),
          const SizedBox(height: 12.0),
          OutlinedButton.icon(
            icon: FaIcon(FontAwesomeIcons.sync),
            label: Text('Обновить'),
            onPressed: () => context
                .bloc<ExporterBloc>()
                .add(ExporterShowPrintersListEvent()),
          )
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ..._showLastPrinter(context),
          ..._showAvailablePrinters(context),
          const SizedBox(height: 24.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: noLists,
                onChanged: (newValue) => setState(() {
                  noLists = newValue;
                }),
              ),
              const SizedBox(height: 8.0),
              Text('Печать без списка работ'),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlineButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена'),
              )
            ],
          )
        ],
      );
    }
  }

  Iterable<Widget> _showLastPrinter(BuildContext context) sync* {
    if (widget.preferredPrinter == null) return;

    yield Text('Последний принтер:');
    yield const SizedBox(height: 12.0);
    yield _createPrinterItem(context, widget.preferredPrinter);
    yield const SizedBox(height: 18.0);
  }

  Iterable<Widget> _showAvailablePrinters(BuildContext context) sync* {
    yield Text('Доступные принтеры:');
    yield const SizedBox(height: 12.0);
    yield Expanded(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.availablePrinters
              .map((p) => _createPrinterItem(context, p))
              .toList(),
        ),
      ),
    );
  }

  Widget _createPrinterItem(BuildContext context, String printerName) =>
      ListTile(
        leading: FaIcon(FontAwesomeIcons.print),
        title: Text(printerName),
        onTap: () =>
            context.bloc<ExporterBloc>().add(ExporterPrintDocumentEvent(
                  printerName,
                  noLists,
                )),
      );
}
