import 'package:carspace/model/CSNotification.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/PopupNotifications.dart';
import 'package:carspace/screens/DriverScreens/Vehicles/VehicleAddAuthDetails.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

import '../HomeDashboard.dart';

class NotificationWidget extends StatelessWidget {
  final CSNotification notification;
  final Function onTap;
  NotificationWidget({@required this.notification, this.onTap});
  @override
  Widget build(BuildContext context) {
    switch (notification.type) {
      case NotificationType.Info:
        return InfoNotificationWidget(
          notification: notification,
          onTap: onTap,
        );
      case NotificationType.VerificationRequest:
        return VehicleAddNotificationWidget(
          notification: notification,
          onTap: onTap,
        );
      case NotificationType.ExpiringLicense:
        return ExpiringLicenseWidget(
          notification: notification,
          onTap: onTap,
        );
      default:
        return _unsupportedNotification();
    }
  }

  Widget _unsupportedNotification() {
    return CSSegmentedTile(
      borderRadius: 5,
      shadow: true,
      onTap: onTap,
      color: notification.opened ? TileColor.DarkGrey : TileColor.Secondary,
      title: CSText(
        "Unsupported Notification Type",
        textAlign: TextAlign.center,
      ),
      body: Column(children: [
        CSText(
          "Notification type ${notification.type} \nPlease check NotificationWidget logic",
          textType: TextType.Caption,
          padding: EdgeInsets.only(top: 8),
        ),
        CSText(
          notification.dateCreated.toString(),
          textType: TextType.Caption,
          padding: EdgeInsets.only(top: 8),
        ),
      ]),
    );
  }
}

class VehicleAddNotificationWidget extends StatelessWidget {
  final CSNotification notification;
  final Function onTap;
  VehicleAddNotificationWidget({@required this.notification, this.onTap});
  @override
  Widget build(BuildContext context) {
    return CSSegmentedTile(
      onTap: () async {
        onTap();
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) {
              return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  child: VehicleAddAuthDetails(code: notification.data["code"]));
            });
      },
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(10),
      borderRadius: 5,
      shadow: true,
      color: notification.opened ? TileColor.DarkGrey : TileColor.Secondary,
      title: CSText(
        notification.title,
        textType: TextType.H5Bold,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CSText(
            "${formatDate(notification.dateCreated, [MM, " ", dd, ", ", yyyy, " ", HH, ":", mm])}",
            textType: TextType.Caption,
          )
        ],
      ),
    );
  }
}

class InfoNotificationWidget extends StatelessWidget {
  final CSNotification notification;
  final Function onTap;
  InfoNotificationWidget({@required this.notification, this.onTap});
  @override
  Widget build(BuildContext context) {
    return CSSegmentedTile(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(10),
      borderRadius: 5,
      shadow: true,
      onTap: onTap,
      color: notification.opened ? TileColor.DarkGrey : TileColor.Secondary,
      title: CSText(
        notification.title,
        textAlign: TextAlign.center,
        textType: TextType.H5Bold,
      ),
      body: Column(children: [
        CSText(
          notification.data["message"],
          textType: TextType.Caption,
          padding: EdgeInsets.only(top: 8, bottom: 16),
        ),
        CSText(
          "${formatDate(notification.dateCreated, [MM, " ", dd, ", ", yyyy, " ", HH, ":", mm])}",
          textType: TextType.Caption,
        )
      ]),
    );
  }
}

class ExpiringLicenseWidget extends StatelessWidget {
  final CSNotification notification;
  final Function onTap;
  ExpiringLicenseWidget({@required this.notification, this.onTap});
  @override
  Widget build(BuildContext context) {
    return CSSegmentedTile(
      onTap: () {
        if (!notification.opened) {
          onTap();
        }
        PopupNotifications.showNotificationDialog(
          context,
          barrierDismissible: true,
          child: UploadLicensePopup(),
        );
      },
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(10),
      borderRadius: 5,
      shadow: true,
      color: notification.opened ? TileColor.DarkGrey : TileColor.Secondary,
      title: CSText(
        notification.title,
        textAlign: TextAlign.center,
        textType: TextType.H5Bold,
      ),
      body: Column(children: [
        CSText(
          notification.data["message"],
          textType: TextType.Caption,
          padding: EdgeInsets.only(top: 8, bottom: 16),
        ),
        CSText(
          "${formatDate(notification.dateCreated, [MM, " ", dd, ", ", yyyy, " ", HH, ":", mm])}",
          textType: TextType.Caption,
        )
      ]),
    );
  }
}
