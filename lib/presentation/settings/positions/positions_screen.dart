import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/domain/models/position.dart';
import 'package:kres_requests2/domain/validators.dart';
import 'package:kres_requests2/presentation/bloc/settings/common/undoable_bloc.dart';
import 'package:kres_requests2/presentation/bloc/settings/common/undoable_events.dart';
import 'package:kres_requests2/presentation/bloc/settings/positions/position_bloc.dart';
import 'package:kres_requests2/presentation/bloc/settings/positions/position_data.dart';
import 'package:kres_requests2/presentation/common/table_view.dart';
import 'package:kres_requests2/presentation/settings/common/undoable_editor_screen.dart';
import 'package:kres_requests2/presentation/settings/common/widgets/delete_button.dart';
import 'package:kres_requests2/presentation/settings/common/widgets/editable_name_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages employee positions
class PositionsScreen extends StatelessWidget
    implements TableRowBuilder<PositionData> {
  const PositionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => UndoableEditorScreen(
        blocBuilder: (_) => PositionBloc(Modular.get(), Modular.get()),
        addItemButtonName: 'Добавить должность',
        addItemIcon: const FaIcon(FontAwesomeIcons.userPlus),
        tableHeader: const [
          TableHeadingColumn(
              label: Text('Название должности'), preferredWidth: 320.0),
          TableHeadingColumn(label: SizedBox(), preferredWidth: 60.0),
        ],
        dataRowBuilder: this,
      );

  @override
  List<TableDataRow> buildDataRow(
      BuildContext context, PositionData dataHolder) {
    final bloc = context.read<UndoableBloc<PositionData, Position>>();

    return dataHolder.data.map((e) {
      return TableDataRow(
        key: ObjectKey(e),
        cells: [
          EditableNameField(
            value: e.name,
            validator:
                Modular.get<MappedValidator<Position>>().findValidator('name'),
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
