import 'package:file_selector/file_selector.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/usecases/storage/update_last_working_directory.dart';
import 'package:kres_requests2/domain/usecases/usecases.dart';
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
  final UpdateLastWorkingDirectory updateWorkingDirectory;
  final AsyncUseCase<String> getWorkingDirectory;

  ExportFileChooserImpl({
    required this.getWorkingDirectory,
    required this.updateWorkingDirectory,
  });

  @override
  Future<String?> getFile(ExportFormat format, Document document) async {
    final extension = format.extension();
    final suggested = '${document.suggestedName}.$extension';
    final dotExtension = '.$extension';
    final res = await getSavePath(
      initialDirectory: document.currentSavePath?.parent.absolute.path ??
          (await getWorkingDirectory()),
      suggestedName: _correctExtension(suggested, dotExtension),
      confirmButtonText: 'Сохранить',
      acceptedTypeGroups: [
        if (format == ExportFormat.native)
          XTypeGroup(
            label: "Документ заявок",
            extensions: [extension],
          )
        else
          XTypeGroup(
            label: "Документ ${extension.toUpperCase()}",
            extensions: [extension],
          )
      ],
    );

    if (res == null) {
      return null;
    }

    await updateWorkingDirectory(res);

    return _correctExtension(res, dotExtension);
  }

  String _correctExtension(String filePath, String ext) {
    if (path.extension(filePath) != ext) return '$filePath$ext';
    return filePath;
  }
}
