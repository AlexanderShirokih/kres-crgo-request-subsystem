import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/service/request_service.dart';
import 'package:kres_requests2/presentation/bloc.dart';
import 'package:kres_requests2/presentation/bloc/editor/requests_move_dialog/requests_move_dialog_bloc.dart';

/// Defines worksheet movement strategy
enum MoveMethod {
  /// Copies requests from the source worksheet to the target
  copy,

  /// Removes requests from the source worksheet and moves to the target
  move,
}

class RequestsMoveDialog extends StatelessWidget {
  /// Requests to be moved
  final List<Request> movingRequests;

  /// The donor worksheet
  final Worksheet sourceWorksheet;

  /// Source worksheet owner
  final Document sourceDocument;

  /// Worksheet movement strategy
  final MoveMethod moveMethod;

  const RequestsMoveDialog({
    Key? key,
    required this.movingRequests,
    required this.sourceWorksheet,
    required this.sourceDocument,
    required this.moveMethod,
  }) : super(key: key);

  String get _title {
    switch (moveMethod) {
      case MoveMethod.copy:
        return "Копирование заявок";
      case MoveMethod.move:
        return "Перемещение заявок";
    }
  }

  bool _shouldRemoveFromOriginal() => moveMethod == MoveMethod.move;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_title, textAlign: TextAlign.center),
      content: SizedBox(
        width: 400,
        height: 300,
        child: BlocProvider(
          /// Move BLoC creation to a separate module
          create: (_) => RequestsMoveDialogBloc(Modular.get(), Modular.to)
            ..add(FetchDataEvent(MoveSource(sourceDocument, sourceWorksheet))),
          child: BlocConsumer<RequestsMoveDialogBloc, BaseState>(
              listener: (context, state) {},
              builder: (context, state) {
                if (state is! DataState<RequestsMoveDialogData>) {
                  return const Text('Нет данных :(');
                }

                final data = state.data;

                return ListView(
                  children: data.targets
                      .map(
                        (MoveTarget target) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: _DocumentMoveTargets(
                            document: target.document,
                            worksheets: target.worksheets,
                            isCurrent: data.source.document == target.document,
                            onTargetChosen: (document, worksheet) {
                              context
                                  .read<RequestsMoveDialogBloc>()
                                  .add(MoveRequestsEvent(
                                    targetWorksheet: worksheet,
                                    targetDocument: document,
                                    requests: movingRequests,
                                    removeFromSource: _shouldRemoveFromOriginal(),
                                  ));
                            },
                          ),
                        ),
                      )
                      .toList(growable: false),
                );
              }),
        ),
      ),
    );
  }
}

typedef OnTargetChosen = void Function(Document document, Worksheet? worksheet);

class _DocumentMoveTargets extends StatelessWidget {
  final Document document;
  final List<Worksheet> worksheets;
  final bool isCurrent;
  final OnTargetChosen onTargetChosen;

  const _DocumentMoveTargets({
    Key? key,
    required this.document,
    required this.worksheets,
    required this.isCurrent,
    required this.onTargetChosen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).selectedRowColor,
      elevation: 3.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              isCurrent ? 'Текущий документ' : document.suggestedName,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 0.0, 8.0, 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...worksheets.map(
                  (e) => _createListTile(
                    FontAwesomeIcons.file,
                    e.name,
                    () => onTargetChosen(document, e),
                  ),
                ),
                _createListTile(
                  FontAwesomeIcons.plus,
                  "В новый лист",
                  () => onTargetChosen(document, null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _createListTile(
    IconData iconData,
    String title,
    void Function() onPressed,
  ) =>
      ListTile(
        onTap: onPressed,
        leading: FaIcon(iconData),
        title: Text(title),
      );
}
