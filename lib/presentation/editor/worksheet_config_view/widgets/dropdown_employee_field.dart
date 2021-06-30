import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/domain/models/employee.dart';

typedef OnEmployeeChanged = void Function(Employee?);
typedef CheckForDuplicatesCallback = bool Function(Employee);

/// Shows dropdown employee field
class DropdownEmployeeField extends StatelessWidget {
  /// Label used when field is empty
  final String positionLabel;

  /// Currently chosen employee.
  final Employee? current;

  /// List of all available for choosing employees
  final Iterable<Employee> employees;

  /// Callback used when employee has changed
  final OnEmployeeChanged onChanged;

  /// Callback used when remove button is pressed. When `null` then the remove
  /// button is hidden
  final Function()? onRemove;

  /// Function for checking for duplicates at another employee positions
  final CheckForDuplicatesCallback checkForDuplicates;

  const DropdownEmployeeField({
    required this.positionLabel,
    required this.current,
    required this.employees,
    required this.onChanged,
    required this.checkForDuplicates,
    this.onRemove,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (onRemove != null)
          IconButton(
              icon: FaIcon(FontAwesomeIcons.timesCircle, size: 16.0),
              onPressed: onRemove),
        Expanded(
          child: DropdownButtonFormField<Employee>(
            autovalidateMode: AutovalidateMode.always,
            value: current,
            validator: (value) {
              return value == null || value.name.isEmpty
                  ? positionLabel
                  : (checkForDuplicates(value) ? 'Значение дублируется' : null);
            },
            onChanged: onChanged,
            items: employees
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(_formatEmployee(e)),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  String _formatEmployee(Employee e) =>
      '${e.name}, ${e.position.name}, ${e.accessGroup} гр.';
}
