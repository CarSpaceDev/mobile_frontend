import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PopupNotifications {
  static showNotificationDialog(BuildContext context, {@required Widget child, bool barrierDismissible=false}) {
    return showDialog(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: child,
      ),
    );
  }
}
