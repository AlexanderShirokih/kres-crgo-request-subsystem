import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;

/// Describes information about recently opened document
class RecentDocumentInfo extends Equatable {
  /// Full document path
  final File path;

  /// Document name that can to display
  String get name => p.basenameWithoutExtension(path.path);

  /// Last file modification date
  DateTime get updateDate => path.lastModifiedSync();

  const RecentDocumentInfo({
    required this.path,
  });

  @override
  List<Object?> get props => [path, updateDate];
}
