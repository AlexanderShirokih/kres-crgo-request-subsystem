import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';

typedef WindowClosingCallback = Future<bool> Function();

class WindowControl {
  static WindowControl? _instance;

  Queue<WindowClosingCallback> _onClosingCallbacks = Queue();

  static WindowControl get instance {
    if (_instance == null) _instance = WindowControl();
    return _instance!;
  }

  WindowControl() {
    MethodChannel('window_control')..setMethodCallHandler(_onMethodCall);
  }

  Future<dynamic> _onMethodCall(MethodCall call) {
    switch (call.method) {
      case "onWindowClosing":
        if (_onClosingCallbacks.isEmpty) return Future.value(true);
        return _onClosingCallbacks.last();
    }

    throw ("Unexpected method was called: ${call.method}");
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
