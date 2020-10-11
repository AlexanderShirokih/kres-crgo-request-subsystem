import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class WindowControl {
  static const MethodChannel _channel = const MethodChannel('window_control');

  static Future<bool> closeWindow() => exit(0);

  static Future<bool> minWindow() => _channel.invokeMethod<bool>('minWindow');

  static Future<bool> toggleMaxWindow() =>
      _channel.invokeMethod<bool>('toogleMaxWindow');

  static Future<bool> startDrag() => _channel.invokeMethod<bool>('startDrag');
}
