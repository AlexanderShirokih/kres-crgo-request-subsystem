import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/data/settings/request_type_module.dart';
import 'package:kres_requests2/domain/models/request_type.dart';
import 'package:kres_requests2/screens/common/table_view.dart';
import 'package:kres_requests2/screens/settings/common/bloc/undoable_bloc.dart';
import 'package:kres_requests2/screens/settings/common/bloc/undoable_events.dart';
import 'package:kres_requests2/screens/settings/common/undoable_editor_screen.dart';
import 'package:kres_requests2/screens/settings/common/widgets/delete_button.dart';
import 'package:kres_requests2/screens/settings/common/widgets/editable_name_field.dart';
import 'package:kres_requests2/screens/settings/request_types/bloc/request_type_bloc.dart';
import 'package:kres_requests2/screens/settings/request_types/bloc/request_type_data.dart';

/// Manages request types.
class RequestTypesScreen extends StatelessWidget {
  final RequestTypeModule requestTypeModule;

  const RequestTypesScreen({Key? key, required this.requestTypeModule})
      : super(key: key);

  @override
  Widget build(BuildContext context) => UndoableEditorScreen(
        blocBuilder: (_) => RequestTypeBloc(
          requestTypeModule.requestTypeController,
          requestTypeModule.requestTypeValidator,
        ),
        addItemButtonName: 'Добавить тип заявки',
        addItemIcon: FaIcon(FontAwesomeIcons.wrench),
        tableHeader: [
          TableHeadingColumn(
              label: Text('Короткое название'), preferredWidth: 300.0),
          TableHeadingColumn(
              label: Text('Полное название'), preferredWidth: 360.0),
          TableHeadingColumn(label: const SizedBox(), preferredWidth: 60.0),
        ],
        dataRowBuilder: _buildData,
      );

  List<TableDataRow> _buildData(UndoableBloc<RequestTypeData, RequestType> bloc,
      RequestTypeData dataHolder) {
    return dataHolder.data.map((e) {
      return TableDataRow(
        key: ObjectKey(e),
        cells: [
          EditableNameField(
            value: e.shortName,
            onChanged: (newValue) => bloc.add(
              UpdateItemEvent(e, e.copy(shortName: newValue)),
            ),
          ),
          EditableNameField(
            value: e.fullName,
            onChanged: (newValue) => bloc.add(
              UpdateItemEvent(e, e.copy(fullName: newValue)),
            ),
          ),
          DeleteButton(
            onPressed: () => bloc.add(DeleteItemEvent(e)),
          ),
        ],
      );
    }).toList();
  }
}
