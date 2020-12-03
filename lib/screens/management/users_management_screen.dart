import 'package:flutter/material.dart';
import 'package:kres_requests2/models/user.dart';

import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/screens/management/base_management_screen.dart';
import 'package:kres_requests2/screens/management/management_editor_dialog.dart';
import 'package:kres_requests2/screens/management/users_editor_dialog.dart';

class UsersManagementScreen extends BaseManagementScreen<User> {
  UsersManagementScreen(RepositoryModule repositoryModule)
      : assert(repositoryModule != null),
        super(
          repository: repositoryModule.getUserRepository(),
          typeEncoder: User.encoder(),
          title: 'Пользователи',
        );

  @override
  DataRow buildRow(
    User e, {
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
            Text(e.authority.getLocalizedDescription()),
            onTap: onTap,
          )
        ],
      );

  @override
  List<DataColumn> buildColumns() => [
        DataColumn(label: Text('Логин')),
        DataColumn(label: Text('Полномочия')),
      ];

  @override
  List<EditableField> buildEditableFields(User e) => null;

  @override
  Widget createEditorDialog(User entity) => UserEditorDialog(entity);
}
