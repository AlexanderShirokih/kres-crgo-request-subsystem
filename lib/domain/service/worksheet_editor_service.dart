import '../models.dart';

/// Service for handling actions on worksheet
class WorksheetEditorService {
  final Document document;

  const WorksheetEditorService(this.document);

  /// Swaps requests on [target] worksheet [from] one request [to] another.
  void swapRequest(Worksheet target, Request from, Request to) {
    document.worksheets.edit(target).swapRequests(from, to).commit();
  }

  /// Removes [requests] from [target] worksheet
  void removeRequests(Worksheet target, List<Request> requests) {
    document.worksheets.edit(target).removeRequests(requests).commit();
  }

  /// Listen for changes on [target] worksheet
  Stream<Worksheet> listenOn(Worksheet target) =>
      document.worksheets.streamFor(target);
}
