import 'package:flutter/material.dart';
import 'package:kres_requests2/models/address.dart';

import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/screens/management/base_management_screen.dart';
import 'package:kres_requests2/screens/management/management_editor_dialog.dart';
import 'package:kres_requests2/screens/management/street_editor_dialog.dart';

class StreetManagementScreen extends BaseManagementScreen<Street> {
  final RepositoryModule repositoryModule;

  StreetManagementScreen(this.repositoryModule)
      : assert(repositoryModule != null),
        super(
          repository: repositoryModule.getStreetRepository(),
          typeEncoder: Street.encoder(),
          title: 'Улицы',
        );

  @override
  DataRow buildRow(
    Street e, {
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
            Text(e.district?.name ?? '--'),
            onTap: onTap,
          )
        ],
      );

  @override
  List<DataColumn> buildColumns() => [
        DataColumn(label: Text('Название')),
        DataColumn(label: Text('Район')),
      ];

  @override
  Widget createEditorDialog(Street entity) => StreetEditorDialog(
        entity,
        repositoryModule.getDistrictRepository(),
      );

  @override
  List<EditableField> buildEditableFields(Street e) => null;
}
