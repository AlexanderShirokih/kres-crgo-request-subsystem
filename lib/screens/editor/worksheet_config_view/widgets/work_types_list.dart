import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/bloc/editor/worksheet_config_view/worksheet_config_bloc.dart';

class WorkTypesList extends StatefulWidget {
  final Set<String> workTypes;

  const WorkTypesList({
    Key? key,
    required this.workTypes,
  }) : super(key: key);

  @override
  _WorkTypesListState createState() => _WorkTypesListState();
}

class _WorkTypesListState extends State<WorkTypesList> {
  bool _hasAdditionalField = false;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          Expanded(
            child: Text('Виды работ:',
                style: Theme.of(context).textTheme.headline6),
          ),
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Добавить',
            onPressed: () => setState(() {
              _hasAdditionalField = true;
            }),
          ),
          const SizedBox(width: 8.0),
        ],
      ),
      const SizedBox(height: 4.0),
      _createWorkTypesList(),
    ]);
  }

  Widget _createWorkTypesList() {
    final allWorkTypes = [...widget.workTypes, if (_hasAdditionalField) null];

    return Column(
      children: allWorkTypes
          .map(
            (e) => ListTile(
              leading: IconButton(
                icon: Icon(Icons.remove_circle_outline, size: 16.0),
                onPressed: () => setState(() {
                  if (e == null) {
                    _hasAdditionalField = false;
                  } else {
                    allWorkTypes.remove(e);
                    _updateWorkTypes(allWorkTypes);
                  }
                }),
              ),
              title: e != null
                  ? Text(e)
                  : TextField(
                      maxLines: 1,
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            _hasAdditionalField = false;
                            allWorkTypes.add(value);
                            _updateWorkTypes(allWorkTypes);
                          });
                        }
                      },
                    ),
            ),
          )
          .toList(),
    );
  }

  void _updateWorkTypes(List<String?> workTypes) {
    context
        .read<WorksheetConfigBloc>()
        .add(UpdateWorkTypesEvent(workTypes.whereType<String>().toSet()));
  }
}
