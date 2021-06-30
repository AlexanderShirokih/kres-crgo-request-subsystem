import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kres_requests2/presentation/common.dart';
import 'package:kres_requests2/presentation/importer/base_importer_screen.dart';

/// The page responsible for opening native file formats
class NativeImporterScreen extends ImporterScreen {
  NativeImporterScreen() : super(title: 'Импорт файла');

  @override
  Widget buildIdleView(BuildContext context) =>
      LoadingView('Ожидание открытия файла...');
}
