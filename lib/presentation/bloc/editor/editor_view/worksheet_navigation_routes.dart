import 'package:kres_requests2/domain/models.dart';

/// Describes worksheet navigation routes to start
/// another pages or dialogs
abstract class WorksheetNavigationRoutes {
  /// Shows  request editor dialog to edit requests
  Future<void> showRequestEditorDialog(
    Worksheet editableWorksheet,
    Document owningDocument, [
    Request? initial,
  ]);
}
