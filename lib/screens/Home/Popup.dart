import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'NotificationList.dart';

class PopupNotifications {
  static showNotificationDialog(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: NotificationList(),
      ),
    );
  }
}
