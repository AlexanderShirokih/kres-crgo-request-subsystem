import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kres_requests2/domain/models.dart';

/// Shows card describing a single worksheet
class WorksheetCard extends StatelessWidget {
  static final _dateFormat = DateFormat('dd.MM.yyyy');
  final ValueChanged<bool?>? onChanged;
  final Worksheet worksheet;
  final bool isSelected;

  const WorksheetCard({
    required this.worksheet,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        child: InkWell(
          onTap: () => onChanged?.call(!isSelected),
          child: Card(
            elevation: 5.0,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        worksheet.name,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: onChanged,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _showEmployees(context),
                  const SizedBox(height: 8.0),
                  _showSubtitle(
                      context, 'Виды работ:', _joinWorkTypes(context)),
                  const SizedBox(height: 8.0),
                  _showDate(context),
                  const SizedBox(height: 8.0),
                  _showSubtitle(
                      context, 'Заявок:', Text('${worksheet.requests.length}')),
                  const SizedBox(height: 8.0),
                  _printWorksheetStatus(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _showEmployees(BuildContext ctx) => Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _printSingleEmployeeField(
              ctx,
              'Выдающий задание:',
              worksheet.chiefEmployee,
            ),
            const SizedBox(height: 8.0),
            _printSingleEmployeeField(
              ctx,
              'Производитель работ:',
              worksheet.mainEmployee,
            ),
            const SizedBox(height: 8.0),
            _printMultipleChildField(
              ctx,
              'Члены бригады:',
              worksheet.membersEmployee,
            ),
          ],
        ),
      );

  Widget _printSingleEmployeeField(
          BuildContext ctx, String label, Employee? emp) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          _printEmployeeLabel(ctx, label),
          const SizedBox(width: 6.0),
          _printEmployee(ctx, emp),
        ],
      );

  Widget _printMultipleChildField(
          BuildContext ctx, String label, Set<Employee> emp) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _printEmployeeLabel(ctx, label),
          const SizedBox(width: 6.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: emp.map((e) => _printEmployee(ctx, e)).toList(),
          )
        ],
      );

  Widget _printEmployeeLabel(BuildContext ctx, String label) => Container(
        width: 180.0,
        child: Text(
          label,
          style: Theme.of(ctx).textTheme.subtitle1!.copyWith(fontSize: 18.0),
        ),
      );

  Widget _printEmployee(BuildContext ctx, Employee? emp) {
    return emp == null
        ? Text(
            'Не выбрано',
            style: _createErrorTextStyle(ctx),
          )
        : Text(
            emp.name,
            style: Theme.of(ctx).textTheme.subtitle1!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0,
                ),
            textAlign: TextAlign.start,
          );
  }

  Widget _showDate(BuildContext context) => _showSubtitle(
        context,
        'Дата выдачи:',
        worksheet.targetDate == null
            ? Text('Не выбрано', style: _createErrorTextStyle(context))
            : Text('${_dateFormat.format(worksheet.targetDate!)}'),
      );

  Widget _showSubtitle(BuildContext context, String label, Widget child) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(
            width: 12.0,
          ),
          child,
        ],
      );

  Widget _joinWorkTypes(BuildContext ctx) => worksheet.workTypes.isEmpty
      ? Text(
          'Не выбран ни один вид работ',
          style: _createErrorTextStyle(ctx),
          textAlign: TextAlign.center,
        )
      : Flexible(
          child: Text(
            worksheet.workTypes.join(', '),
          ),
        );

  TextStyle _createErrorTextStyle(BuildContext ctx) =>
      Theme.of(ctx).textTheme.subtitle1!.copyWith(
            color: Theme.of(ctx).errorColor,
            fontWeight: FontWeight.w800,
            fontSize: 18.0,
          );

  Widget _printWorksheetStatus(BuildContext context) {
    final errors = worksheet.validate().take(3).toList();

    if (errors.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(FontAwesomeIcons.check, color: Colors.green),
          const SizedBox(width: 12.0),
          Text('Готово к печати'),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Обнаружены следующие ошибки: ',
            style: _createErrorTextStyle(context),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: errors
                  .map(
                    (e) => ListTile(
                      leading: FaIcon(FontAwesomeIcons.exclamationCircle),
                      title: Text(e),
                    ),
                  )
                  .toList(),
            ),
          )
        ],
      );
    }
  }
}
