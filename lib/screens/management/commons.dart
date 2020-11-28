import 'package:flutter/material.dart';

/// Builds [Text] wrapped in [ConstrainedBox] with [minWidth]
Widget buildFixedWidthText(String text, double minWidth) => ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
      ),
    );

bool _validateNotEmptyField(String text) => text == null || text.isEmpty;

/// Builds
Widget buildLabeledTextField({
  @required String fieldName,
  @required TextEditingController fieldController,
  @required double labelWidth,
  @required int maxLength,
  bool Function(String) validatorPredicate = _validateNotEmptyField,
  double fieldWidth = 300.0,
}) =>
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        buildFixedWidthText(fieldName, labelWidth),
        SizedBox(
          width: fieldWidth,
          child: TextFormField(
            controller: fieldController,
            autovalidateMode: AutovalidateMode.always,
            validator: (text) => validatorPredicate(text) ? '' : null,
            maxLength: maxLength,
          ),
        )
      ],
    );

Widget buildDropdownField<T>({
  @required double labelWidth,
  @required String labelName,
  @required double buttonWidth,
  @required T value,
  @required List<T> items,
  @required String Function(T) valueExtractor,
  @required void Function(T) onChanged,
}) =>
    Row(
      children: [
        buildFixedWidthText(labelName, labelWidth),
        SizedBox(
          width: buttonWidth,
          child: DropdownButtonFormField<T>(
            value: value,
            items: items == null
                ? null
                : items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(valueExtractor(e)),
                      ),
                    )
                    .toList(),
            onChanged: onChanged,
          ),
        )
      ],
    );
