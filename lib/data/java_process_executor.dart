import 'dart:io';

import 'package:kres_requests2/data/process_executor.dart';
import 'package:meta/meta.dart';

import 'models/java_process_info.dart';

class JavaProcessExecutor extends ProcessExecutor {
  final String javaHome;
  final JavaProcessInfo javaProcessInfo;

  const JavaProcessExecutor({
    @required this.javaHome,
    @required this.javaProcessInfo,
  })  : assert(javaHome != null),
        assert(javaProcessInfo != null);

  @override
  Future<ProcessResult> runProcess(List<String> args) async {
    // TODO: Properly catach error
    final javaBin = _getJavaExecutable();

    if (!await _isJavaBinariesExists(javaBin)) {
      throw ('Java executable is not exists!');
    }

    final res =
        await Process.run(javaBin.absolute.path, await _buildArgs(args));
    return res;
  }

  File _getJavaExecutable() => Platform.isWindows
      ? File('$javaHome/bin/java.exe')
      : File('$javaHome/bin/java');

  @override
  Future<bool> isAvailable() => _isJavaBinariesExists(_getJavaExecutable());

  Future<bool> _isJavaBinariesExists(File javaBin) {
    return javaBin.exists();
  }

  Future<List<String>> _buildArgs(List<String> args) async {
    final classPath = await _resolveClasspath();

    return ['-classpath', classPath, javaProcessInfo.mainClassName, ...args];
  }

  Future<String> _resolveClasspath() async {
    final appHome = Directory(javaProcessInfo.appHome);

    if (!await appHome.exists()) {
      // TODO: catch this error
      throw ('Java app home folder "${appHome.absolute.path} is not exists"');
    }

    return javaProcessInfo.classpath
        .replaceAll('%APP_HOME%', appHome.absolute.path);
  }
}
