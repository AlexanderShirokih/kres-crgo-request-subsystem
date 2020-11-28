import 'package:flutter/material.dart';
import 'package:kres_requests2/models/address.dart';

import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/screens/management/base_management_screen.dart';
import 'package:kres_requests2/screens/management/management_editor_dialog.dart';

class DistrictManagementScreen extends BaseManagementScreen<District> {
  DistrictManagementScreen(RepositoryModule repositoryModule)
      : assert(repositoryModule != null),
        super(
          repository: repositoryModule.getDistrictRepository(),
          typeEncoder: District.encoder(),
          title: 'Районы города',
        );

  @override
  DataRow buildRow(
    District e, {
    bool isSelected,
    VoidCallback onTap,
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
  List<DataColumn> buildColumns() =>
      [DataColumn(label: Text('Название района'))];

  @override
  List<EditableField> buildEditableFields(District e) => [
        EditableField(
          'Название района',
          'name',
          e?.name ?? '',
          20,
          RegExp('[\w]{1,20}'),
        ),
      ];
}
