import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/screens/bloc/exporter/exporter_bloc.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/screens/common.dart';

/// Dialog used to create printable document and send it to the printer
class PrintDialog extends StatelessWidget {
  /// Target document
  final Document document;

  const PrintDialog(this.document);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Печать', textAlign: TextAlign.center),
      content: Container(
        width: 340.0,
        height: 380.0,
        child: BlocProvider(
          create: (_) =>
              Modular.get<ExporterBloc>()..add(ShowPrintersListEvent()),
          child: Builder(
            builder: (context) => BlocConsumer(
              bloc: context.read<ExporterBloc>(),
              builder: (context, state) {
                if (state is ExporterListPrintersState) {
                  return _ListPrintersView(
                    document,
                    state.preferredPrinter,
                    state.availablePrinters,
                  );
                } else if (state is ExporterIdle) {
                  return LoadingView(state.message ?? '');
                } else if (state is ExporterErrorState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: ErrorView(
                          errorDescription: state.error,
                          stackTrace: StackTrace.fromString(state.stackTrace),
                        ),
                      ),
                      BackButton(),
                    ],
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

class _ListPrintersView extends HookWidget {
  final Document document;
  final String? preferredPrinter;
  final List<String> availablePrinters;

  const _ListPrintersView(
    this.document,
    this.preferredPrinter,
    this.availablePrinters,
  );

  @override
  Widget build(BuildContext context) {
    final noLists = useState(false);

    if (availablePrinters.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Доступные принтеры не найдены'),
          const SizedBox(height: 12.0),
          OutlinedButton.icon(
            icon: FaIcon(FontAwesomeIcons.sync),
            label: Text('Обновить'),
            onPressed: () =>
                context.read<ExporterBloc>().add(ShowPrintersListEvent()),
          ),
          const SizedBox(height: 12.0),
          BackButton(),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ..._showLastPrinter(context, noLists.value),
          ..._showAvailablePrinters(context, noLists.value),
          const SizedBox(height: 24.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: noLists.value,
                onChanged: (newValue) => noLists.value = newValue!,
              ),
              const SizedBox(height: 8.0),
              Text('Печать без списка работ'),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена'),
              )
            ],
          )
        ],
      );
    }
  }

  Iterable<Widget> _showLastPrinter(
    BuildContext context,
    bool noLists,
  ) sync* {
    if (preferredPrinter == null) return;

    yield Text('Последний принтер:');
    yield const SizedBox(height: 12.0);
    yield _createPrinterItem(context, preferredPrinter!, noLists);
    yield const SizedBox(height: 18.0);
  }

  Iterable<Widget> _showAvailablePrinters(
    BuildContext context,
    bool noLists,
  ) sync* {
    yield Text('Доступные принтеры:');
    yield const SizedBox(height: 12.0);
    yield Expanded(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: availablePrinters
              .map((p) => _createPrinterItem(context, p, noLists))
              .toList(),
        ),
      ),
    );
  }

  Widget _createPrinterItem(
    BuildContext context,
    String printerName,
    bool noLists,
  ) =>
      ListTile(
        leading: FaIcon(FontAwesomeIcons.print),
        title: Text(printerName),
        onTap: () => context.read<ExporterBloc>().add(PrintDocumentEvent(
              document,
              printerName,
              noLists,
            )),
      );
}
