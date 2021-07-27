import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/domain/models/request_entity.dart';
import 'package:kres_requests2/domain/models/worksheet.dart';
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

  /// Worksheet movement strategy
  final MoveMethod moveMethod;

  const RequestsMoveDialog({
    Key? key,
    required this.movingRequests,
    required this.sourceWorksheet,
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
          create: (_) => RequestsMoveDialogBloc(Modular.get())
            ..add(FetchDataEvent(sourceWorksheet)),
          child: BlocConsumer<RequestsMoveDialogBloc, BaseState>(
              listener: (context, state) {
            if (state is CompletedState) {
              Navigator.pop(context, true);
            }
          }, builder: (context, state) {
            if (state is! DataState<RequestsMoveDialogData>) {
              return const Text('Нет данных :(');
            }

            return ListView(
              children: [
                ...state.data.targets.map(
                  (e) => _createListTile(FontAwesomeIcons.file, e.name, () {
                    context
                        .read<RequestsMoveDialogBloc>()
                        .add(MoveRequestsEvent(
                          target: e,
                          requests: movingRequests,
                          removeFromSource: _shouldRemoveFromOriginal(),
                        ));
                  }),
                ),
                _createListTile(FontAwesomeIcons.plus, "В новый лист", () {
                  context.read<RequestsMoveDialogBloc>().add(MoveRequestsEvent(
                        requests: movingRequests,
                        removeFromSource: _shouldRemoveFromOriginal(),
                      ));
                })
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _createListTile(
    IconData iconData,
    String title,
    void Function() onPressed,
  ) =>
      Card(
        elevation: 3.0,
        child: ListTile(
          onTap: onPressed,
          leading: FaIcon(iconData),
          title: Text(title),
        ),
      );
}
