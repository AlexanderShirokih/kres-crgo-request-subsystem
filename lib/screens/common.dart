import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String errorDescription;
  final String stackTrace;
  final VoidCallback onPressed;

  const ErrorView({
    this.errorDescription,
    this.stackTrace,
    @required this.onPressed,
  }) : assert(onPressed != null);

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
                    children: [
                      Text(errorDescription ?? "",
                          style: Theme.of(context).textTheme.bodyText2),
                      SizedBox(height: 24.0),
                      Text(stackTrace ?? "",
                          style: Theme.of(context).textTheme.bodyText2)
                    ],
                  ),
                ),
                RaisedButton(
                  onPressed: onPressed,
                  child: Text("НАЗАД"),
                ),
              ],
            ),
          ),
        ),
      );
}

class LoadingView extends StatelessWidget {
  final String label;

  const LoadingView(this.label);

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 18.0),
            Text(
              label,
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      );
}
