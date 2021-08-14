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
  final List<DocumentDescriptor> all;

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
  final bool force;

  const CreatePage([this.force = false]) : super._();

  @override
  List<Object?> get props => [force];
}

/// Imports document from the storage
class ImportPage extends DocumentMasterEvent {
  const ImportPage() : super._();

  @override
  List<Object?> get props => [];
}

/// Event used to create new document from mega-billing requests
class ImportMegaBillingRequests extends DocumentMasterEvent {
  const ImportMegaBillingRequests() : super._();

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

/// Defines what app should to do after document has saved
enum EventBehaviour { pop, nothing }

/// Event used to save all opened documents
class SaveAllEvent extends DocumentMasterEvent {
  final EventBehaviour saveAllBehaviour;

  const SaveAllEvent(this.saveAllBehaviour) : super._();

  @override
  List<Object?> get props => [saveAllBehaviour];
}

/// Discard all changes in all opened documents
class DiscardChangesEvent extends DocumentMasterEvent {
  final EventBehaviour discardAllBehaviour;

  const DiscardChangesEvent(this.discardAllBehaviour) : super._();

  @override
  List<Object?> get props => [discardAllBehaviour];
}

/// Event used to toggle searching mode with some searching text
/// If [searchText] is empty search mode will be disabled
class WorksheetMasterSearchEvent extends DocumentMasterEvent {
  final String searchText;

  const WorksheetMasterSearchEvent(this.searchText) : super._();

  @override
  List<Object?> get props => [searchText];
}
