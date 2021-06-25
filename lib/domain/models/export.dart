import 'package:equatable/equatable.dart';

/// Data class that holds info about [preferred] printer and a list of
/// all available printers for printing documents
class PrintersList extends Equatable {
  /// The preferred printer. Can be `null` if preferred printer if not defined
  final String? preferred;

  /// All available printers list
  final List<String> available;

  const PrintersList(this.preferred, this.available);

  @override
  List<Object?> get props => [preferred, available];
}

/// Describes supported export formats
enum ExportFormat { pdf, excel }

/// Extension for getting file extension string from [ExportFormat].
extension ExportFormatExtension on ExportFormat {
  String extension() {
    switch (this) {
      case ExportFormat.pdf:
        return "pdf";
      case ExportFormat.excel:
        return "xlsx";
    }
  }
}

/// Describes exporting steps
enum ExportState {
  pickingFile,
  exporting,
  done,
  cancelled,
}
