import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';

typedef WindowClosingCallback = Future<bool> Function();

class WindowControl {
  static WindowControl? _instance;

  Queue<WindowClosingCallback> _onClosingCallbacks = Queue();

  static WindowControl get instance {
    return _instance ?? WindowControl();
  }

  /**
   * Initializes WindowsControl instance
   */
  static void init() {
    instance;
  }

  WindowControl() {
    MethodChannel('window_control')..setMethodCallHandler(_onMethodCall);
  }

  Future<dynamic> _onMethodCall(MethodCall call) {
    switch (call.method) {
      case "onWindowClosing":
        return _doWindowClosing();
    }

    throw ("Unexpected method was called: ${call.method}");
  }

  Future<bool> _doWindowClosing() {
    if (_onClosingCallbacks.isEmpty) {
      return Future.value(true);
    }

    return _onClosingCallbacks.last();
  }

  void addOnWindowClosingCallback(WindowClosingCallback onClosingCallback) {
    if (!_onClosingCallbacks.contains(onClosingCallback)) {
      _onClosingCallbacks.add(onClosingCallback);
    }
  }

  void removeOnWindowClosingCallback(WindowClosingCallback onClosingCallback) {
    _onClosingCallbacks.remove(onClosingCallback);
  }
}
