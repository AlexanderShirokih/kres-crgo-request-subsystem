import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:path/path.dart' as path;

class ErrorView extends StatelessWidget {
  final String errorDescription;
  final StackTrace? stackTrace;

  const ErrorView({
    required this.errorDescription,
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
                      Text(errorDescription,
                          style: Theme.of(context).textTheme.bodyText2),
                      SizedBox(height: 24.0),
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
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      );
}

Future<String?> showSaveDialog(
    Document currentDoc, String currentDirectory) async {
  final res = await getSavePath(
    suggestedName: await getSuggestedName(currentDoc, '.json').first,
    initialDirectory: currentDirectory,
    confirmButtonText: 'Сохранить',
    acceptedTypeGroups: [
      XTypeGroup(
        label: "Документ заявок",
        extensions: ["json"],
      )
    ],
  );
  return res;
}

Stream<String> getSuggestedName(Document currentDocument, String ext) {
  String fmtDate(DateTime d) => DateFormat('dd.MM.yyyy').format(d);
  return currentDocument.savePath.asyncMap((file) async => file == null
      ? "Заявки ${fmtDate(await currentDocument.updateDate.first)}$ext"
      : "${path.basenameWithoutExtension(file.path)}$ext");
}
