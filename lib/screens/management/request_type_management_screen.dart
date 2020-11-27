import 'package:flutter/material.dart';

import 'package:kres_requests2/models/request.dart';
import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/screens/management/base_management_screen.dart';
import 'package:kres_requests2/screens/management/management_editor_dialog.dart';

class RequestTypesManagementScreen extends BaseManagementScreen<RequestType> {
  RequestTypesManagementScreen(RepositoryModule repositoryModule)
      : assert(repositoryModule != null),
        super(
          repository: repositoryModule.getRequestTypeRepository(),
          typeEncoder: RequestType.encoder(),
          title: 'Типы заявок',
        );

  @override
  DataRow buildRow(
    RequestType e, {
    @required bool isSelected,
    @required VoidCallback onTap,
  }) =>
      DataRow(
        selected: isSelected,
        cells: [
          DataCell(
            Text(e.shortName),
            onTap: onTap,
          ),
          DataCell(
            Text(e.fullName),
            onTap: onTap,
          )
        ],
      );

  @override
  List<DataColumn> buildColumns() => [
        DataColumn(label: Text('Название')),
        DataColumn(label: Text('Вид работ')),
      ];

  @override
  List<EditableField> buildEditableFields(RequestType e) => [
        EditableField(
          'Название',
          'shortName',
          e?.shortName ?? '',
          16,
          RegExp('[\wА-я -]{1,16}'),
        ),
        EditableField(
          'Вид работ',
          'fullName',
          e?.fullName ?? '',
          64,
          RegExp('[\wА-я -]{1,64}'),
        ),
      ];
}
