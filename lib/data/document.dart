import 'dart:io';
import 'dart:math';

import 'package:kres_requests2/data/worksheet.dart';

/// Contains info about whole set of work blanks for special date
class Document {
  /// Current document save path.
  /// `null` values means document save path is not defined
  File savePath;

  /// Document worksheets
  List<Worksheet> get worksheets => List.unmodifiable(_worksheets);

  List<Worksheet> _worksheets;

  int _activeWorksheet = 0;

  Worksheet get active => _worksheets[_activeWorksheet];

  set active(Worksheet worksheet) {
    _activeWorksheet = max(_worksheets.indexOf(worksheet), 0);
  }

  Document({this.savePath, List<Worksheet> worksheets})
      : _worksheets = worksheets,
        assert(worksheets != null);

  Document.empty() {
    _worksheets = [];
    addEmptyWorksheet();
  }

  Worksheet addEmptyWorksheet({String name}) {
    name ??= "Лист ${_worksheets.length + 1}";
    String worksheetName;
    var attempt = 0;
    do {
      worksheetName = "$name${attempt > 0 ? "($attempt)" : ""}";
      attempt++;
    } while (_worksheets.any((w) => w.name == worksheetName));

    final worksheet = Worksheet(name: worksheetName);
    _worksheets.add(worksheet);
    return worksheet;
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

  // TODO: Implement raid creation
  Worksheet addEmptyRaidWorksheet() => throw UnimplementedError();
}
