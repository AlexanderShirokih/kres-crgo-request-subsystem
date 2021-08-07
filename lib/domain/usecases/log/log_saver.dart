import 'dart:io';
import 'package:path/path.dart';

/// Saves exception log to the file
class ErrorLogger {
  Future<void> call(Object error, StackTrace stack) async {
    try {
      final date = DateTime.now();
      final dateMs = date.millisecondsSinceEpoch;
      final logDir = Directory('log');

      await logDir.create();

      final logFile = File(join(logDir.absolute.path, 'error-log_$dateMs.txt'));

      final io = logFile.openWrite(mode: FileMode.write);

      io.writeln("Exception happened at $date!");
      io.writeln();

      io.writeln(error);
      io.writeln();

      io.writeln(stack.toString());
      await io.close();
    } catch (_) {
      // ignored
    }
  }
}
