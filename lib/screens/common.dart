import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String errorDescription;
  final String stackTrace;

  const ErrorView({
    this.errorDescription,
    this.stackTrace,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Card(
          elevation: 5.0,
          margin: EdgeInsets.all(10.0),
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 24.0),
                Text('Ой, кажется произошла ошибка😢',
                    style: Theme.of(context).textTheme.headline6),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(12.0),
                    children: [
                      Text(errorDescription ?? "",
                          style: Theme.of(context).textTheme.bodyText2),
                      SizedBox(height: 24.0),
                      Text(stackTrace ?? "",
                          style: Theme.of(context).textTheme.bodyText2)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class LoadingView extends StatelessWidget {
  final String label;

  const LoadingView([this.label]);

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 18.0),
            Text(
              label ?? "...",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      );
}

/// Builds [Text] wrapped in [ConstrainedBox] with [minWidth]
Widget buildFixedWidthText(String text, double minWidth) => ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
      ),
    );

bool _validateNotEmptyField(String text) => text == null || text.isEmpty;

/// Builds row with text and text form field
Widget buildLabeledTextField({
  @required String fieldName,
  @required TextEditingController fieldController,
  @required int maxLength,
  bool Function(String) validatorPredicate = _validateNotEmptyField,
  double labelWidth = 160.0,
  double fieldWidth = 300.0,
  bool obscureText = false,
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
            obscureText: obscureText,
            controller: fieldController,
            autovalidateMode: AutovalidateMode.always,
            validator: (text) => validatorPredicate(text) ? '' : null,
            maxLength: maxLength,
          ),
        )
      ],
    );

Widget buildDropdownField<T>({
  bool allowEmptyValues = false,
  double labelWidth = 160.0,
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
            autovalidateMode: AutovalidateMode.always,
            validator: (value) => allowEmptyValues || value != null ? null : '',
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
