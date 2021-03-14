import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:kres_requests2/repo/settings_repository.dart';

class JavaPathSelectorScreen extends StatelessWidget {
  final SettingsRepository settingsRepository;

  const JavaPathSelectorScreen({Key? key, required this.settingsRepository})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Текущий путь к Java:',
            style: Theme.of(context).textTheme.headline5,
          ),
          const SizedBox(height: 12.0),
          Text(_getCurrentJavaPath()),
          const SizedBox(height: 12.0),
          ElevatedButton(
            onPressed: () => _showJavaPathSelector().then((newPath) {
              if (newPath != null) {
                settingsRepository.javaPath = newPath;
              }
            }),
            child: Text('Изменить'),
          ),
        ],
      ),
    );
  }

  // TODO: Move logic to bloc or viewmodel
  String _getCurrentJavaPath() {
    final path = settingsRepository.javaPath;
    if (path == null) return '(Не установлено)';
    final filePath = Directory(path).absolute;
    if (!filePath.existsSync()) {
      return '(Не существует!)';
    }
    return path;
  }

  Future<String?> _showJavaPathSelector() => getDirectoryPath(
        confirmButtonText: 'Выбрать',
      );
}
