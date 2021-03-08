import 'dart:io';

import 'package:kres_requests2/data/process_executor.dart';

import 'models/java_process_info.dart';

class JavaProcessExecutor extends ProcessExecutor {
  final String? Function() javaHome;
  final JavaProcessInfo javaProcessInfo;

  const JavaProcessExecutor({
    required this.javaHome,
    required this.javaProcessInfo,
  });

  @override
  Future<ProcessResult> runProcess(List<String> args) async {
    final javaBin = _getJavaExecutable();

    if (!await _isJavaBinariesExists(javaBin)) {
      throw ('Java executable does not exists!');
    }

    if (!await Directory(javaProcessInfo.appHome).exists()) {
      throw ('Requests processor module does not exists!');
    }

    final res =
        await Process.run(javaBin.absolute.path, await _buildArgs(args));
    return res;
  }

  File _getJavaExecutable() => Platform.isWindows
      ? File('${javaHome()}/bin/javaw.exe')
      : File('${javaHome()}/bin/javaw');

  @override
  Future<bool> isAvailable() => _isJavaBinariesExists(_getJavaExecutable());

  Future<bool> _isJavaBinariesExists(File javaBin) => javaBin.exists();

  Future<List<String>> _buildArgs(List<String> args) async {
    final classPath = await _resolveClasspath();

    return ['-classpath', classPath, javaProcessInfo.mainClassName, ...args];
  }

  Future<String> _resolveClasspath() async {
    final appHome = Directory(javaProcessInfo.appHome);

    if (!await appHome.exists()) {
      throw ('Java app home folder "${appHome.absolute.path} is not exists"');
    }

    return javaProcessInfo.classpath
        .replaceAll('%APP_HOME%', appHome.absolute.path);
  }
}
