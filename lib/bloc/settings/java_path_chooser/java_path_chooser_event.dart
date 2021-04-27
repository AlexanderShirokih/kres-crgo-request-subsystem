part of 'java_path_chooser_bloc.dart';

/// Base event class  for [JavaPathChooserBloc]
@sealed
abstract class JavaPathChooserEvent extends Equatable {
  const JavaPathChooserEvent._();
}

/// Used internally to fetch current java path
class _FetchCurrentInfo extends JavaPathChooserEvent {
  const _FetchCurrentInfo() : super._();

  @override
  List<Object?> get props => [];
}

/// Signals to update current java executable path
class UpdateJavaPath extends JavaPathChooserEvent {
  /// Updated java executable path
  final String path;

  const UpdateJavaPath(this.path) : super._();

  @override
  List<Object?> get props => [path];
}
