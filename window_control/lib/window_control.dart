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

  void triggerClosing() {
    _doWindowClosing().then((value) => print("CLOSING COMPLETED: $value"));
  }

  Future<bool> _doWindowClosing() {
    print("CLOSING CALLBACKS SIZE: ${_onClosingCallbacks.isEmpty}");

    if (_onClosingCallbacks.isEmpty) return Future.value(true);
    return _onClosingCallbacks.last();
  }

  Future<dynamic> _onMethodCall(MethodCall call) {
    switch (call.method) {
      case "onWindowClosing":
        return _doWindowClosing();
    }

    throw ("Unexpected method was called: ${call.method}");
  }

  void addOnWindowClosingCallback(WindowClosingCallback onClosingCallback) {
    print("ADDED CALLBACK $onClosingCallback");
    if (!_onClosingCallbacks.contains(onClosingCallback)) {
      _onClosingCallbacks.add(onClosingCallback);
    }
  }

  void removeOnWindowClosingCallback(WindowClosingCallback onClosingCallback) {
    print("REMOVED CALLBACK $onClosingCallback");
    _onClosingCallbacks.remove(onClosingCallback);
  }
}
