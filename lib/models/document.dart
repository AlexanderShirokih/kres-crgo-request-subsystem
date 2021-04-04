import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:kres_requests2/domain/controller/worksheet_editor.dart';
import 'package:kres_requests2/models/worksheet.dart';
import 'package:path/path.dart' as path;
import 'package:rxdart/rxdart.dart';

/// Contains info about whole set of work blanks for special date
class Document extends Equatable {
  final BehaviorSubject<File> _savePath = BehaviorSubject();

  final BehaviorSubject<List<WorksheetEditor>> _worksheets =
      BehaviorSubject.seeded([]);

  final BehaviorSubject<DateTime> _updateDate =
      BehaviorSubject.seeded(DateTime.now());

  final BehaviorSubject<int> _activeWorksheet = BehaviorSubject.seeded(0);

  /// Current document save path.
  /// `null` values means document save path is not defined
  Stream<File?> get savePath => _savePath;

  /// Document worksheets
  Stream<List<Worksheet>> get worksheets => _worksheets.stream.flatMap(
        (event) => Rx.combineLatestList(
          event.map((e) => e.actualState),
        ),
      );

  /// Returns a list of current worksheets snapshot
  List<Worksheet> get currentWorksheets =>
      _worksheets.requireValue.map((e) => e.current).toList();

  /// Returns currently active worksheet
  Worksheet get currentActive =>
      _worksheets.requireValue[_activeWorksheet.requireValue].current;

  /// Last save date
  Stream<DateTime> get updateDate => _updateDate;

  /// Returns currently active Worksheet
  Stream<Worksheet> get active =>
      Rx.combineLatest2<List<Worksheet>, int, Worksheet>(
        worksheets,
        _activeWorksheet,
        (ws, int activeIdx) => ws[activeIdx],
      );

  /// Returns `true` if document is empty
  Stream<bool> get isEmpty => worksheets.map(
        (list) => list.every((worksheet) => worksheet.isEmpty),
      );

  /// Directory where document saved or could be saved
  Stream<String> get workingDirectory => Rx.concat(
        [
          Stream.value('./'),
          _savePath.map(
            (file) => path.dirname(file.path),
          ),
        ],
      );

  /// Returns current save path
  Future<File?> get currentSavePath async {
    try {
      return await savePath.first;
    } on StateError {
      return null;
    }
  }

  /// Converts [Document] instance to JSON representation
  Map<String, dynamic> toJson() => {
        'updateDate': _updateDate.requireValue.millisecondsSinceEpoch,
        'activeWorksheet': _activeWorksheet.requireValue,
        'worksheets':
            _worksheets.requireValue.map((w) => w.current.toJson()).toList()
      };

  /// Makes target [worksheet] active
  void makeActive(Worksheet worksheet) {
    final index = _worksheets.requireValue.indexWhere(
      (e) => e.current.worksheetId == worksheet.worksheetId,
    );

    _activeWorksheet.add(max(index, 0));
  }

  /// Creates document from [savePath] and list of [worksheets]
  Document({
    File? savePath,
    DateTime? updateDate,
  }) {
    if (savePath != null) {
      _savePath.add(savePath);
    }
    if (updateDate != null) {
      _updateDate.add(updateDate);
    }
  }

  /// Creates an empty document
  Document.empty() {
    addEmptyWorksheet();
  }

  /// Returns editor for [worksheet]
  /// Throws [StateError] if the editor cannot be found
  WorksheetEditor edit(Worksheet worksheet) {
    final currentWorksheets = _worksheets.requireValue;
    return currentWorksheets.singleWhere(
      (e) => e.current.worksheetId == worksheet.worksheetId,
    );
  }

  WorksheetEditor _createEditor(Worksheet w) {
    return WorksheetEditor(
      w.copy(
        name: _getUniqueName(w.name),
        worksheetId: _getUniqueId(),
      ),
    );
  }

  /// Ads a list of worksheets to the document. New worksheet ID's will be
  /// created on target document
  void addWorksheets(List<Worksheet> worksheets) {
    _worksheets.add(
      _worksheets.requireValue
        ..addAll(
          worksheets.map(_createEditor).toList(),
        ),
    );
  }

  /// Adds an empty worksheet to the document.
  /// Returns [WorksheetEditor] to update the state of worksheet
  WorksheetEditor addEmptyWorksheet({String? name}) {
    final worksheet = _createEditor(
      Worksheet(
        name: name ?? '',
        worksheetId: 0,
        requests: const [],
      ),
    );

    final currentWorksheets = _worksheets.requireValue;
    _worksheets.add(currentWorksheets..add(worksheet));
    return worksheet;
  }

  // Last worksheet id. Guaranteed to be unique for whole document. But actually
  // it unique for beside all documents in single VM instance.
  static int _lastId = 0;

  int _getUniqueId() => ++_lastId;

  String _getUniqueName(String? name) {
    final currentWorksheets = _worksheets.requireValue;

    if (name?.isEmpty ?? true) {
      name = "Лист ${currentWorksheets.length + 1}";
    }

    String worksheetName;
    var attempt = 0;
    do {
      worksheetName = "$name${attempt > 0 ? "($attempt)" : ""}";
      attempt++;
    } while (currentWorksheets.any((w) => w.current.name == worksheetName));
    return worksheetName;
  }

  /// Removes [worksheet] from the document
  Future<void> removeWorksheet(Worksheet worksheet) async {
    // Get the current worksheets
    final currentWorksheets = _worksheets.requireValue;

    // Find the active worksheet
    final activeWs = (await active.first);

    // Find the editor and it's index
    final editor = edit(worksheet);
    final currIndex = currentWorksheets.indexOf(editor);

    if (currIndex < 0) {
      throw "Given worksheet doesn't exists in this document";
    }

    // If deletable worksheet is active then move active marker to the next
    if (worksheet.worksheetId == activeWs.worksheetId) {
      var newIndex = currIndex - 1;
      if (newIndex < 0) newIndex = currIndex + 1;
      _activeWorksheet.add(newIndex);
    }

    // Remove worksheet with the same worksheet (should be only one)
    final curr = currentWorksheets[currIndex];
    currentWorksheets.removeAt(currIndex);

    // Close internal streams
    await curr.close();

    // Fetch updates
    _worksheets.add(currentWorksheets);

    // Shift active worksheet index if needed (end of list case)
    if (_activeWorksheet.requireValue == currentWorksheets.length) {
      _activeWorksheet.add(currentWorksheets.length - 1);
    }
  }

  /// Saves document in local storage
  /// If [changePath] is `true` save path will be updated by picking it from
  /// [savePathChooser].
  /// Returns `true` if document was saved to the storage.
  Future<bool> saveDocument(
    bool changePath,
    Future<String?> Function(Document document, String workingDirectory)
        savePathChooser,
  ) async {
    final savePath = _savePath.value;

    if (savePath == null || changePath) {
      final chosenSavePath = await savePathChooser(
        this,
        await workingDirectory.first,
      );

      if (chosenSavePath == null) return false;

      _savePath.add(
        path.extension(chosenSavePath) != '.json'
            ? File('$chosenSavePath.json')
            : File(chosenSavePath),
      );
    }

    await _save();
    return true;
  }

  Future<void> _save() async {
    if (!_savePath.hasValue) {
      throw ('savePath == null!');
    }

    _updateDate.add(DateTime.now());

    await _savePath.requireValue.writeAsString(json.encode(toJson()));
  }

  /// Replaces all worksheets in the document
  void setWorksheets(List<Worksheet> worksheets) {
    if (worksheets.isEmpty) {
      throw ('Cannot set an empty worksheet list');
    }

    // Close the current worksheets
    for (final ws in _worksheets.requireValue) {
      ws.close();
    }

    _worksheets.add(worksheets.map(_createEditor).toList());
    makeActive(worksheets.first);
  }

  /// Closes all internal resources
  Future<void> close() async {
    await _updateDate.close();
    await _savePath.close();
    await _activeWorksheet.close();

    await for (final wsEditor in _worksheets.stream) {
      for (final ws in wsEditor) {
        await ws.close();
      }
    }

    await _worksheets.close();
  }

  /// Updates save path of the document
  void setSavePath(File savePath) {
    _savePath.add(savePath);
  }

  @override
  List<Object?> get props => [
        _updateDate.value,
        _activeWorksheet.value,
        _savePath.value,
        _worksheets.value,
      ];
}
