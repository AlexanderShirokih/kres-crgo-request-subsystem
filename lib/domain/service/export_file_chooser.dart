import 'package:file_selector/file_selector.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:path/path.dart' as path;

/// Interface for picking filenames from the storage
abstract class ExportFileChooser {
  /// Picks file with [format] for the [document] from the storage and
  /// returns it's string path.
  /// Returns `null` if file was not selected.
  Future<String?> getFile(ExportFormat format, Document document);
}

/// Default implementation of [ExportFileChooser]
class ExportFileChooserImpl implements ExportFileChooser {
  Future<String?> getFile(ExportFormat format, Document document) async {
    final extension = format.extension();
    final suggested = '${document.suggestedName}.$extension';
    final dotExtension = '.$extension';
    final res = await getSavePath(
      initialDirectory: document.currentSavePath?.parent.absolute.path,
      suggestedName: _correctExtension(suggested, dotExtension),
      confirmButtonText: 'Сохранить',
      acceptedTypeGroups: [
        XTypeGroup(
          label: "Документ ${extension.toUpperCase()}",
          extensions: [extension],
        )
      ],
    );

    if (res == null) {
      return null;
    }

    return _correctExtension(res, dotExtension);
  }

  String _correctExtension(String filePath, String ext) {
    if (path.extension(filePath) != ext) return '$filePath$ext';
    return filePath;
  }
}
