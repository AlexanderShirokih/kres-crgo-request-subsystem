import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';

import 'package:kres_requests2/models/document.dart';

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

  const LoadingView(this.label);

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

mixin DocumentSaverMixin<T extends StatefulWidget> on State<T> {
  static final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  Document currentDocument;
  String currentDirectory;

  Future<String> saveDocument(
    BuildContext context,
    bool changePath,
  ) async {
    if (currentDocument.savePath == null || changePath) {
      final newSavePath = await _showSaveDialog();
      if (newSavePath == null) return null;

      setState(() {
        currentDocument.savePath = newSavePath;
      });
    }

    final scaffold = Scaffold.of(context, nullOk: true);

    void showSnackbar(String message, Duration duration) =>
        scaffold?.showSnackBar(
          SnackBar(
            content: Text(message),
            duration: duration,
          ),
        );

    showSnackbar('Сохранение...', const Duration(seconds: 20));

    return currentDocument
        .save()
        .then((_) {
          scaffold?.removeCurrentSnackBar();
          showSnackbar(
            'Документ сохранён',
            const Duration(seconds: 2),
          );
        })
        .then((_) => currentDocument.savePath.path)
        .catchError(
          (e, s) {
            print("$e\n$s");
            scaffold?.removeCurrentSnackBar();
            showSnackbar(
              'Не удалось сохранить! $e',
              const Duration(seconds: 6),
            );
            return null;
          },
        );
  }

  Future<File> _showSaveDialog() async {
    final res = await showSavePanel(
      suggestedFileName: getSuggestedName('.json'),
      initialDirectory: currentDirectory,
      confirmButtonText: 'Сохранить',
      allowedFileTypes: [
        FileTypeFilterGroup(
          label: "Документ заявок",
          fileExtensions: ["json"],
        )
      ],
    );
    if (res.canceled) return null;

    final savePath = res.paths[0];
    currentDirectory = path.dirname(savePath);

    if (path.extension(savePath) != '.json') return File('$savePath.json');
    return File(savePath);
  }

  String getSuggestedName(String ext) {
    String fmtDate(DateTime d) => _dateFormat.format(d);
    return currentDocument.savePath == null
        ? "Заявки ${fmtDate(currentDocument.updateDate)}$ext"
        : "${path.basenameWithoutExtension(currentDocument.savePath.path)}$ext";
  }
}
