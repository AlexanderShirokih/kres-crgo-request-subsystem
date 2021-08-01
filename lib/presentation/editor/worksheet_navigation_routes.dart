import 'package:flutter/material.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:kres_requests2/domain/models/request_entity.dart';
import 'package:kres_requests2/domain/models/worksheet.dart';
import 'package:kres_requests2/domain/validators.dart';
import 'package:kres_requests2/presentation/bloc/editor/editor_view/worksheet_navigation_routes.dart';
import 'package:kres_requests2/presentation/editor/request_editor_dialog/request_editor_dialog.dart';

class WorksheetNavigationRoutesImpl implements WorksheetNavigationRoutes {
  /// Context to start the dialog
  final BuildContext context;

  /// Validator to validate requests
  final MappedValidator<Request> validator;

  const WorksheetNavigationRoutesImpl(this.context, this.validator);

  @override
  Future<void> showRequestEditorDialog(
      Worksheet editableWorksheet, Document owningDocument,
      [Request? initial]) async {
    await showDialog(
      context: context,
      builder: (_) => RequestEditorDialog(
        worksheet: editableWorksheet,
        document: owningDocument,
        validator: validator,
        initial: initial,
      ),
    );
  }
}
