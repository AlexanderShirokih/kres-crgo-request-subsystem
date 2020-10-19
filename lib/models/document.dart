import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:kres_requests2/models/worksheet.dart';

/// Contains info about whole set of work blanks for special date
class Document {
  /// Current document save path.
  /// `null` values means document save path is not defined
  File savePath;

  /// Document worksheets
  List<Worksheet> get worksheets => List.unmodifiable(_worksheets);

  List<Worksheet> _worksheets;

  /// Last save date
  DateTime updateDate = DateTime.now();

  int _activeWorksheet = 0;

  Worksheet get active => _worksheets[_activeWorksheet];

  /// Converts [Document] instance to JSON representation
  Map<String, dynamic> toJson() => {
        'updateDate': updateDate.millisecondsSinceEpoch,
        'activeWorksheet': _activeWorksheet,
        'worksheets': _worksheets.map((w) => w.toJson()).toList()
      };

  factory Document.fromJson(Map<String, dynamic> data) => Document._(
        (data['worksheets'] as List<dynamic>)
            .map((w) => Worksheet.fromJson(w))
            .toList(),
        data['activeWorksheet'] ?? 0,
        DateTime.fromMillisecondsSinceEpoch(data['updateDate']),
      );

  set active(Worksheet worksheet) {
    _activeWorksheet = max(_worksheets.indexOf(worksheet), 0);
  }

  Document._(
    this._worksheets,
    this._activeWorksheet,
    this.updateDate,
  );

  Document({this.savePath, List<Worksheet> worksheets})
      : _worksheets = worksheets,
        assert(worksheets != null);

  Document.empty() {
    _worksheets = [];
    addEmptyWorksheet();
  }

  void addWorksheets(List<Worksheet> worksheets) => _worksheets.addAll(
        worksheets.map(
          (w) => w.copy(name: _getUniqueName(w.name)),
        ),
      );

  Worksheet addEmptyWorksheet({String name}) {
    final worksheet = Worksheet(name: _getUniqueName(name));
    _worksheets.add(worksheet);
    return worksheet;
  }

  String _getUniqueName(String name) {
    name ??= "Лист ${_worksheets.length + 1}";
    String worksheetName;
    var attempt = 0;
    do {
      worksheetName = "$name${attempt > 0 ? "($attempt)" : ""}";
      attempt++;
    } while (_worksheets.any((w) => w.name == worksheetName));
    return worksheetName;
  }

  void removeWorksheet(Worksheet worksheet) {
    if (worksheet == active) {
      final currIndex = _worksheets.indexOf(active);
      _activeWorksheet = currIndex - 1;
      if (_activeWorksheet < 0) _activeWorksheet = currIndex + 1;
    }
    _worksheets.remove(worksheet);

    if (_activeWorksheet == _worksheets.length)
      _activeWorksheet = _worksheets.length - 1;
  }

  /// Saves [Document] instance to [savePath]
  Future save() async {
    if (savePath == null) throw ('savePath == null!');

    updateDate = DateTime.now();
    await savePath.writeAsString(json.encode(toJson()));
  }

  bool get isEmpty => _worksheets.every((worksheet) => worksheet.isEmpty);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Document &&
          runtimeType == other.runtimeType &&
          savePath == other.savePath &&
          _worksheets == other._worksheets &&
          updateDate == other.updateDate &&
          _activeWorksheet == other._activeWorksheet;

  @override
  int get hashCode =>
      savePath.hashCode ^
      _worksheets.hashCode ^
      updateDate.hashCode ^
      _activeWorksheet.hashCode;

  Document setWorksheets(List<Worksheet> worksheets) {
    if (worksheets == null || worksheets.isEmpty)
      throw ('Cannot set empty worksheet list');

    _worksheets.clear();
    _worksheets.addAll(worksheets);
    return this;
  }
}
