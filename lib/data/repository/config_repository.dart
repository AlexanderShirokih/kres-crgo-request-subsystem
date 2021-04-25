import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:kres_requests2/data/models/java_process_info.dart';

class ConfigRepository {
  Completer<JavaProcessInfo>? _javaProcessInfo;

  static final ConfigRepository _instance = ConfigRepository._();

  ConfigRepository._();

  /// Returns instance to config repository singleton
  static ConfigRepository get instance => _instance;

  /// Returns [JavaProcessInfo] loaded from config file
  Future<JavaProcessInfo> get javaProcessInfo {
    if (_javaProcessInfo == null) {
      _javaProcessInfo = Completer();
      _javaProcessInfo!.complete(_buildJavaProcessInfo());
    }

    return _javaProcessInfo!.future;
  }

  static Future<JavaProcessInfo> _buildJavaProcessInfo() async {
    final requestsProcessInfo = await File('requests_processor_classpath.json')
        .readAsString()
        .then((value) => jsonDecode(value));
    return JavaProcessInfo.fromMap(requestsProcessInfo);
  }
}
