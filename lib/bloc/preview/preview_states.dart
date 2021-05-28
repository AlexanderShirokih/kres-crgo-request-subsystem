part of 'preview_bloc.dart';

/// Base state for [PreviewBloc]
@sealed
abstract class PreviewState extends Equatable {
  const PreviewState._();
}

/// Default state of preview screen
class PreviewInitialState extends PreviewState {
  const PreviewInitialState() : super._();

  @override
  List<Object?> get props => [];
}

/// The state used when document has no pages to deal with
class EmptyDocumentState extends PreviewState {
  const EmptyDocumentState() : super._();

  @override
  List<Object?> get props => [];
}

/// The main state used to show document worksheets for printing or exporting
class ShowDocumentState extends PreviewState {
  final Document _document;

  /// List of checked worksheets for printing
  final List<Worksheet> selectedWorksheets;

  /// List of non empty worksheets
  final List<Worksheet> allWorksheet;

  const ShowDocumentState(
    this._document, {
    required this.selectedWorksheets,
    required this.allWorksheet,
  }) : super._();

  /// Returns `true` if document has selected worksheets to export
  bool get hasPrintableWorksheets => selectedWorksheets.isNotEmpty;

  @override
  List<Object?> get props => [selectedWorksheets];

  /// Creates document that contains only selected worksheet
  Document get printableDocument {
    if (!hasPrintableWorksheets) {
      throw 'There are no printable worksheets';
    }

    final document = Document(
      updateDate: _document.currentUpdateDate,
      savePath: _document.currentSavePath,
    );

    document.worksheets.addWorksheets(selectedWorksheets);

    return document;
  }

  /// Creates a copy of the object with customizable parameters
  ShowDocumentState copy({List<Worksheet>? selectedWorksheets}) =>
      ShowDocumentState(
        _document,
        allWorksheet: allWorksheet,
        selectedWorksheets: selectedWorksheets ?? this.selectedWorksheets,
      );
}
