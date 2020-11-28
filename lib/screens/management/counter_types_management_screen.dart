import 'package:flutter/material.dart';

import 'package:kres_requests2/models/counting_point.dart';
import 'package:kres_requests2/repo/repository_module.dart';

import 'base_management_screen.dart';
import 'counter_type_editor_dialog.dart';
import 'management_editor_dialog.dart';

class CounterTypesManagementScreen extends BaseManagementScreen<CounterType> {
  final RepositoryModule repositoryModule;

  CounterTypesManagementScreen(this.repositoryModule)
      : assert(repositoryModule != null),
        super(
          repository: repositoryModule.getCounterTypesRepository(),
          typeEncoder: CounterType.encoder(),
          title: 'Приборы учета',
        );

  @override
  List<DataColumn> buildColumns() => [
        DataColumn(label: Text('Тип')),
        DataColumn(label: Text('Класс точности')),
        DataColumn(label: Text('Разрядность')),
        DataColumn(label: Text('Фазность')),
      ];

  @override
  DataRow buildRow(
    CounterType e, {
    @required bool isSelected,
    @required VoidCallback onTap,
  }) =>
      DataRow(
        selected: isSelected,
        cells: [
          DataCell(
            Text(e.name),
            onTap: onTap,
          ),
          DataCell(
            Text(e.accuracy.describeValue()),
            onTap: onTap,
          ),
          DataCell(
            Text(e.bits.toString()),
            onTap: onTap,
          ),
          DataCell(
            Text(e.singlePhased ? '1 ф.' : '3 ф.'),
            onTap: onTap,
          )
        ],
      );

  @override
  Widget createEditorDialog(CounterType entity) =>
      CounterTypeEditorDialog(entity);

  @override
  List<EditableField> buildEditableFields(CounterType e) => null;
}
