import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/data/validators/mapped_validator.dart';
import 'package:kres_requests2/domain/models/position.dart';
import 'package:kres_requests2/screens/common/table_view.dart';
import 'package:kres_requests2/screens/settings/common/bloc/undoable_bloc.dart';
import 'package:kres_requests2/screens/settings/common/bloc/undoable_events.dart';
import 'package:kres_requests2/screens/settings/common/undoable_editor_screen.dart';
import 'package:kres_requests2/screens/settings/common/widgets/delete_button.dart';
import 'package:kres_requests2/screens/settings/common/widgets/editable_name_field.dart';
import 'package:kres_requests2/screens/settings/positions/bloc/position_bloc.dart';
import 'package:kres_requests2/screens/settings/positions/bloc/position_data.dart';

/// Manages employee positions
class PositionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => UndoableEditorScreen(
        blocBuilder: (_) => PositionBloc(Modular.get(), Modular.get()),
        addItemButtonName: 'Добавить должность',
        addItemIcon: FaIcon(FontAwesomeIcons.userPlus),
        tableHeader: [
          TableHeadingColumn(
              label: Text('Название должности'), preferredWidth: 320.0),
          TableHeadingColumn(label: const SizedBox(), preferredWidth: 60.0),
        ],
        dataRowBuilder: _buildData,
      );

  List<TableDataRow> _buildData(
      UndoableBloc<PositionData, Position> bloc, PositionData dataHolder) {
    return dataHolder.data.map((e) {
      return TableDataRow(
        key: ObjectKey(e),
        cells: [
          EditableNameField(
            value: e.name,
            validator: Modular.get<MappedValidator<Position>>()
                .findValidator('name'),
            onChanged: (newValue) =>
                bloc.add(UpdateItemEvent(e, e.copy(name: newValue))),
          ),
          DeleteButton(
            onPressed: () => bloc.add(DeleteItemEvent(e)),
          ),
        ],
      );
    }).toList();
  }
}
