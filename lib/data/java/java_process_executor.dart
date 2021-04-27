import 'dart:convert';
import 'dart:io';

import 'package:kres_requests2/data/process_executor.dart';
import 'package:kres_requests2/data/repository/config_repository.dart';
import 'package:kres_requests2/repo/settings_repository.dart';

import 'java_info.dart';

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
    final javaHome = (await settingsRepository.javaPath) ?? '~';
    final javaBin = javaHome.endsWith('/bin') ? javaHome : '$javaHome/bin';

    File crossFile(String name) => Platform.isWindows
        ? File('$javaBin/$name.exe')
        : File('$javaBin/$name');

    final javaw = crossFile('javaw');
    if (await javaw.exists()) {
      return javaw;
    }

    return crossFile('java');
  }

  @override
  Future<bool> isAvailable() async {
    final javaExec = await _getJavaExecutable();
    return await _isJavaBinariesExists(javaExec);
  }

  Future<JavaInfo?> checkDefaultJava() async {
    final javaBin = await _getJavaExecutable();

    if (!await _isJavaBinariesExists(javaBin)) {
      return null;
    }
    final version = await _checkVersion(javaBin);

    if (version == null) {
      return null;
    }

    return JavaInfo(version, javaBin.path);
  }

  Future<String?> _checkVersion(File javaBin) async {
    final res = await Process.run(
      javaBin.absolute.path,
      ['-version'],
      stdoutEncoding: utf8,
    );

    if (res.exitCode != 0) {
      return null;
    }

    final output = res.stderr.toString();

    if (output.isEmpty) {
      return null;
    }

    return output.split('\n')[0];
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
