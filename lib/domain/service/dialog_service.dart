abstract class IDialogManager {
  /// Shows short error [message] without blocking.
  /// Error will disappear after few seconds.
  void showErrorMessage(String message);

  /// Shows short information [message].
  void showInfoMessage(String message);
}

/// Service representing base dialogs support
class DialogService {
  IDialogManager? _manager;

  /// Sets the current dialog manager
  void installDialogManager(IDialogManager manager) {
    _manager = manager;
  }

  /// Removes currently installed dialog manager
  void dispose() {
    _manager = null;
  }

  /// Shows short error [message] without blocking.
  /// Error will disappear after few seconds.
  void showErrorMessage(String message) {
    _manager?.showErrorMessage(message);
  }

  /// Shows short information [message].
  void showInfoMessage(String message) {
    _manager?.showInfoMessage(message);
  }
}
