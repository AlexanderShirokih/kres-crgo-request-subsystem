import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/presentation/bloc/settings/common/undoable_bloc.dart';
import 'package:kres_requests2/presentation/bloc/settings/common/undoable_data.dart';
import 'package:kres_requests2/presentation/bloc/settings/common/undoable_events.dart';
import 'package:kres_requests2/presentation/bloc/settings/common/undoable_state.dart';
import 'package:kres_requests2/presentation/common/save_changes_dialog.dart';
import 'package:kres_requests2/presentation/common/table_view.dart';

typedef UndoableBlocBuilder<DH extends UndoableDataHolder<E>, E extends Object>
    = UndoableBloc<DH, E> Function(BuildContext);

abstract class TableRowBuilder<E> {
  List<TableDataRow> buildDataRow(BuildContext context, E entity);
}

/// Creates for managing some list of entities. Shows all entities in table view.
/// Supports showing insertion, modifying, deleting of entities.
class UndoableEditorScreen<DH extends UndoableDataHolder<E>, E extends Object>
    extends StatelessWidget {
  final String addItemButtonName;
  final Widget addItemIcon;
  final List<TableHeadingColumn> tableHeader;
  final TableRowBuilder<DH> dataRowBuilder;
  final UndoableBlocBuilder<DH, E> blocBuilder;

  const UndoableEditorScreen({
    Key? key,
    required this.blocBuilder,
    required this.addItemIcon,
    required this.addItemButtonName,
    required this.tableHeader,
    required this.dataRowBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: blocBuilder,
        child: Builder(
          builder: (context) => WillPopScope(
            onWillPop: () async {
              // ignore: close_sinks
              final bloc = context.read<UndoableBloc<DH, E>>();

              final currentState = bloc.state;
              if (currentState is DataState<E, DH>) {
                if (currentState.hasUnsavedChanges && currentState.canSave) {
                  final canPop = await showDialog<bool?>(
                      context: context,
                      builder: (_) => const SaveChangesDialog());

                  if (canPop == null) {
                    // Cancelled
                    return false;
                  }

                  if (!canPop) {
                    // Cannot be popped before  all changes committed
                    await bloc.commitChanges();
                  }

                  // Can be popped by discarding changes
                  return true;
                }
              }

              return true;
            },
            child: BlocBuilder<UndoableBloc<DH, E>, UndoableState<DH>>(
              builder: (context, state) {
                if (state is DataState<E, DH>) {
                  if (state.hasUnresolvedDependencies) {
                    final theme = Theme.of(context);
                    return Center(
                      child: Text(
                        'Поля этой таблицы зависят от другой таблицы, но она пуста',
                        style: theme.textTheme.headline3!
                            .copyWith(color: theme.errorColor),
                      ),
                    );
                  }
                  return Stack(
                    children: [
                      _EntityTableContent<DH, E>(
                        headerTrailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ..._spreadActionButtons(context, state),
                            Builder(
                              builder: (BuildContext context) =>
                                  ElevatedButton.icon(
                                icon: addItemIcon,
                                label: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 16.0,
                                  ),
                                  child: Text(addItemButtonName),
                                ),
                                onPressed: () => context
                                    .read<UndoableBloc<DH, E>>()
                                    .add(const AddItemEvent()),
                              ),
                            ),
                            const SizedBox(width: 42.0),
                          ],
                        ),
                        dataRowBuilder: dataRowBuilder,
                        tableHeader: tableHeader,
                        data: state.current,
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: _buildActionButton(),
                        ),
                      ),
                    ],
                  );
                }
                return const Center(
                  child: Text('Нет данных :('),
                );
              },
            ),
          ),
        ),
      );

  Widget _buildActionButton() =>
      BlocBuilder<UndoableBloc<DH, E>, UndoableState<DH>>(
          builder: (context, state) {
        if (state is DataState<E, DH> && state.canSave) {
          return FloatingActionButton(
            tooltip: 'Сохранить изменения',
            child: const FaIcon(FontAwesomeIcons.solidSave),
            onPressed: () =>
                context.read<UndoableBloc<DH, E>>().add(const ApplyEvent()),
          );
        } else {
          return const SizedBox();
        }
      });

  Iterable<Widget> _spreadActionButtons(
      BuildContext context, DataState<E, DH> state) sync* {
    if (state.hasUnsavedChanges) {
      yield IconButton(
        icon: const Icon(Icons.redo),
        tooltip: 'Отменить',
        onPressed: () =>
            context.read<UndoableBloc<DH, E>>().add(const UndoActionEvent()),
      );
      yield const SizedBox(width: 36.0);
    }
  }
}

class _EntityTableContent<DH extends UndoableDataHolder<E>, E extends Object>
    extends StatefulWidget {
  final DH data;
  final Widget headerTrailing;
  final List<TableHeadingColumn> tableHeader;
  final TableRowBuilder<DH> dataRowBuilder;

  const _EntityTableContent({
    Key? key,
    required this.data,
    required this.headerTrailing,
    required this.tableHeader,
    required this.dataRowBuilder,
  }) : super(key: key);

  @override
  _EntityTableContentState createState() => _EntityTableContentState<DH, E>();
}

class _EntityTableContentState<DH extends UndoableDataHolder<E>,
    E extends Object> extends State<_EntityTableContent> {
  late ScrollController _scrollController;
  bool _wasRebuilt = false;

  _EntityTableContentState();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      if (_wasRebuilt && _scrollController.hasClients) {
        _scrollController.animateTo(
          100000.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }
      _wasRebuilt = true;
    });

    final List<TableDataRow> rows =
        widget.dataRowBuilder.buildDataRow(context, widget.data as DH);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 460.0,
      ),
      child: TableView(
        headerTrailing: widget.headerTrailing,
        controller: _scrollController,
        rowsTextStyle:
            Theme.of(context).textTheme.headline5!.copyWith(color: Colors.grey),
        headingTextStyle:
            Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 18.0),
        header: widget.tableHeader,
        rows: rows,
        onTableEmpty: (BuildContext context) => Expanded(
          child: Center(
            child: Text('Таблица пуста',
                style: Theme.of(context).textTheme.headline3),
          ),
        ),
      ),
    );
  }
}
