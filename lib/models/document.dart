import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:kres_requests2/models/worksheet.dart';
import 'package:path/path.dart' as path;
import 'package:rxdart/rxdart.dart';

/// Contains info about whole set of work blanks for special date
class Document extends Equatable {
  final BehaviorSubject<File> _savePath = BehaviorSubject();
  final BehaviorSubject<List<Worksheet>> _worksheets =
      BehaviorSubject.seeded([]);

  final BehaviorSubject<DateTime> _updateDate =
      BehaviorSubject.seeded(DateTime.now());

  final BehaviorSubject<int> _activeWorksheet = BehaviorSubject.seeded(0);

  /// Current document save path.
  /// `null` values means document save path is not defined
  Stream<File?> get savePath => _savePath;

  /// Document worksheets
  Stream<List<Worksheet>> get worksheets =>
      _worksheets.map((ws) => List.unmodifiable(ws));

  /// Last save date
  Stream<DateTime> get updateDate => _updateDate;

  /// Returns currently active Worksheet
  Stream<Worksheet> get active =>
      Rx.combineLatest2<List<Worksheet>, int, Worksheet>(
          _worksheets, _activeWorksheet, (ws, int activeIdx) => ws[activeIdx]);

  /// Returns `true` if document is empty
  Stream<bool> get isEmpty => _worksheets.map(
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

  /// Converts [Document] instance to JSON representation
  Map<String, dynamic> toJson() => {
        'updateDate': _updateDate.requireValue.millisecondsSinceEpoch,
        'activeWorksheet': _activeWorksheet.requireValue,
        'worksheets': _worksheets.requireValue.map((w) => w.toJson()).toList()
      };

  /// Makes target [worksheet] active
  void makeActive(Worksheet worksheet) {
    _activeWorksheet.add(max(_worksheets.requireValue.indexOf(worksheet), 0));
  }

  /// Creates document from [savePath] and list of [worksheets]
  Document({
    File? savePath,
    required List<Worksheet> worksheets,
    DateTime? updateDate,
  }) {
    if (savePath != null) {
      _savePath.add(savePath);
    }
    if (updateDate != null) {
      _updateDate.add(updateDate);
    }

    _worksheets.add(worksheets);
  }

  /// Creates an empty document
  Document.empty() {
    addEmptyWorksheet();
  }

  /// Ads a list of worksheets to the document
  void addWorksheets(List<Worksheet> worksheets) {
    _worksheets.add(
      _worksheets.requireValue
        ..addAll(
          worksheets
              .map(
                (w) => w.copy(name: _getUniqueName(w.name)),
              )
              .toList(),
        ),
    );
  }

  /// Adds an empty worksheet to the document
  Worksheet addEmptyWorksheet({String? name}) {
    final worksheet = Worksheet(name: _getUniqueName(name));
    final currentWorksheets = _worksheets.requireValue;
    _worksheets.add(currentWorksheets..add(worksheet));
    return worksheet;
  }

  String _getUniqueName(String? name) {
    final currentWorksheets = _worksheets.requireValue;
    name ??= "Лист ${currentWorksheets.length + 1}";
    String worksheetName;
    var attempt = 0;
    do {
      worksheetName = "$name${attempt > 0 ? "($attempt)" : ""}";
      attempt++;
    } while (currentWorksheets.any((w) => w.name == worksheetName));
    return worksheetName;
  }

  /// Removes [worksheet] from the document
  Future<void> removeWorksheet(Worksheet worksheet) async {
    final currentWorksheets = _worksheets.requireValue;
    final activeWs = await active.first;
    if (worksheet == activeWs) {
      final currIndex = currentWorksheets.indexOf(activeWs);
      var newIndex = currIndex - 1;
      if (newIndex < 0) newIndex = currIndex + 1;
      _activeWorksheet.add(newIndex);
    }

    currentWorksheets.remove(worksheet);
    _worksheets.add(currentWorksheets);

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

    _worksheets.add(worksheets);
    makeActive(worksheets.first);
  }

  /// Closes all internal resources
  Future<void> close() async {
    await _updateDate.close();
    await _savePath.close();
    await _activeWorksheet.close();
    // TODO: Close all Worksheet sinks
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
