import 'dart:io';

import 'package:kres_requests2/domain/usecases/usecases.dart';

/// Gets the current working directory (cwd)
class GetCurrentDirectory implements AsyncUseCase<String> {
  @override
  Future<String> call() {
    final directory = Directory.current;
    return Future.value(directory.absolute.path);
  }
}
