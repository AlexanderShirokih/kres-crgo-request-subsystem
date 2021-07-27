part of 'document_master_bloc.dart';

/// Base abstract event for [DocumentMasterBloc]
@sealed
abstract class DocumentMasterEvent extends Equatable {
  const DocumentMasterEvent._();
}

/// Sets the currently selected document and the list of all opened.
class SetDocuments extends DocumentMasterEvent {
  /// Currently selected document
  /// Can be `null` if there are no opened documents
  final Document? selected;
  final List<Document> all;

  const SetDocuments(this.selected, this.all) : super._();

  @override
  List<Object?> get props => [selected, all];
}

/// Sets the currently selected document
class SetSelectedPage extends DocumentMasterEvent {
  final Document selected;

  const SetSelectedPage(this.selected) : super._();

  @override
  List<Object?> get props => [selected];
}

/// Deletes [target] page from the opened documents list.
/// If page has unsaved changes, BLoC will ask for save before close
class DeletePage extends DocumentMasterEvent {
  final Document target;

  const DeletePage(this.target) : super._();

  @override
  List<Object?> get props => [target];
}

/// Creates an empty document in a new tab
class CreatePage extends DocumentMasterEvent {
  const CreatePage() : super._();

  @override
  List<Object?> get props => [];
}

/// Event that used when user wants to save current document.
class SaveEvent extends DocumentMasterEvent {
  /// If `true` 'Save as' behaviour will be used.
  final bool changePath;

  /// If [popAfterSave] is `true` that the page will popped after file have saved.
  final bool popAfterSave;

  const SaveEvent({this.changePath = false, this.popAfterSave = false})
      : super._();

  @override
  List<Object> get props => [changePath, popAfterSave];
}

/// Event used to toggle searching mode with some searching text
/// If [searchText] is `null` search mode will be disabled
class WorksheetMasterSearchEvent extends DocumentMasterEvent {
  final String? searchText;

  const WorksheetMasterSearchEvent([this.searchText]) : super._();

  @override
  List<Object?> get props => [searchText];
}
