import 'package:flutter/material.dart';
import 'package:kres_requests2/data/document.dart';

class WorksheetsPreviewScreen extends StatelessWidget {
  final Document document;

  const WorksheetsPreviewScreen(this.document);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Вывод документа'),
      ),
      body: Container(),
    );
  }
}
