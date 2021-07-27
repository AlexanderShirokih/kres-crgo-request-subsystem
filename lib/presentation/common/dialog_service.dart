import 'package:flutter/material.dart';
import 'package:kres_requests2/domain/service/dialog_service.dart';

/// Injects dialogs into [DialogService]
class DialogManager extends StatefulWidget {
  final Widget child;
  final DialogService dialogService;

  const DialogManager({
    Key? key,
    required this.dialogService,
    required this.child,
  }) : super(key: key);

  @override
  _DialogManagerState createState() => _DialogManagerState();
}

class _DialogManagerState extends State<DialogManager>
    implements IDialogManager {
  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void initState() {
    super.initState();
    widget.dialogService.installDialogManager(this);
  }

  @override
  void dispose() {
    widget.dialogService.dispose();
    super.dispose();
  }

  @override
  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 6),
        content: Text(message),
      ),
    );
  }
}
