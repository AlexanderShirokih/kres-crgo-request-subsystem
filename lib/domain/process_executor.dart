import 'dart:io';

/// Abstract class for executing external processes
abstract class ProcessExecutor {
  const ProcessExecutor();

  /// Runs process with command line arguments [args]
  Future<ProcessResult> runProcess(List<String> args);

  /// Returns `true` if the executor can start the process
  Future<bool> isAvailable();
}
