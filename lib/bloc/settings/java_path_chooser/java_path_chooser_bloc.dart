import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/data/java/java_process_executor.dart';
import 'package:kres_requests2/domain/repository/settings_repository.dart';
import 'package:kres_requests2/screens/bloc.dart';
import 'package:meta/meta.dart';

part 'java_path_chooser_event.dart';

/// Contains info about currently chosen JVM
class JavaInfo extends Equatable {
  final bool isOk;
  final String info;
  final String path;
  final String directory;

  JavaInfo(this.isOk, this.info, this.path)
      : directory = FileSystemEntity.isFileSync(path)
            ? File(path).parent.absolute.path
            : path;

  factory JavaInfo.fromString(String info, [String path = './']) {
    return JavaInfo(false, info, path);
  }

  @override
  List<Object?> get props => [isOk, info, path];
}

/// BLoC for java executable path chooser
class JavaPathChooserBloc extends Bloc<JavaPathChooserEvent, BaseState> {
  final SettingsRepository _settingsRepository;
  final JavaProcessExecutor _javaProcessExecutor;

  JavaPathChooserBloc(
    this._settingsRepository,
    this._javaProcessExecutor,
  ) : super(const InitialState()) {
    add(_FetchCurrentInfo());
  }

  @override
  Stream<BaseState> mapEventToState(
    JavaPathChooserEvent event,
  ) async* {
    if (event is _FetchCurrentInfo) {
      yield* _fetchCurrentInfo();
    } else if (event is UpdateJavaPath) {
      yield* _updatePath(event.path);
    }
  }

  Stream<BaseState> _fetchCurrentInfo() async* {
    final path = await _settingsRepository.javaPath;
    if (path == null) {
      yield DataState(JavaInfo.fromString('(Не установлено)'));
      return;
    }

    final filePath = Directory(path).absolute;
    if (!filePath.existsSync()) {
      yield DataState(JavaInfo.fromString('(Не существует!)', path));
      return;
    }

    final javaInfo = await _javaProcessExecutor.checkDefaultJava();

    if (javaInfo == null) {
      yield DataState(
        JavaInfo.fromString('(Выбранная папка не содержит JVM)', path),
      );
      return;
    }

    yield DataState(JavaInfo(true, javaInfo.version, javaInfo.execPath));
  }

  Stream<BaseState> _updatePath(String path) async* {
    await _settingsRepository.setJavaPath(path);
    yield* _fetchCurrentInfo();
  }
}
