import 'package:flutter/material.dart';

/// Simple dialog for picking a date
class DateChooserDialog extends StatelessWidget {
  final DateTime currentDate;

  const DateChooserDialog({Key key, this.currentDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Выберите дату'),
      content: Container(
        width: 400.0,
        height: 350.0,
        child: CalendarDatePicker(
          initialCalendarMode: DatePickerMode.day,
          initialDate: currentDate ?? DateTime.now(),
          firstDate:
              (currentDate ?? DateTime.now()).subtract(Duration(days: 15)),
          lastDate: DateTime.now().add(Duration(days: 15)),
          onDateChanged: (newDate) => Navigator.pop(context, newDate),
        ),
      ),
    );
  }
}
