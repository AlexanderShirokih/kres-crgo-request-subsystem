import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:kres_requests2/models/entity.dart';
import 'package:kres_requests2/models/encoder.dart';
import 'package:kres_requests2/repo/base_crud_repository.dart';
import 'package:kres_requests2/bloc/management/management_bloc.dart';
import 'package:kres_requests2/screens/common.dart';
import 'package:kres_requests2/screens/management/management_editor_dialog.dart';

/// Base class for all management screens
abstract class BaseManagementScreen<E extends Entity> extends StatelessWidget
    implements ContentBuildContract<E> {
  final String title;
  final ManagementBloc<E> _managementBloc;

  BaseManagementScreen({
    Key key,
    @required this.title,
    @required Encoder<E> typeEncoder,
    @required BaseCRUDRepository<E> repository,
  })  : _managementBloc = ManagementBloc<E>(repository, typeEncoder),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<ManagementBloc<E>, ManagementState>(
        cubit: _managementBloc,
        builder: (context, state) {
          if (state is ManagementFetchingData) {
            return LoadingView('Загрузка данных...');
          } else if (state is ManagementDataState<E>) {
            return BlocProvider.value(
              value: _managementBloc,
              child: _ManagedContentView(
                title: title,
                builder: this,
                data: state.data,
              ),
            );
          } else if (state is ManagementErrorState) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.bug,
                    size: 82.0,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Ошибка выполнения запроса',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  const SizedBox(height: 16.0),
                  Text(state.error.error),
                  const SizedBox(height: 16.0),
                  OutlinedButton(
                    child: Text('Обновить'),
                    onPressed: () =>
                        _managementBloc.add(ManagementFetchEvent()),
                  )
                ],
              ),
            );
          } else {
            return Center(child: Text('Нет данных('));
          }
        },
        listener: (context, state) {
          if (state is ManagementConfirmationState) {
            ScaffoldMessenger.of(context)
                .showSnackBar(
                  SnackBar(
                    content: Text('Запись "${state.content}" удалена!'),
                    action: SnackBarAction(
                      label: 'Отменить',
                      onPressed: () => _managementBloc.add(state.onRestore),
                    ),
                  ),
                )
                .closed
                .then((reason) {
              if (reason == SnackBarClosedReason.timeout) {
                _managementBloc.add(state.onConfirmed);
              }
            });
          } else if (state is ManagementEditingState<E>) {
            showDialog<Map<String, dynamic>>(
              context: context,
              builder: (_) => ManagementEditorDialog(
                  state.entity == null, buildEditableFields(state.entity)),
            ).then((editingResult) {
              if (editingResult != null) {
                _managementBloc.add(
                    ManagementEditCompletedEvent(state.entity, editingResult));
              }
            });
          }
        },
      ),
    );
  }

  List<EditableField> buildEditableFields(E e);
}

abstract class ContentBuildContract<E> {
  /// Builds table header
  List<DataColumn> buildColumns();

  /// Builds table row
  DataRow buildRow(
    E e, {
    @required bool isSelected,
    @required VoidCallback onTap,
  });
}

class _ManagedContentView<E extends Entity> extends StatefulWidget {
  final ContentBuildContract<E> builder;
  final List<E> data;
  final String title;

  const _ManagedContentView({
    @required this.title,
    @required this.builder,
    @required this.data,
  });

  @override
  __ManagedContentViewState createState() => __ManagedContentViewState<E>();
}

class __ManagedContentViewState<E extends Entity>
    extends State<_ManagedContentView> {
  E _selected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            child: Container(color: Colors.white),
            onTap: () => setState(() {
              _selected = null;
            }),
          ),
        ),
        Center(
          heightFactor: 1.1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24.0),
              Text(widget.title, style: Theme.of(context).textTheme.headline4),
              const SizedBox(height: 24.0),
              Container(
                width: 840.0,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: widget.builder.buildColumns(),
                    rows: widget.data
                        .map((e) => widget.builder.buildRow(
                              e,
                              isSelected: e == _selected,
                              onTap: () => setState(() {
                                _selected = e;
                              }),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 32.0, bottom: 32.0),
            child: Builder(
              builder: (context) {
                if (_selected == null)
                  return FloatingActionButton(
                    child: FaIcon(FontAwesomeIcons.plus),
                    tooltip: 'Добавить',
                    onPressed: () => context
                        .read<ManagementBloc<E>>()
                        .add(ManagementEditItemEvent(null)),
                  );
                else
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: 'edit',
                        child: FaIcon(FontAwesomeIcons.pencilAlt),
                        tooltip: 'Изменить',
                        onPressed: () => context
                            .read<ManagementBloc<E>>()
                            .add(ManagementEditItemEvent(_selected)),
                      ),
                      const SizedBox(height: 24.0),
                      FloatingActionButton(
                        heroTag: 'remove',
                        child: FaIcon(FontAwesomeIcons.trashAlt),
                        tooltip: 'Удалить',
                        onPressed: () {
                          context
                              .read<ManagementBloc<E>>()
                              .add(ManagementRemoveItemEvent(_selected));
                          setState(() {
                            _selected = null;
                          });
                        },
                      )
                    ],
                  );
              },
            ),
          ),
        )
      ],
    );
  }
}
