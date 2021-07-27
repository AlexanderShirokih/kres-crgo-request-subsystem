import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String errorDescription;
  final StackTrace? stackTrace;

  const ErrorView({
    Key? key,
    required this.errorDescription,
    this.stackTrace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: Card(
          elevation: 5.0,
          margin: const EdgeInsets.all(10.0),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24.0),
                Text('Ой, кажется произошла ошибка😢',
                    style: Theme.of(context).textTheme.headline6),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12.0),
                    children: [
                      Text(errorDescription,
                          style: Theme.of(context).textTheme.bodyText2),
                      const SizedBox(height: 24.0),
                      Text(stackTrace?.toString() ?? "",
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

  const LoadingView(this.label, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 18.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      );
}
