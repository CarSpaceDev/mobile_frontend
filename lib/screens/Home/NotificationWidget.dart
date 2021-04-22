import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/model/CSNotification.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/screens/Home/VehicleAddAuthDetails.dart';
import 'package:flutter/material.dart';

class NotificationWidget extends StatelessWidget {
  final CSNotification notification;
  final Function onTap;
  NotificationWidget({@required this.notification, this.onTap});
  @override
  Widget build(BuildContext context) {
    if (notification.type == NotificationType.Info) {
      return _infoMessageNotification();
    } else if (notification.type == NotificationType.Action) {
      return _type1Notification(context);
    }
    return _unsupportedNotification();
  }

  Widget _infoMessageNotification() {
    return CSSegmentedTile(
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

  Widget _type1Notification(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
            color: notification.opened ? csStyle.csGrey : csStyle.theme().secondaryHeaderColor,
            borderRadius: BorderRadius.circular(5.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * .6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        notification.title,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(""),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        notification.dateCreated
                            .toString()
                            .substring(0, notification.dateCreated.toString().length - 5),
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    )
                  ],
                ),
              ),
              InkWell(
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
                child: Container(
                  height: 9.0 * 3,
                  width: 16.0 * 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.0),
                    color: Colors.grey,
                  ),
                  child: Center(
                      child: Text(
                    "See More",
                    style: TextStyle(color: Colors.white),
                  )),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
