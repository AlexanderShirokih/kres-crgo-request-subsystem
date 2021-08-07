part of 'db_utils_bloc.dart';

/// Base event for [DatabaseUtilsBloc]
@sealed
abstract class DatabaseUtilsEvent extends Equatable {}

/// Triggers fetching initial data
class _FetchCurrentInfo extends DatabaseUtilsEvent {
  @override
  List<Object?> get props => [];
}

/// Used to open file dialog to update the database location
class UpdateDatabaseLocation extends DatabaseUtilsEvent {
  @override
  List<Object?> get props => [];
}

/// Executes SQLite script in database
class ImportIntoDatabase extends DatabaseUtilsEvent {
  @override
  List<Object?> get props => [];
}

/// Exports SQLite dump from the database
class ExportFromDatabase extends DatabaseUtilsEvent {
  @override
  List<Object?> get props => [];
}
