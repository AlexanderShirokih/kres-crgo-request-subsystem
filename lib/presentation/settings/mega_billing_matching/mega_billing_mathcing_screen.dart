import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/domain/models/mega_billing_matching.dart';
import 'package:kres_requests2/domain/models/request_type.dart';
import 'package:kres_requests2/domain/validators.dart';
import 'package:kres_requests2/presentation/bloc/settings/common/undoable_bloc.dart';
import 'package:kres_requests2/presentation/bloc/settings/common/undoable_events.dart';
import 'package:kres_requests2/presentation/bloc/settings/mega_billing_matching/mega_billing_matching_bloc.dart';
import 'package:kres_requests2/presentation/bloc/settings/mega_billing_matching/mega_billing_matching_data.dart';
import 'package:kres_requests2/presentation/common/table_view.dart';
import 'package:kres_requests2/presentation/settings/common/undoable_editor_screen.dart';
import 'package:kres_requests2/presentation/settings/common/widgets/delete_button.dart';
import 'package:kres_requests2/presentation/settings/common/widgets/editable_name_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages  mega-billing type associations.
class MegaBillingMatchingScreen extends StatelessWidget
    implements TableRowBuilder<MegaBillingMatchingData> {
  const MegaBillingMatchingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => UndoableEditorScreen(
        blocBuilder: (_) => MegaBillingMatchingBloc(
          Modular.get(),
          Modular.get(),
          Modular.get(),
        ),
        addItemButtonName: 'Добавить ассоциацию',
        addItemIcon: const FaIcon(FontAwesomeIcons.wrench),
        tableHeader: const [
          TableHeadingColumn(
              label: Text('Тип заявки Mega-Billing'), preferredWidth: 320.0),
          TableHeadingColumn(
              label: Text('Внутренняя ассоциация'), preferredWidth: 360.0),
          TableHeadingColumn(label: SizedBox(), preferredWidth: 60.0),
        ],
        dataRowBuilder: this,
      );

  @override
  List<TableDataRow> buildDataRow(
      BuildContext context, MegaBillingMatchingData dataHolder) {
    final bloc = context
        .read<UndoableBloc<MegaBillingMatchingData, MegaBillingMatching>>();
    return dataHolder.data.map((e) {
      return TableDataRow(
        key: ObjectKey(e),
        cells: [
          EditableNameField(
            validator: Modular.get<MappedValidator<MegaBillingMatching>>()
                .findValidator<StringValidator>('mb_match'),
            value: e.megaBillingNaming,
            onChanged: (newValue) =>
                _fireItemChanged(bloc, e, e.copy(megaBillingNaming: newValue)),
          ),
          _createRequestTypeDropdown(bloc, e, dataHolder),
          DeleteButton(onPressed: () => bloc.add(DeleteItemEvent(e))),
        ],
      );
    }).toList();
  }

  Widget _createRequestTypeDropdown(
          UndoableBloc<MegaBillingMatchingData, MegaBillingMatching> bloc,
          MegaBillingMatching e,
          MegaBillingMatchingData data) =>
      SizedBox(
        width: 140.0,
        child: DropdownButton<RequestType>(
          onChanged: (newRequestType) =>
              _fireItemChanged(bloc, e, e.copy(requestType: newRequestType)),
          value: e.requestType,
          items: {...data.availableRequestTypes, e.requestType}
              .map(
                (e) => DropdownMenuItem<RequestType>(
                  child: Text(e.fullName),
                  value: e,
                ),
              )
              .toList(),
        ),
      );

  void _fireItemChanged(
          UndoableBloc<MegaBillingMatchingData, MegaBillingMatching> bloc,
          MegaBillingMatching source,
          MegaBillingMatching updated) =>
      bloc.add(UpdateItemEvent(source, updated));
}
