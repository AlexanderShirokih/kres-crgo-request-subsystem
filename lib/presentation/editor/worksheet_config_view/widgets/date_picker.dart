import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kres_requests2/presentation/bloc/editor/worksheet_config_view/worksheet_config_bloc.dart';

/// Used to pick date on worksheet config list
/// Requires [WorksheetConfigBloc] to be injected in the widget tree
class DatePicker extends StatefulWidget {
  final DateTime? targetDate;

  const DatePicker({
    Key? key,
    required this.targetDate,
  }) : super(key: key);

  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  static final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  bool _isDateChosen = true;

  @override
  Widget build(BuildContext context) {
    return _isDateChosen
        ? Row(
            children: [
              Expanded(
                child: Text(
                  'Дата выдачи задания:',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              InkWell(
                onTap: () => setState(() {
                  _isDateChosen = false;
                }),
                child: FormField<DateTime>(
                  initialValue: widget.targetDate,
                  builder: (state) => state.hasError
                      ? Text(
                          state.errorText ?? 'error!',
                          style: TextStyle(
                            color: Theme.of(context).errorColor,
                          ),
                        )
                      : Text(_dateFormat.format(state.value!),
                          style: Theme.of(context).textTheme.subtitle1),
                  validator: (value) => value == null ? 'Выберите дату' : null,
                  autovalidateMode: AutovalidateMode.always,
                ),
              ),
              const SizedBox(width: 28.0),
            ],
          )
        : _showDatePicker();
  }

  Widget _showDatePicker() {
    final target = widget.targetDate ?? DateTime.now();
    return CalendarDatePicker(
      initialCalendarMode: DatePickerMode.day,
      initialDate: target,
      firstDate: target.subtract(Duration(days: 15)),
      lastDate: DateTime.now().add(Duration(days: 15)),
      onDateChanged: (newDate) {
        setState(() {
          _isDateChosen = true;
          context
              .read<WorksheetConfigBloc>()
              .add(UpdateTargetDateEvent(newDate));
        });
      },
    );
  }
}
