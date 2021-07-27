import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:kres_requests2/domain/editor/document_saver.dart';
import 'package:path/path.dart' as path;
import 'package:rxdart/rxdart.dart';

import 'worksheets_list.dart';

/// Contains info about whole set of work blanks for special date
class Document extends Equatable {
  final BehaviorSubject<File> _savePath = BehaviorSubject();

  final BehaviorSubject<DateTime> _updateDate =
      BehaviorSubject.seeded(DateTime.now());

  /// Current document save path.
  /// `null` values means document save path is not defined
  Stream<File?> get savePathStream => _savePath;

  /// Last save date
  Stream<DateTime> get updateDateStream => _updateDate;

  /// Last save date
  DateTime get currentUpdateDate => _updateDate.requireValue;

  /// List of all worksheets
  final WorksheetsList worksheets = WorksheetsList();

  /// Directory where document saved or could be saved
  String get workingDirectory {
    final savePath = currentSavePath;
    if (savePath == null) return './';
    return path.dirname(savePath.path);
  }

  /// Returns current save path
  File? get currentSavePath => _savePath.value;

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

  /// Creates an empty document with single worksheet
  Document.empty() {
    worksheets.add().commit();
  }

  /// Stores document in [DocumentSaver].
  /// Before calling this function. Document should have [savePathStream] set.
  Future<void> save(DocumentSaver saver) async {
    if (!_savePath.hasValue) {
      throw ('savePath == null!');
    }

    await saver.store(this);

    _updateDate.add(DateTime.now());
  }

  /// Closes all internal resources
  Future<void> close() async {
    await _updateDate.close();
    await _savePath.close();

    await worksheets.close();
  }

  /// Updates save path of the document
  void setSavePath(File savePath) {
    _savePath.add(savePath);
  }

  /// Returns suggested filename without extension based update date
  String get suggestedName {
    final savePath = currentSavePath;
    final updateDate = currentUpdateDate;
    String fmtDate(DateTime d) => DateFormat('dd.MM.yyyy').format(d);
    return savePath == null
        ? 'Заявки ${fmtDate(updateDate)}'
        : path.basenameWithoutExtension(savePath.path);
  }

  @override
  List<Object?> get props => [
        _updateDate.value,
        _savePath.value,
        worksheets,
      ];
}
