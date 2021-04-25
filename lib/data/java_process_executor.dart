import 'dart:io';

import 'package:kres_requests2/data/process_executor.dart';
import 'package:kres_requests2/data/repository/config_repository.dart';
import 'package:kres_requests2/repo/settings_repository.dart';

class JavaProcessExecutor extends ProcessExecutor {
  final SettingsRepository settingsRepository;
  final ConfigRepository configRepository;

  const JavaProcessExecutor({
    required this.settingsRepository,
    required this.configRepository,
  });

  @override
  Future<ProcessResult> runProcess(List<String> args) async {
    final javaBin = await _getJavaExecutable();

    if (!await _isJavaBinariesExists(javaBin)) {
      throw ('Java executable does not exists!');
    }

    final javaProcessInfo = await configRepository.javaProcessInfo;

    if (!await Directory(javaProcessInfo.appHome).exists()) {
      throw ('Requests processor module does not exists!');
    }

    final res =
        await Process.run(javaBin.absolute.path, await _buildArgs(args));
    return res;
  }

  Future<File> _getJavaExecutable() async {
    final javaHome = await settingsRepository.javaPath;
    return Platform.isWindows
        ? File('$javaHome/bin/javaw.exe')
        : File('$javaHome/bin/javaw');
  }

  @override
  Future<bool> isAvailable() async {
    final javaExec = await _getJavaExecutable();
    return await _isJavaBinariesExists(javaExec);
  }

  Future<bool> _isJavaBinariesExists(File javaBin) => javaBin.exists();

  Future<List<String>> _buildArgs(List<String> args) async {
    final classPath = await _resolveClasspath();

    final javaProcessInfo = await configRepository.javaProcessInfo;

    return ['-classpath', classPath, javaProcessInfo.mainClassName, ...args];
  }

  Future<String> _resolveClasspath() async {
    final javaProcessInfo = await configRepository.javaProcessInfo;

    final appHome = Directory(javaProcessInfo.appHome);

    if (!await appHome.exists()) {
      throw ('Java app home folder "${appHome.absolute.path} is not exists"');
    }

    return javaProcessInfo.classpath
        .replaceAll('%APP_HOME%', appHome.absolute.path);
  }
}
