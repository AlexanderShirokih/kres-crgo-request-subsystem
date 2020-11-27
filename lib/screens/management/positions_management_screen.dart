import 'package:flutter/material.dart';
import 'package:kres_requests2/models/position.dart';

import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/screens/management/base_management_screen.dart';
import 'package:kres_requests2/screens/management/management_editor_dialog.dart';

class PositionsManagementScreen extends BaseManagementScreen<Position> {
  PositionsManagementScreen(RepositoryModule repositoryModule)
      : assert(repositoryModule != null),
        super(
          repository: repositoryModule.getPositionsRepository(),
          typeEncoder: Position.encoder(),
          title: 'Должности сотрудников',
        );

  @override
  DataRow buildRow(
    Position e, {
    @required bool isSelected,
    @required VoidCallback onTap,
  }) =>
      DataRow(
        selected: isSelected,
        cells: [
          DataCell(
            Text(e.name),
            onTap: onTap,
          )
        ],
      );

  @override
  List<DataColumn> buildColumns() => [
        DataColumn(label: Text('Название должности')),
      ];

  @override
  List<EditableField> buildEditableFields(Position e) => [
        EditableField(
          'Название должности',
          'name',
          e?.name ?? '',
          32,
          RegExp('[\wА-я -]{1,32}'),
        ),
      ];
}
