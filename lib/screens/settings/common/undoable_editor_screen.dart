import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/screens/common/save_changes_dialog.dart';
import 'package:kres_requests2/screens/common/table_view.dart';

import '../common/bloc/undoable_bloc.dart';
import 'bloc/undoable_data.dart';
import 'bloc/undoable_events.dart';
import 'bloc/undoable_state.dart';

typedef UndoableBlocBuilder<DH extends UndoableDataHolder<E>, E extends Object>
    = UndoableBloc<DH, E> Function(BuildContext);

typedef TableRowBuilder<DH extends UndoableDataHolder<E>, E extends Object>
    = List<TableDataRow> Function(UndoableBloc<DH, E>, DH);

/// Creates for managing some list of entities. Shows all entities in table view.
/// Supports showing insertion, modifying, deleting of entities.
class UndoableEditorScreen<DH extends UndoableDataHolder<E>, E extends Object>
    extends StatelessWidget {
  final String screenTitle;
  final String addItemButtonName;
  final Widget addItemIcon;
  final List<TableHeadingColumn> tableHeader;
  final TableRowBuilder<DH, E> dataRowBuilder;
  final UndoableBlocBuilder<DH, E> blocBuilder;

  const UndoableEditorScreen({
    Key? key,
    required this.blocBuilder,
    required this.screenTitle,
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

              if (bloc.state is DataState<E, DH>) {
                final dataState = bloc.state as DataState<E, DH>;
                if (dataState.hasUnsavedChanges && dataState.canSave) {
                  final canPop = await showDialog<bool?>(
                      context: context, builder: (_) => SaveChangesDialog());

                  if (canPop == null) {
                    // Cancelled
                    return false;
                  }

                  if (!canPop) {
                    // Cannot be popped before changed
                    await bloc.commitChanges();
                  }

                  // Can be popped by discarding changes
                  return true;
                }
              }

              return true;
            },
            child: Scaffold(
              floatingActionButton: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildActionButton(),
              ),
              appBar: AppBar(
                title: Text(screenTitle),
                actions: [
                  _buildAppBarActions(),
                  Builder(
                    builder: (BuildContext context) => ElevatedButton.icon(
                      icon: addItemIcon,
                      label: Text(addItemButtonName),
                      onPressed: () => context
                          .read<UndoableBloc<DH, E>>()
                          .add(AddItemEvent()),
                    ),
                  ),
                  SizedBox(width: 42.0),
                ],
              ),
              body: BlocBuilder<UndoableBloc<DH, E>, UndoableState<DH>>(
                builder: (context, state) {
                  if (state is DataState<E, DH>) {
                    return _EntityTableContent<DH, E>(
                      bloc: context.watch<UndoableBloc<DH, E>>(),
                      dataRowBuilder: (a, b) => dataRowBuilder(
                        a as UndoableBloc<DH, E>,
                        b as DH,
                      ),
                      tableHeader: tableHeader,
                      data: state.current,
                    );
                  }
                  return Center(
                    child: Text('Нет данных :('),
                  );
                },
              ),
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
            child: FaIcon(FontAwesomeIcons.solidSave),
            onPressed: () =>
                context.read<UndoableBloc<DH, E>>().add(ApplyEvent()),
          );
        } else {
          return const SizedBox();
        }
      });

  Widget _buildAppBarActions() =>
      BlocBuilder<UndoableBloc<DH, E>, UndoableState<DH>>(
          builder: (context, state) {
        if (state is DataState<E, DH>) {
          return Row(
            children: _spreadActionButtons(context, state).toList(),
          );
        } else {
          return const SizedBox();
        }
      });

  Iterable<Widget> _spreadActionButtons(
      BuildContext context, DataState<E, DH> state) sync* {
    if (state.hasUnsavedChanges) {
      yield IconButton(
        icon: Icon(Icons.redo),
        tooltip: 'Отменить',
        onPressed: () =>
            context.read<UndoableBloc<DH, E>>().add(UndoActionEvent()),
      );
      yield SizedBox(width: 36.0);
    }
  }
}

class _EntityTableContent<DH extends UndoableDataHolder<E>, E extends Object>
    extends StatefulWidget {
  final DH data;
  final UndoableBloc<DH, E> bloc;
  final List<TableHeadingColumn> tableHeader;
  final TableRowBuilder<DH, E> dataRowBuilder;

  const _EntityTableContent({
    Key? key,
    required this.data,
    required this.bloc,
    required this.tableHeader,
    required this.dataRowBuilder,
  }) : super(key: key);

  @override
  _EntityTableContentState createState() =>
      _EntityTableContentState<DH, E>(dataRowBuilder);
}

class _EntityTableContentState<DH extends UndoableDataHolder<E>,
    E extends Object> extends State<_EntityTableContent> {
  final TableRowBuilder<DH, E> _rowBuilder;
  late ScrollController _scrollController;
  bool _wasRebuilt = false;

  _EntityTableContentState(this._rowBuilder);

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
    if (widget.data.data.isEmpty) {
      return Center(
        child:
            Text('Таблица пуста', style: Theme.of(context).textTheme.headline3),
      );
    }

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (_wasRebuilt) {
        _scrollController.animateTo(
          100000.0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }
      _wasRebuilt = true;
    });

    final List<TableDataRow> rows =
        _rowBuilder(widget.bloc as UndoableBloc<DH, E>, widget.data as DH);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 460.0,
      ),
      child: TableView(
        controller: _scrollController,
        rowsTextStyle:
            Theme.of(context).textTheme.headline5!.copyWith(color: Colors.grey),
        headingTextStyle:
            Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 18.0),
        header: widget.tableHeader,
        rows: rows,
      ),
    );
  }
}
