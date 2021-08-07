part of 'db_utils_bloc.dart';

class DatabaseUtilsData extends Equatable {
  /// Path to the SQLite database
  final String currentDatabasePath;

  const DatabaseUtilsData({
    required this.currentDatabasePath,
  });

  @override
  List<Object?> get props => [
        currentDatabasePath,
      ];
}
