import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/bloc/settings/common/undoable_bloc.dart';
import 'package:kres_requests2/bloc/settings/common/undoable_events.dart';
import 'package:kres_requests2/bloc/settings/request_types/request_type_bloc.dart';
import 'package:kres_requests2/bloc/settings/request_types/request_type_data.dart';
import 'package:kres_requests2/domain/models/request_type.dart';
import 'package:kres_requests2/domain/validators.dart';
import 'package:kres_requests2/screens/common/table_view.dart';
import 'package:kres_requests2/screens/settings/common/undoable_editor_screen.dart';
import 'package:kres_requests2/screens/settings/common/widgets/delete_button.dart';
import 'package:kres_requests2/screens/settings/common/widgets/editable_name_field.dart';

/// Manages request types.
class RequestTypesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => UndoableEditorScreen(
        blocBuilder: (_) => RequestTypeBloc(Modular.get(), Modular.get()),
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
    final validator = Modular.get<MappedValidator<RequestType>>();
    return dataHolder.data.map((e) {
      return TableDataRow(
        key: ObjectKey(e),
        cells: [
          EditableNameField(
            value: e.shortName,
            validator: validator.findValidator('shortName'),
            onChanged: (newValue) => bloc.add(
              UpdateItemEvent(e, e.copy(shortName: newValue)),
            ),
          ),
          EditableNameField(
            value: e.fullName,
            validator: validator.findValidator('fullName'),
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
