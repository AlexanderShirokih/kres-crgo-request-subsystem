import 'dart:math';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:kres_requests2/domain/controller/worksheet_editor.dart';
import 'package:rxdart/rxdart.dart';

import 'employee.dart';
import 'worksheet.dart';

/// Interface used to notify about changed in the worksheet
abstract class WorksheetChangeListener {
  void onWorksheetChanged(Worksheet original, Worksheet updated);
}

/// Manages a list of worksheets and it's state
class WorksheetsList extends Equatable implements WorksheetChangeListener {
  final BehaviorSubject<int> _activeWorksheet = BehaviorSubject.seeded(0);

  final BehaviorSubject<List<WorksheetEditor>> _editors =
      BehaviorSubject.seeded([]);

  WorksheetsList();

  /// Document worksheets list as a stream
  Stream<List<Worksheet>> get stream => _editors
      .map(
        (editors) =>
            editors.map((editor) => editor.current).toList(growable: false),
      )
      .distinct(const ListEquality<Worksheet>().equals);

  /// Returns stream that emits changes of [target] worksheet
  Stream<Worksheet> streamFor(Worksheet target) => stream.flatMap((list) {
        final tId =
            list.indexWhere((ws) => ws.worksheetId == target.worksheetId);
        return tId < 0 || list[tId] == target
            ? const Stream.empty()
            : Stream.value(list[tId]);
      });

  /// Returns a list of current worksheets snapshot
  List<Worksheet> get list => _editors.requireValue
      .map((editor) => editor.current)
      .toList(growable: false);

  /// Returns currently active worksheet
  Worksheet get active =>
      _editors.requireValue[_activeWorksheet.requireValue].current;

  /// Returns currently active Worksheet
  Stream<Worksheet> get activeStream =>
      Rx.combineLatest2<List<Worksheet>, int, Worksheet>(
        stream,
        _activeWorksheet,
        (ws, int activeIdx) => ws[activeIdx],
      ).distinct();

  /// Returns `true` if document is empty (doesn't have any request)
  bool get isEmpty => list.every((worksheet) => worksheet.isEmpty);

  /// Returns stream which emits when document emptiness changes`true
  Stream<bool> get isEmptyStream => stream
      .map(
        (list) => list.every((worksheet) => worksheet.isEmpty),
      )
      .distinct();

  /// Returns index of currently active worksheet
  int get activePosition => _activeWorksheet.requireValue;

  /// Makes target [worksheet] active.
  /// Throws [StateError] if [worksheet] is not assigned to the document.
  void makeActive(Worksheet worksheet) {
    final index = _editors.requireValue.indexWhere(
      (e) => e.worksheetId == worksheet.worksheetId,
    );

    _setActiveIndex(index);
  }

  void _setActiveIndex(int index) {
    _activeWorksheet.add(max(index, 0));
  }

  /// Returns editor for [worksheet]
  /// Throws error if the editor cannot be found
  /// (worksheet is not assigned to the document)
  WorksheetEditor edit(Worksheet worksheet) {
    final editor = _findEditor(worksheet);

    if (editor == null) {
      throw 'Editor for worksheet "${worksheet.name}" if not found!';
    }

    return editor;
  }

  WorksheetEditor _createEditor(Worksheet w) {
    return _findEditor(w) ??
        WorksheetEditor(
            w.copyWith(
              name: _getUniqueName(w.name),
              worksheetId: _getUniqueId(),
            ),
            this);
  }

  WorksheetEditor? _findEditor(Worksheet w) => _editors.requireValue
      .where((e) => e.worksheetId == w.worksheetId)
      .firstOrNull;

  /// Ads a list of worksheets to the document. New worksheet ID's will be
  /// created on target document
  void addWorksheets(List<Worksheet> worksheets) {
    _editors.add(
      _editors.requireValue..addAll(worksheets.map(_createEditor)),
    );
  }

  /// Adds an empty worksheet to the document.
  /// If [activate] == `true` worksheet becomes active after inserting
  /// Returns [WorksheetEditor] to update the state of worksheet
  WorksheetEditor add({
    String? name,
    DateTime? targetDate,
    Employee? mainEmployee,
    Employee? chiefEmployee,
    Set<Employee> membersEmployee = const {},
    Set<String>? workTypes,
    bool activate = false,
  }) {
    final worksheet = _createEditor(
      Worksheet(
        name: name ?? '',
        targetDate: targetDate,
        worksheetId: _getUniqueId(),
        mainEmployee: mainEmployee,
        chiefEmployee: chiefEmployee,
        membersEmployee: membersEmployee,
        workTypes: workTypes,
        requests: const [],
      ),
    );

    final currentWorksheets = _editors.requireValue;
    _editors.add(currentWorksheets..add(worksheet));

    if (activate) {
      _setActiveIndex(currentWorksheets.length - 1);
    }
    return worksheet;
  }

  // Last worksheet id. Guaranteed to be unique for whole document. But actually
  // it unique for beside all documents in single VM instance.
  static int _lastId = 0;

  int _getUniqueId() => ++_lastId;

  String _getUniqueName(String? name) {
    final currentWorksheets = _editors.requireValue;

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
  void remove(Worksheet worksheet) {
    // Get the current worksheets
    final currentWorksheets = _editors.requireValue;

    final currIndex = _requireIndex(worksheet);

    // If deletable worksheet is active then move active marker to the next
    if (worksheet.worksheetId == active.worksheetId) {
      var newIndex = currIndex - 1;
      if (newIndex < 0) newIndex = currIndex + 1;
      _activeWorksheet.add(newIndex);
    }

    // Remove the worksheet (should be exactly one)
    currentWorksheets.removeAt(currIndex);

    // Notify updates
    _editors.add(currentWorksheets);

    // Shift active worksheet index if needed (end of list case)
    if (_activeWorksheet.requireValue == currentWorksheets.length) {
      _activeWorksheet.add(currentWorksheets.length - 1);
    }
  }

  /// Removes all worksheets from the worksheet list.
  void removeAll() {
    _editors.add([]);
  }

  /// Closes the current worksheets holder
  Future<void> close() async {
    await _editors.close();
  }

  @override
  List<Object?> get props => [
        _activeWorksheet.requireValue,
        _editors.requireValue,
      ];

  @override
  void onWorksheetChanged(Worksheet original, Worksheet updated) {
    final worksheets = _editors.requireValue;
    final index = _requireIndex(original);

    // Replace the worksheet
    worksheets[index] = _createEditor(updated);

    // Notify listeners
    _editors.add(worksheets);
  }

  int _requireIndex(Worksheet worksheet) {
    // Get the current worksheets
    final currentWorksheets = _editors.requireValue;

    final currIndex = currentWorksheets
        .indexWhere((e) => e.worksheetId == worksheet.worksheetId);

    if (currIndex < 0) {
      throw "Given worksheet doesn't exists in this document";
    }

    return currIndex;
  }
}
