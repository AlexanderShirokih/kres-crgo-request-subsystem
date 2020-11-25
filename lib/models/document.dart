import 'dart:math';

import 'package:kres_requests2/models/request_set.dart';

/// Contains info about a whole set of work request sets for certain date
class Document {
  /// Document worksheets
  List<RequestSet> get requestSets => List.unmodifiable(_requestSets);

  List<RequestSet> _requestSets;

  int _activeSet = 0;

  RequestSet get active => _requestSets[_activeSet];

  factory Document.fromJson(Map<String, dynamic> data) => Document._(
        (data['worksheets'] as List<dynamic>)
            .map((w) => RequestSet.fromJson(w))
            .toList(),
        0,
      );

  set active(RequestSet worksheet) {
    _activeSet = max(_requestSets.indexOf(worksheet), 0);
  }

  Document._(
    this._requestSets,
    this._activeSet,
  );

  Document({List<RequestSet> requestSets})
      : _requestSets = requestSets,
        assert(requestSets != null);

  Document.empty() {
    _requestSets = [];
    addEmptyWorksheet();
  }

  /// TODO: Move to repository
  RequestSet addEmptyWorksheet({String name}) {
    final worksheet = RequestSet(name: _getUniqueName(name));
    _requestSets.add(worksheet);
    return worksheet;
  }

  String _getUniqueName(String name) {
    name ??= "Лист ${_requestSets.length + 1}";
    String worksheetName;
    var attempt = 0;
    do {
      worksheetName = "$name${attempt > 0 ? "($attempt)" : ""}";
      attempt++;
    } while (_requestSets.any((w) => w.name == worksheetName));
    return worksheetName;
  }

  /// TODO: Move to repository
  void removeWorksheet(RequestSet requestSet) {
    if (requestSet == active) {
      final currIndex = _requestSets.indexOf(active);
      _activeSet = currIndex - 1;
      if (_activeSet < 0) _activeSet = currIndex + 1;
    }
    _requestSets.remove(requestSet);

    if (_activeSet == _requestSets.length) _activeSet = _requestSets.length - 1;
  }

  bool get isEmpty => _requestSets.every((requestSet) => requestSet.isEmpty);

  Document setWorksheets(List<RequestSet> worksheets) {
    if (worksheets == null || worksheets.isEmpty)
      throw ('Cannot set empty worksheet list');

    _requestSets.clear();
    _requestSets.addAll(worksheets);
    return this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Document &&
          runtimeType == other.runtimeType &&
          _requestSets == other._requestSets &&
          _activeSet == other._activeSet;

  @override
  int get hashCode => _requestSets.hashCode ^ _activeSet.hashCode;
}
